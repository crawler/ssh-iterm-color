# ssh-iterm-color

When you `ssh` somewhere from iTerm2, this zsh plugin sets the terminal background to a color
derived from the target hostname and shows the hostname as an iTerm2 badge, then reverts both when
ssh exits. Every server gets its own stable color, so you can tell sessions apart at a glance and
are less likely to run a command on the wrong machine by mistake. The hostname is the one `ssh -G`
resolves, i.e. the `HostName` from `~/.ssh/config`, not the alias you typed.

<!-- screenshot -->

## Requirements

- [iTerm2](https://iterm2.com)
- zsh

## Install

### oh-my-zsh

```zsh
git clone https://github.com/crawler/ssh-iterm-color ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ssh-iterm-color
```

Then add it to the plugin list in `~/.zshrc`:

```zsh
plugins=(... ssh-iterm-color)
```

### antidote

Add to `~/.zsh_plugins.txt`:

```
crawler/ssh-iterm-color
```

### zinit

```zsh
zinit light crawler/ssh-iterm-color
```

### Plain `source`

```zsh
git clone https://github.com/crawler/ssh-iterm-color ~/.zsh/ssh-iterm-color
echo 'source ~/.zsh/ssh-iterm-color/ssh-iterm-color.plugin.zsh' >> ~/.zshrc
```

## Usage

The plugin only defines functions. Add the alias to `~/.zshrc` after the plugin is loaded:

```zsh
alias ssh=ssh_iterm_color
```

## Configuration

Set these in `~/.zshrc`. Colors are hex `RGB` or `RRGGBB` (`301` is `#330011`), or `default`.

`SSH_BG_COLORS`: space-separated list of background colors to pick from. Default: `301 130 013 310`.

```zsh
SSH_BG_COLORS="300 030 003 330 033"
```

`ITERM_BG_COLOR`: background to restore when ssh exits. Default: `default` (the profile's background).

```zsh
ITERM_BG_COLOR=1d1f21
```

`NO_ITERM2_INTEGRATION_HOSTS`: array of hostnames for which no color or badge is set. Matched
against the resolved hostname (see above).

```zsh
NO_ITERM2_INTEGRATION_HOSTS=(build.example.com 192.0.2.10)
```

## Behaviour notes

- No escape sequences are printed when stdout is not a terminal (pipes, redirects), so
  `ssh host cat file > copy` stays byte-for-byte clean.
- Outside iTerm2 (`$TERM_PROGRAM` is not `iTerm.app`) it does nothing but run `ssh`.
- The revert runs on any ssh exit, including Ctrl-C (zsh `always` block).
- ssh's exit status is preserved.

## Test

```zsh
zsh test.zsh
```

Needs a pseudo-terminal (`script`) for the iTerm2 check; exits non-zero on failure.

## License

MIT
