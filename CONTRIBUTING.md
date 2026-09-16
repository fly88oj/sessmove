# Contributing to sessmove

Thanks for your interest in improving sessmove! The project is implemented
in Rust; keep new dependencies minimal and justified.

## Getting started

```bash
git clone https://github.com/fly88oj/sessmove && cd sessmove
cargo test --all                          # all tests must pass
cargo clippy --all-targets -- -D warnings # no warnings
cargo fmt --all -- --check
./target/release/agentpath agents         # smoke check
```

Install the local git hooks (same checks the CI runs):

```bash
pipx install pre-commit        # or: pip install --user pre-commit
pre-commit install             # enables pre-commit + commit-msg hooks
```

The hooks enforce: whitespace/YAML/TOML hygiene, large-file and private-key
detection, `cargo fmt` + `cargo clippy -D warnings`, the Conventional
Commits message format, and a "no local machine info" scanner.
Run everything manually with `pre-commit run --all-files`.

Layout (the crate root is `src/` directly — `src/lib.rs` is the crate):

```
src/
  lib.rs                  crate root: module docs + i18n init
  bin/sessmove.rs         the sessmove binary (mv subcommand implied)
  bin/agentpath.rs        the agentpath binary (full CLI)
  spec.rs                 boundary-aware replacement spec (linear scanner + derived tokens)
  backup.rs               change journal and undo
  rewriters.rs            text / JSON / JSONL rewriters
  sqlite.rs / protobuf.rs rusqlite helpers, protobuf wire rewriter
  encodings.rs            per-vendor directory-name encodings & hashes
  ctx.rs                  cross-platform state-dir resolution
  i18n.rs + locales/      UI languages (en, zh-CN, ja, ko, es, fr, de, pt-BR)
  cli.rs                  clap CLI (scan / migrate / mv / undo / backups)
  adapters/               one module per agent family
build.rs                  rebuild when locales/*.yml change
scripts/                  commit-message & no-local-info hook scripts
tests/                    fixture-based unit tests + sessmove + robustness
docs/research*.md         storage-format research notes with sources
packaging/                local packaging helpers (tarball / deb / rpm / dmg / homebrew)
.github/workflows/        CI + tag-triggered release pipeline
```

## Commit messages — Conventional Commits

This project follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/).
The commit-msg hook (`scripts/check-commit-msg.sh`) rejects anything else,
and CI re-checks every commit in a PR:

```
<type>(<scope>)?: <summary>          # summary <= 72 chars, no trailing period

<optional body, wrapped at ~72>      # blank line between subject and body

<optional footers>                   # e.g. Fixes: #123
```

- **types**: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build`
  `ci` `chore` `revert`
- **scopes** (optional): `engine` `adapters` `cli` `i18n` `tests`
  `packaging` `docs` `deps` `release`

Examples:

```
feat(adapters): add gemini cli adapter with sha256 projectHash rewrite
fix(engine): preserve CRLF line endings in jsonl rewrites
docs(readme): calibrate verification wording in all languages
```

## Adding a new agent adapter

1. **Research the storage layout** — where the agent keys state by the
   project path: encoded directory names, hash names (sha256/md5/…),
   SQLite columns, JSON/JSONL identity fields, protobuf blobs. Verify the
   encoding algorithm against real data on your machine and record the
   evidence and source links in `docs/research.md`.
2. **Write the adapter** — implement the `Adapter` trait in
   `src/adapters/` (`state_paths`, `scan`, `migrate`) and
   register the type in `all()` / the relevant module. Reuse the shared
   helpers (`scan_tree`, `migrate_text_tree`, `migrate_pb_tree`,
   `encoded_bucket_findings`, `rename_encoded_children`,
   `rewrite_pair`, `rewrite_file_by_ext`) and the `encodings`
   module; add a new encoding function there if the vendor scheme differs.
   Project conventions:
   - SQL statements must be **inline literals executed with bound
     parameters only** (rusqlite `params!` — both a security-hook
     requirement here and good practice everywhere).
   - Default to rewriting *identity* fields only (cwd, directory,
     project, …); path mentions inside chat content belong behind
     `--deep`.
   - Return a `note` describing the state layout for `agentpath agents`.
3. **Add unit tests** — extend the `Fixture` builder in
   `tests/common/mod.rs` with the agent's real layout, then assert the
   post-migration state in `tests/units.rs` (see `claude_bucket_rename…`
   for the pattern). Cover: directory renames, SQLite updates, derived
   hash tokens, no leftovers for sibling paths (`/a/abc2` must stay
   untouched), and undo restoring everything.
4. **E2E if the CLI is installed locally** — sandbox `SESSMOVE_HOME`,
   create a real session in `proj/abc`, run `./target/release/sessmove
   --deep $SANDBOX/proj/abc $SANDBOX/proj/cba`, verify zero leftovers
   and — best — that the agent's own resume/continue finds the session
   under the new path.

## Guidelines

- Keep dependencies minimal and justified; Rust stable, edition 2021.
- Every destructive path must stay reversible: record file backups,
  `wal_checkpoint` + copy SQLite databases, journal renames. `undo` is a
  feature, not an afterthought.
- Boundary-aware replacement only (`ReplaceSpec`); never naive
  `str::replace` on user paths.
- New user-facing strings go into **all eight** `locales/*.yml` files
  (key parity is checked in review; the rust-i18n fallback is en).
- Update `CHANGELOG.md` (Keep a Changelog format) and, for new adapters,
  the tables in every README language.
- Never commit local machine info (real home paths, hostnames,
  credentials); `scripts/check-no-local-info.sh` blocks it and redact
  examples to `/home/user/...`.

## Reporting bugs / security

Open an issue with the agent name, its version, the relevant state paths
and (redacted) evidence. For security matters see [SECURITY.md](SECURITY.md).

## License

By contributing you agree that your contributions are licensed under the
GNU General Public License v3.0 or later ([LICENSE](LICENSE)).
