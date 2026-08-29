# CFM Voice

A set of voice alerts for World of Warcraft (Retail), packaged as a [LibSharedMedia-3.0](https://www.wowace.com/projects/libsharedmedia-3-0)
media addon. Assign the sounds to alerts in raid addons like BigWigs, Northern Sky Raid Tools, or
Deadly Boss Mods.

## Requirements

- World of Warcraft (Retail)
- [LibSharedMedia-3.0](https://www.wowace.com/projects/libsharedmedia-3-0), loaded by another addon
  (e.g. BigWigs). This addon does not bundle its own copy.

## Installation

Clone the repository into your AddOns directory:

```
/Applications/World of Warcraft/_retail_/Interface/AddOns/
```

Syncing this repo with tools like CurseForge or the Wago app may be possible, but it isn't
currently supported. This addon is intentionally not published to those platforms — it's a
personal project, not a public release.

## Development

### Dependencies

- [ffmpeg](https://ffmpeg.org/) — used by `make convert` to transcode `.wav` sources to `.mp3`.
- [awk](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html) — used by
  `scripts/update-sounds.sh` and `make update` to generate Lua tables and bump the TOC version.
  Any POSIX awk works (the `awk` that ships with macOS/Linux); no GNU-specific features are used.
- [GitHub CLI (`gh`)](https://cli.github.com/) — used by `make release` to publish releases.

After cloning, point git at the repo's tracked hooks so you don't accidentally commit `.wav`
files (WoW's sound API only accepts `.mp3` and `.ogg`):

```
git config core.hooksPath hooks
```

1. Add new audio files (`.wav`) to a voice pack folder — an existing one, or a brand-new
   directory to start a new pack. Adding sounds to an existing pack requires no other changes.
2. Run `make update`. This converts every `.wav` to `.mp3` (deleting the `.wav` source once
   converted), regenerates each voice pack's Lua registration table and `cfm_voice.toc`'s file
   list, and bumps the TOC patch version if anything actually changed.
3. Pull the updates in-game.

### Makefile

Run `make help` to list targets:

- `make convert` — convert every `.wav` under a voice pack folder to `.mp3`, then delete the
  source `.wav`. Pass `NO_PURGE=1` to keep the `.wav` files instead (e.g. `make convert
  NO_PURGE=1`).
- `make sounds` — `make convert`, then regenerate voice pack Lua/TOC registration
  (`scripts/update-sounds.sh`).
- `make update` — `make convert` + `make sounds`, then bump `cfm_voice.toc`'s patch version
  (`## Version: X.Y.Z` → `X.Y.(Z+1)`) if anything in `*.mp3`, `*.lua`, or the TOC actually
  changed. This is the normal workflow after adding audio.
- `make release VERSION [DRY]` — tags a release on `main`, builds a zip from that tag, and
  publishes it as a GitHub release via `gh`. `make release v1.0.0 DRY` previews the steps
  without changing anything. Requires a clean working tree on `main` and a `vX.Y.Z` version
  that isn't already tagged.
- `make version` — print the version currently set in `cfm_voice.toc`.
- `make clean` — remove the `dist/` directory (release zips built by `make release`).

Only `.mp3` files (and the generated `.lua` files) are committed — `.wav` sources are gitignored,
purged by `make convert`, and blocked from being committed by the pre-commit hook above. Since
`.wav` masters aren't kept anywhere (not in git, deleted from disk after conversion), treat the
conversion step as final — if you need to re-encode, do it before running `make convert` /
`make update`.

### Releasing

`make release vX.Y.Z` does the following, in order: sets `cfm_voice.toc`'s `## Version:` field to
match, commits that change, creates an annotated git tag `vX.Y.Z`, builds
`dist/cfm_voice-vX.Y.Z.zip` from the tagged commit (containing `cfm_voice.toc`, `CFM_Voice.lua`,
and every voice pack directory — the same folder structure WoW expects in `AddOns/`), pushes
`main` and the tag to GitHub, then publishes a GitHub release with the zip attached. Releases stay
tagged in the commit history, same as before.

## Voice Packs

### Vivian

Voice lines generated with a custom QWEN voice and the default Vivian (Chinese) voice from
VoiceBox.ai.

## A Note on AI-Generated Audio

Some or all of these files were generated using tools like VoiceBox or Qwen-TTS. If a clip sounds
like a celebrity, it's either a voice clone or a clip from a Cameo video — not the genuine
article.

## License

All rights reserved. No distribution. No modification. No use without permission — effectively
the inverse of the MIT License.
