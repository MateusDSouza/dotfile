# Login shell: put Homebrew on PATH (macOS Apple Silicon, macOS Intel, Linux)
for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$b" ] && eval "$("$b" shellenv)" && break
done
