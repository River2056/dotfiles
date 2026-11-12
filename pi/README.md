# Pi dotfiles

## Bootstrap the footer

Requires Node.js 22+, Git, and network access. No npm dependencies or Pi CLI
invocation are needed. From the dotfiles repository, run:

```sh
./pi/bootstrap.sh
```

Or invoke Node.js directly:

```sh
node pi/bootstrap.js
```

Both commands clone into `~/.pi/agent/local-packages/pi-powerline-footer`, matching
the `./local-packages/pi-powerline-footer` source in Pi settings. The package is
not vendored in dotfiles; this repository keeps only the setup scripts and patch.
The Bash wrapper locates the JavaScript script independently of the working
directory and forwards additional arguments.

Bootstrap:

1. Clones `https://github.com/nicobailon/pi-powerline-footer.git` at `v0.22.0`.
2. Applies `pi/footer-blocks.patch` to `segments.ts`.
3. Creates branch `local/context-blocks`, leaving customization uncommitted.
4. Registers the local package in Pi settings.

The bar uses ten `▰`/`▱` blocks, rounded and clamped to 0–100%, before the
existing figures in both full and percent formats. Unknown usage shows empty
blocks; threshold colors and custom-compaction hiding remain unchanged.

## Options

To clone elsewhere and link that checkout into the Pi local-package path:

```sh
node pi/bootstrap.js --clone ~/src/pi-powerline-footer-blocks
```

Use `--repo URL` and `--ref BRANCH_OR_TAG` to override the upstream repository
and version. Add `--agent-dir` to use a different Pi configuration directory:

```sh
node pi/bootstrap.js --agent-dir /path/to/agent
node pi/bootstrap.js --agent-dir /path/to/agent --clone /path/to/new-checkout
```

The clone destination must not exist. Existing directories and symlinks are
never overwritten, including on repeated runs. If the local-package path
already points to another checkout, review and remove only that old symlink
before choosing a new source; do not delete the underlying package directory.
If upstream has drifted and the patch no longer matches, bootstrap removes the
temporary clone and leaves Pi settings untouched. No dependencies are installed.

## Settings safety

Bootstrap updates only `packages` in `~/.pi/agent/settings.json`: it replaces
an npm footer registration (including pinned versions), normalizes an existing
local registration, or appends it when absent. Object-form resource filters
and unrelated settings are preserved. No other packages are updated.

Settings changes receive a sibling `settings.json.backup-*` backup. Settings
symlinks are preserved: their target is updated. Invalid settings, duplicate
footer declarations, and conflicting package paths are rejected before cloning
or changing configuration. A successful clone is retained if a later filesystem
error prevents registration; inspect the printed error before retrying.

Run `/reload` in Pi after bootstrap. Use `node pi/bootstrap.js --help` for options.

## Tests

```sh
node --test pi/bootstrap.test.js
```

Tests use temporary configuration directories and minimal local Git fixtures
constructed from the patch. They do not access the network, a vendored package,
or your live Pi settings.
