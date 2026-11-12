#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { randomUUID } = require('node:crypto');
const { parseArgs } = require('node:util');

const NAME = 'pi-powerline-footer';
const SOURCE = `./local-packages/${NAME}`;
const UPSTREAM = 'https://github.com/nicobailon/pi-powerline-footer.git';
const DEFAULT_REF = 'v0.22.0';
const PATCH = path.join(__dirname, 'footer-blocks.patch');

function expand(value) {
  if (value === '~') return os.homedir();
  if (value.startsWith('~/')) return path.join(os.homedir(), value.slice(2));
  return path.resolve(value);
}

function exists(value) {
  try {
    fs.lstatSync(value);
    return true;
  } catch (error) {
    if (error.code === 'ENOENT') return false;
    throw error;
  }
}

// Resolve symlinked parents even when the final component does not exist yet.
function resolve(value) {
  try {
    return fs.realpathSync(value);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    const parent = path.dirname(value);
    if (parent === value) return value;
    // Preserve a dangling settings symlink rather than replacing the link itself.
    if (exists(value) && fs.lstatSync(value).isSymbolicLink()) {
      return resolve(path.resolve(parent, fs.readlinkSync(value)));
    }
    return path.join(resolve(parent), path.basename(value));
  }
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (error) {
    throw new Error(`Cannot read JSON from ${file}: ${error.message}`);
  }
}

function validatePackage(directory) {
  const manifest = readJson(path.join(directory, 'package.json'));
  if (manifest?.name !== NAME) throw new Error(`Unexpected package manifest in ${directory}`);
}

function git(...args) {
  const result = spawnSync('git', args, { stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`Git command failed (exit ${result.status})`);
}

function cloneFooter(destination, repository, ref) {
  if (exists(destination)) throw new Error(`Destination already exists: ${destination}`);
  if (!fs.statSync(PATCH).isFile()) throw new Error(`Missing patch: ${PATCH}`);
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  const temporary = fs.mkdtempSync(path.join(path.dirname(destination), '.pi-footer-clone-'));
  try {
    const checkout = path.join(temporary, 'checkout');
    git('-c', 'advice.detachedHead=false', 'clone', '--depth', '1', '--branch', ref,
      '--', repository, checkout);
    validatePackage(checkout);
    git('-C', checkout, 'apply', '--check', PATCH);
    git('-C', checkout, 'apply', PATCH);
    git('-C', checkout, 'switch', '-c', 'local/context-blocks');
    if (exists(destination)) throw new Error(`Destination appeared during clone: ${destination}`);
    fs.renameSync(checkout, destination);
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
  console.log(`Cloned and customized ${destination}; source changes are uncommitted.`);
}

function isFooter(source, agentDir, local) {
  if (typeof source !== 'string') return false;
  if (source === `npm:${NAME}` || source.startsWith(`npm:${NAME}@`)) return true;
  if (!source.startsWith('.') && !source.startsWith('/') && !source.startsWith('~')) return false;
  const absolute = source.startsWith('~') ? expand(source) : path.resolve(agentDir, source);
  return resolve(absolute) === resolve(local);
}

function bootstrap({ agentDir, clone, repository, ref }) {
  agentDir = expand(agentDir);
  const local = path.join(agentDir, 'local-packages', NAME);
  const packageDir = clone ? expand(clone) : local;
  const settings = path.join(agentDir, 'settings.json');
  const target = resolve(settings);
  const config = fs.existsSync(target) ? readJson(target) : {};
  if (!config || typeof config !== 'object' || Array.isArray(config)) {
    throw new Error('settings.json must contain a JSON object');
  }
  const packages = config.packages ?? [];
  if (!Array.isArray(packages) || config.packages === null) {
    throw new Error('settings.json packages must be an array');
  }
  if (exists(local) && resolve(local) !== resolve(packageDir)) {
    throw new Error(`Refusing to overwrite existing package: ${local}`);
  }
  if (exists(packageDir)) throw new Error(`Destination already exists: ${packageDir}`);

  let found = false;
  const updated = packages.map((entry) => {
    const object = entry !== null && typeof entry === 'object' && !Array.isArray(entry);
    if (!isFooter(object ? entry.source : entry, agentDir, local)) return entry;
    if (found) throw new Error('Multiple footer registrations; resolve their resource filters first');
    found = true;
    return object ? { ...entry, source: SOURCE } : SOURCE;
  });
  if (!found) updated.push(SOURCE);
  const changed = !Object.hasOwn(config, 'packages') || JSON.stringify(updated) !== JSON.stringify(packages);
  config.packages = updated;

  // Validate settings and conflicts before cloning or modifying the configuration.
  cloneFooter(packageDir, repository, ref);
  if (!exists(local)) {
    fs.mkdirSync(path.dirname(local), { recursive: true });
    fs.symlinkSync(packageDir, local, 'dir');
    console.log(`Linked ${local} -> ${packageDir}`);
  }
  if (changed) {
    fs.mkdirSync(path.dirname(target), { recursive: true });
    const mode = fs.existsSync(target) ? fs.statSync(target).mode & 0o777 : 0o600;
    if (fs.existsSync(target)) {
      const backup = `${target}.backup-${randomUUID()}`;
      fs.copyFileSync(target, backup, fs.constants.COPYFILE_EXCL);
      fs.chmodSync(backup, mode);
      console.log(`Backup: ${backup}`);
    }
    const temporary = path.join(path.dirname(target), `.${path.basename(target)}.${randomUUID()}`);
    try {
      fs.writeFileSync(temporary, `${JSON.stringify(config, null, 2)}\n`, { flag: 'wx', mode });
      fs.renameSync(temporary, target);
    } finally {
      fs.rmSync(temporary, { force: true });
    }
    console.log(`Registered ${SOURCE} in ${settings}`);
  } else {
    console.log(`Already registered in ${settings}; no settings changes`);
  }
  console.log('Run /reload in Pi to load the footer.');
}

function main() {
  const { values } = parseArgs({ options: {
    'agent-dir': { type: 'string', default: path.join(os.homedir(), '.pi', 'agent') },
    clone: { type: 'string' },
    repo: { type: 'string' },
    ref: { type: 'string' },
    help: { type: 'boolean', short: 'h' },
  } });
  if (values.help) {
    console.log(`Usage: node pi/bootstrap.js [--agent-dir PATH] [--clone NEW_PATH] [--repo URL] [--ref TAG]

Default: clone into ~/.pi/agent/local-packages/pi-powerline-footer, patch, and register.
--agent-dir PATH: use a different Pi configuration directory.
--clone NEW_PATH: clone elsewhere and link into the Pi local-package path.
--repo URL and --ref TAG override the source (defaults: upstream, ${DEFAULT_REF}).
Existing package paths are never overwritten. Requires Node.js 22+ and Git.`);
    return;
  }
  bootstrap({ agentDir: values['agent-dir'], clone: values.clone,
    repository: values.repo ?? UPSTREAM, ref: values.ref ?? DEFAULT_REF });
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(`Bootstrap failed: ${error.message}`);
    process.exitCode = 1;
  }
}
