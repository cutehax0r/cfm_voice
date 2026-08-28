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

1. Add new audio files to the appropriate voice pack folder.
2. Reference them from the Lua file that registers media with LibSharedMedia.
3. Bump the version in `cfm_voice.toc`.
4. Pull the updates in-game.

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
