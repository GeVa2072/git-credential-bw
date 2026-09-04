# git-credential-bw

Git credential helper backed by [Bitwarden](https://bitwarden.com) via the `bw` CLI.

Looks up HTTPS credentials in a Bitwarden vault and returns them to git. When multiple credentials match the requested host, an interactive arrow-key menu lets you pick the right one.

## Requirements

- `bw` — [Bitwarden CLI](https://bitwarden.com/help/cli/)
- `jq`
- Bash 4+

## Installation

```bash
make install
```

Installs `git-credential-bw` to `/usr/local/bin` (use `PREFIX=...` to override).

## Configuration

Register the helper in your git config, optionally chained with git's built-in cache helper so credentials stay in memory between calls:

```ini
[credential]
    helper = cache --timeout 900
    helper = /usr/local/bin/git-credential-bw
```

Git queries helpers in order: the cache answers instantly on a hit, and only on a miss does `git-credential-bw` contact Bitwarden. After a successful lookup, git stores the credentials back into the cache automatically.

To pass your Bitwarden username upfront:

```bash
git config --global credential.helper "bw -l user@example.com"
```

## How it works

1. Git calls the helper with `get` and sends the credential context on stdin (`protocol`, `host`, etc.).
2. The helper ensures the Bitwarden vault is unlocked. If locked or logged out, it prompts for the master password on `/dev/tty`.
3. `bw list items --url <host>` retrieves login items whose URI matches the host, filtered to those with a custom field named `access_token`.
4. If multiple items match, an interactive arrow-key menu selects one.
5. The helper returns `username` (from the item's login username) and `password` (from the `access_token` custom field value).

### Session handling

The Bitwarden session key (`BW_SESSION`) lives only in memory for the duration of a single helper invocation. No secrets are written to disk. If the vault is locked or logged out, the helper prompts for the master password on `/dev/tty`. Chaining with git's `cache` helper minimises how often this happens — after a successful lookup, git stores the credentials in the cache, so subsequent calls within the timeout window never touch Bitwarden.

### Custom field convention

The helper uses the `access_token` custom field as the git password rather than the item's login password. This lets you store a personal access token (e.g. a GitLab PAT) separately from the login password in the same Bitwarden item.

## Make targets

| Target | Description |
|---|---|
| `all` | Make the script executable |
| `install` | Install to `$(PREFIX)/bin` (default `/usr/local/bin`) |
| `clean` | Remove the installed binary |
| `config` | Register helpers in git config (cache + bw) |

```bash
make install PREFIX=~/.local/bin
make config TIMEOUT=600
make clean
```

## License

GPL-3.0 — See [LICENSE](LICENSE).
