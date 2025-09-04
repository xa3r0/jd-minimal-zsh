# jd-minimal-zsh

A one-shot bootstrap that installs **Oh My Zsh**, enables two must-have plugins, and drops in a **minimal prompt theme**.

### Prompt preview

```
username::host | ~/path >>
```

- `>>` turns **green** when the last command succeeded, **red** when it failed.
- Includes **autosuggestions** and **syntax highlighting**.
- Detects whether a **Nerd Font** is available. If missing, it can auto-install **JetBrainsMono Nerd Font** into your user fonts directory (Linux). You can disable that behavior with a flag.

---

## Quick start

```bash
git clone https://github.com/xa3r0/jd-minimal-zsh.git
cd jd-minimal-zsh
chmod +x install.sh
./install.sh
exec zsh
```

That’s it. Your prompt will look like:

```
jd::jd | ~/projects >>
```

---

## What the installer does

1. Ensures `zsh`, `git`, `curl` exist (Debian/Ubuntu, Fedora, Arch supported).
2. Installs **Oh My Zsh** if missing.
3. Installs plugins:
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
4. Installs theme file to `~/.oh-my-zsh/custom/themes/jd-minimal/jd-minimal.zsh-theme`.
5. Updates `~/.zshrc` to:
   - set `ZSH_THEME="jd-minimal/jd-minimal"`
   - enable the two plugins above
   - add a small commented config block for custom options
6. Detects a **Nerd Font**:
   - If none found, downloads **JetBrainsMono Nerd Font** to `~/.local/share/fonts/NerdFonts/JetBrainsMono` and refreshes font cache.
   - You can skip font install with `--no-font` or `JD_INSTALL_FONT=0`.

---

## Flags and environment variables

- `--no-font` => skip Nerd Font detection/install
- `JD_INSTALL_FONT=0` => same as `--no-font`
- `JD_SYMBOL=">>"` => choose your prompt symbol (ASCII default). Examples: `>>`, `❯❯`, `$`
- `JD_PATH_MODE="short"` => path style
  - `short` => `~` shorthand (uses `%~`)
  - `full` => full path (uses `%d`)
- `JD_COLORS_USER`, `JD_COLORS_HOST`, `JD_COLORS_PATH` => zsh color names for parts
  - defaults: `cyan`, `yellow`, `green`

You can set these in your shell before running the installer, or permanently in your `~/.zshrc` after the block the installer adds.

Examples:

```bash
JD_SYMBOL="❯❯" JD_PATH_MODE=full ./install.sh
# later, if you want to change:
echo 'export JD_SYMBOL=">>"' >> ~/.zshrc
echo 'export JD_PATH_MODE="short"' >> ~/.zshrc
exec zsh
```

---

## Customization cheat sheet

Edit the env vars in `~/.zshrc` to customize:

```zsh
# jd-minimal options (feel free to adjust)
export JD_SYMBOL=">>"            # or "❯❯" if you like
export JD_PATH_MODE="short"      # "short" => %~ , "full" => %d
export JD_COLORS_USER="cyan"
export JD_COLORS_HOST="yellow"
export JD_COLORS_PATH="green"
```

Switch back to any Oh My Zsh theme by changing:

```zsh
ZSH_THEME="some-other-theme"
```

---

## Uninstall

Revert your theme setting and remove the theme directory:

```bash
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="robbyrussell"|' ~/.zshrc
rm -rf ~/.oh-my-zsh/custom/themes/jd-minimal
exec zsh
```

Optionally remove the two plugins:

```bash
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

---

## Troubleshooting

- Changes not visible after editing `.zshrc`:
  - Run `source ~/.zshrc` or `exec zsh`.
- Terminal still starts in bash:
  - `chsh -s /usr/bin/zsh` and log out/in once, or add to end of `~/.bashrc`:
    ```bash
    if [[ $- == *i* ]] && [ -z "$ZSH_VERSION" ]; then exec zsh; fi
    ```
- Nerd Font not picked up in the terminal:
  - Set your terminal profile font to any *Nerd Font* installed. The theme uses ASCII by default, so fonts are optional.

---

## Repo layout

```
jd-minimal-zsh/
├── .gitignore
├── LICENSE
├── README.md
├── install.sh
└── themes/
    └── jd-minimal.zsh-theme
```

---

## License

MIT © JD
