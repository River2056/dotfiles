'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { test } = require('node:test');

const SCRIPT = path.join(__dirname, 'bootstrap.js');
const PATCH = path.join(__dirname, 'footer-blocks.patch');
const SOURCE = './local-packages/pi-powerline-footer';

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'pi-bootstrap-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const agent = path.join(root, 'agent');
  fs.mkdirSync(agent);
  const settings = path.join(agent, 'settings.json');
  const repository = upstream({ root });
  return { root, agent, settings,
    save: (config) => fs.writeFileSync(settings, JSON.stringify(config)),
    config: () => JSON.parse(fs.readFileSync(settings, 'utf8')),
    run: (args = [], status = 0) => {
      const result = spawnSync(process.execPath, [SCRIPT, '--agent-dir', agent, '--repo', repository, ...args], { encoding: 'utf8' });
      assert.equal(result.status, status, result.stderr);
      return result;
    },
    local: path.join(agent, 'local-packages/pi-powerline-footer'),
    backups: () => fs.readdirSync(agent).filter((name) => name.startsWith('settings.json.backup-')),
  };
}

function git(directory, ...args) {
  const result = spawnSync('git', ['-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null',
    '-C', directory, ...args], { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim();
}

// Keep only a minimal synthetic fixture, not a copy of the upstream package.
function patchSource(patched) {
  const lines = fs.readFileSync(PATCH, 'utf8').split('\n');
  return lines.slice(lines.findIndex((line) => line.startsWith('@@')) + 1)
    .filter((line) => line.startsWith(' ') || line.startsWith(patched ? '+' : '-'))
    .map((line) => line.slice(1)).join('\n') + '\n';
}

function upstream(f) {
  const repository = path.join(f.root, 'upstream');
  if (fs.existsSync(repository)) return repository;
  fs.mkdirSync(repository);
  git(repository, 'init');
  fs.writeFileSync(path.join(repository, 'segments.ts'), patchSource(false));
  fs.writeFileSync(path.join(repository, 'package.json'), JSON.stringify({ name: 'pi-powerline-footer' }));
  git(repository, 'add', '.');
  git(repository, '-c', 'user.name=Test', '-c', 'user.email=test@example.invalid',
    'commit', '-m', 'Upstream fixture');
  git(repository, 'tag', 'v0.22.0');
  return repository;
}

test('default clones into configured package path and refuses to overwrite on rerun', (t) => {
  const f = fixture(t);
  f.run();
  assert.deepEqual(f.config(), { packages: [SOURCE] });
  assert.ok(fs.existsSync(path.join(f.local, '.git')));
  assert.equal(fs.readFileSync(path.join(f.local, 'segments.ts'), 'utf8'), patchSource(true));
  const before = fs.statSync(f.settings).mtimeMs;
  f.run([], 1);
  assert.equal(fs.statSync(f.settings).mtimeMs, before);
  assert.deepEqual(f.backups(), []);
});

test('npm replacements preserve object filters, unrelated settings, and exact backup', (t) => {
  const f = fixture(t);
  const original = { theme: 'gruvbox-dark', skills: ['~/skills'], packages: ['npm:unrelated',
    { source: 'npm:pi-powerline-footer@0.22.0', extensions: [] }] };
  f.save(original);
  const before = fs.readFileSync(f.settings, 'utf8');
  f.run();
  assert.deepEqual(f.config(), { ...original, packages: ['npm:unrelated', { source: SOURCE, extensions: [] }] });
  assert.equal(f.backups().length, 1);
  assert.equal(fs.readFileSync(path.join(f.agent, f.backups()[0]), 'utf8'), before);
  f.run([], 1);
  assert.equal(f.backups().length, 1);
});

test('unpinned npm and absolute local sources normalize', (t) => {
  for (const source of ['npm:pi-powerline-footer', 'absolute']) {
    const f = fixture(t);
    f.save({ packages: [source === 'absolute' ? f.local : source] });
    f.run();
    assert.deepEqual(f.config().packages, [SOURCE]);
  }
});

test('Stow settings symlink is preserved', (t) => {
  const f = fixture(t);
  const target = path.join(f.root, 'stowed-settings.json');
  fs.writeFileSync(target, '{"packages":["npm:pi-powerline-footer"]}');
  fs.symlinkSync(target, f.settings);
  f.run();
  assert.ok(fs.lstatSync(f.settings).isSymbolicLink());
  assert.ok(fs.existsSync(path.join(f.local, '.git')));
  assert.deepEqual(f.config().packages, [SOURCE]);
});

test('invalid settings fail without links or backups', (t) => {
  for (const content of ['{broken', '[]', 'null', '{"packages":{}}', '{"packages":null}']) {
    const f = fixture(t);
    fs.writeFileSync(f.settings, content);
    f.run([], 1);
    assert.equal(fs.readFileSync(f.settings, 'utf8'), content);
    assert.ok(!fs.existsSync(path.dirname(f.local)));
    assert.deepEqual(f.backups(), []);
  }
});

test('conflicting local checkout is never overwritten', (t) => {
  const f = fixture(t);
  fs.mkdirSync(f.local, { recursive: true });
  f.save({ packages: ['npm:pi-powerline-footer'] });
  f.run([], 1);
  assert.ok(!fs.lstatSync(f.local).isSymbolicLink());
  assert.deepEqual(f.config(), { packages: ['npm:pi-powerline-footer'] });
});

test('duplicate footer declarations are rejected before writes', (t) => {
  const f = fixture(t);
  f.save({ packages: ['npm:pi-powerline-footer', SOURCE] });
  const before = fs.readFileSync(f.settings, 'utf8');
  f.run([], 1);
  assert.equal(fs.readFileSync(f.settings, 'utf8'), before);
  assert.ok(!fs.existsSync(path.dirname(f.local)));
});

test('custom clone path is patched and registered with filters preserved', (t) => {
  const f = fixture(t);
  const repository = upstream(f);
  const destination = path.join(f.root, 'custom footer');
  f.save({ theme: 'test', packages: [{ source: 'npm:pi-powerline-footer', extensions: [] }] });
  f.run(['--clone', destination, '--repo', repository]);
  assert.equal(fs.readFileSync(path.join(destination, 'segments.ts'), 'utf8'),
    patchSource(true));
  assert.equal(fs.realpathSync(f.local), fs.realpathSync(destination));
  assert.deepEqual(f.config(), { theme: 'test', packages: [{ source: SOURCE, extensions: [] }] });
  assert.equal(git(destination, 'diff', '--name-only'), 'segments.ts');
  assert.equal(git(destination, 'branch', '--show-current'), 'local/context-blocks');
  git(destination, 'diff', '--check');
  const before = fs.readFileSync(f.settings, 'utf8');
  f.run(['--clone', destination, '--repo', repository], 1);
  assert.equal(fs.readFileSync(f.settings, 'utf8'), before);
});

test('clone may use the actual local-package path', (t) => {
  const f = fixture(t);
  const repository = upstream(f);
  f.run(['--clone', f.local, '--repo', repository]);
  assert.ok(fs.existsSync(path.join(f.local, '.git')));
  assert.ok(!fs.lstatSync(f.local).isSymbolicLink());
  assert.deepEqual(f.config().packages, [SOURCE]);
});

test('clone failure or source drift leaves no partial destination or settings', (t) => {
  const f = fixture(t);
  const repository = upstream(f);
  fs.writeFileSync(path.join(repository, 'segments.ts'), '// incompatible\n');
  git(repository, 'add', '.');
  git(repository, '-c', 'user.name=Test', '-c', 'user.email=test@example.invalid', 'commit', '-m', 'Drift');
  git(repository, 'tag', 'incompatible');
  const destination = path.join(f.root, 'clone');
  for (const ref of ['missing-tag', 'incompatible']) {
    f.run(['--clone', destination, '--repo', repository, '--ref', ref], 1);
    assert.ok(!fs.existsSync(destination));
    assert.ok(!fs.existsSync(f.settings));
    assert.ok(!fs.existsSync(path.dirname(f.local)));
    assert.ok(!fs.readdirSync(f.root).some((name) => name.startsWith('.pi-footer-clone-')));
  }
});

test('invalid settings are rejected before attempting a clone', (t) => {
  const f = fixture(t);
  fs.writeFileSync(f.settings, '[]');
  const destination = path.join(f.root, 'new-parent/clone');
  f.run(['--clone', destination, '--repo', '/nonexistent/repo'], 1);
  assert.ok(!fs.existsSync(path.dirname(destination)));
});

test('help and invalid CLI options never write configuration', (t) => {
  const f = fixture(t);
  assert.match(f.run(['--help']).stdout, /Usage: node/);
  f.run(['--ref'], 1);
  f.run(['--unknown'], 1);
  assert.ok(!fs.existsSync(f.settings));
});
