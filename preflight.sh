#!/usr/bin/env bash
# Checks that every host the install downloads from is reachable, before touching anything.
# Run on its own with ./preflight.sh or `just preflight`; bootstrap.sh runs it first.
set -uo pipefail

hosts=(
  # Homebrew: install script, API, bottles, taps
  https://github.com https://raw.githubusercontent.com https://formulae.brew.sh
  https://ghcr.io https://pkg-containers.githubusercontent.com
  https://releases.hashicorp.com
  # uv: Python builds (GitHub releases) and PyPI
  https://release-assets.githubusercontent.com https://pypi.org https://files.pythonhosted.org
  # VS Code extensions
  https://marketplace.visualstudio.com
)

if [ "$(uname -s)" = Linux ]; then
  # Every enabled apt repository (classic .list and deb822 .sources formats)
  while read -r h; do hosts+=("$h"); done < <(
    { grep -hE '^\s*deb(-src)?\s' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null
      grep -hE '^\s*URIs:' /etc/apt/sources.list.d/*.sources 2>/dev/null
    } | grep -oE 'https?://[^/ ]+' | sort -u
  )
  # Desktop apps: only checked when apps-linux will actually install them (never on WSL)
  if ! grep -qi microsoft /proc/version; then
    { command -v ghostty && command -v code; } >/dev/null || hosts+=(https://api.snapcraft.io)
    command -v docker >/dev/null || hosts+=(https://get.docker.com https://download.docker.com)
  fi
fi

failed=() dns_failed=0
for url in "${hosts[@]}"; do
  host=${url#*://}
  if command -v curl >/dev/null; then
    curl -sS -o /dev/null --head --max-time 15 "$url" 2>/dev/null; rc=$?
    # 0 = any HTTP response; 6 = DNS lookup failed
    [ $rc -eq 6 ] && dns_failed=1
  else
    # Fresh Ubuntu may not have curl yet: resolve, then open a TCP connection
    port=443; [ "${url%%://*}" = http ] && port=80
    if ! getent hosts "$host" >/dev/null; then rc=6; dns_failed=1
    else timeout 10 bash -c "</dev/tcp/$host/$port" 2>/dev/null; rc=$?; fi
  fi
  if [ $rc -eq 0 ]; then printf '  \033[32m✔\033[0m %s\n' "$host"
  else printf '  \033[31m✘\033[0m %s (%s)\n' "$host" "$([ $rc -eq 6 ] && echo "DNS lookup failed" || echo "unreachable, code $rc")"; failed+=("$host"); fi
done

[ ${#failed[@]} -eq 0 ] && { echo "✔ all repositories reachable"; exit 0; }

echo >&2
echo "✘ ${#failed[@]} host(s) unreachable. Nothing was installed." >&2
if [ $dns_failed -eq 1 ] && [ "$(uname -s)" = Linux ]; then
  cat >&2 <<'EOF'

Your DNS server can't resolve some hosts (some ISP resolvers break on ubuntu.com).
Switch to public DNS, then run again:

  sudo mkdir -p /etc/systemd/resolved.conf.d
  printf '[Resolve]\nDNS=1.1.1.1 8.8.8.8\nDomains=~.\n' | sudo tee /etc/systemd/resolved.conf.d/dns.conf
  sudo systemctl restart systemd-resolved
EOF
fi
exit 1
