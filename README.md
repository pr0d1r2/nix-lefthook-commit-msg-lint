# nix-lefthook-commit-msg-lint

[![CI](https://github.com/pr0d1r2/nix-lefthook-commit-msg-lint/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-commit-msg-lint/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible commit message linter, packaged as a Nix flake.

Enforces standard commit message conventions: capitalized subject (or conventional commit prefix like `feat:`, `fix:`), no trailing period, subject max 72 characters, blank second line, body lines max 80 characters. Skips merge, fixup, squash, and amend commits.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` - no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-commit-msg-lint
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-commit-msg-lint = {
  url = "github:pr0d1r2/nix-lefthook-commit-msg-lint";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-commit-msg-lint.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
commit-msg:
  commands:
    commit-msg-lint:
      run: timeout ${LEFTHOOK_COMMIT_MSG_LINT_TIMEOUT:-10} lefthook-commit-msg-lint {1}
```

### Configuring timeout

The default timeout is 10 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_COMMIT_MSG_LINT_TIMEOUT=30
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) - entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-commit-msg-lint  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
