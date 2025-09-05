# Contributing to jd-minimal-zsh

Thanks for taking the time to contribute. This project is intentionally small and simple. Keep it clean and minimal.

## Ground rules
- Keep the prompt minimal. No heavy frameworks or slow shell hacks.
- Default paths, colors, and symbols must be configurable via environment variables.
- Do not break install on Debian/Ubuntu, Fedora, or Arch.
- Scripts must pass `shellcheck`.

## Getting started
1. Fork the repo and create a feature branch.
2. Make your changes in small, focused commits.
3. Run lint locally:
   ```bash
   sudo apt install shellcheck  # or your distro equivalent
   shellcheck -S style install.sh
