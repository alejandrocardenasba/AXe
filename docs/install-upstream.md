# Install upstream AXe

This fork adds Apple TV support on top of [cameroncooke/AXe](https://github.com/cameroncooke/AXe). The README installs the fork. These steps install upstream's release instead, without the Apple TV commands. Do not mix the two: the Homebrew binary and a fork build both answer to `axe`.

## CLI

```bash
brew install cameroncooke/axe/axe
axe --help
```

Brew puts `axe` in `$(brew --prefix)/bin`. If you built the fork into `~/.local/opt/axe`, remove the symlink or put the Homebrew directory first on `PATH`, then check with `which axe`.

To go back to the fork, follow the README's Install section.

## Skill for AI clients

### Claude Code

```bash
claude plugin marketplace add cameroncooke/AXe --sparse .claude-plugin agent-plugin && claude plugin install axe@axe
```

### Codex

```bash
codex plugin marketplace add cameroncooke/AXe --sparse .agents --sparse agent-plugin && codex plugin add axe@axe
```

### Kiro and other agents

Neither command above covers Kiro. Install the skill that ships inside the upstream binary:

```bash
axe init --dest ~/.kiro/skills --force
```

`axe init` with no options installs into `~/.claude/skills` and `~/.agents/skills` for each client it finds.

The skill tells an agent to run `brew install cameroncooke/axe/axe` when `axe` is missing. That line matches upstream and is wrong for the fork.

## Switching an existing plugin install

Remove the fork's marketplace first, then add upstream's:

```bash
claude plugin marketplace remove axe
codex plugin marketplace remove axe
```

Both marketplaces are named `axe`, so only one can be registered at a time.
