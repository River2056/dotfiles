#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
agent_dir="${HOME}/.pi/agent"

exec node "${script_dir}/bootstrap.js" \
  --agent-dir "${agent_dir}" \
  --clone "${agent_dir}/local-packages/pi-powerline-footer" \
  "$@"
