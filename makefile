.PHONY: help convert sounds update

# Default target
.DEFAULT_GOAL := help

# Variables
FFMPEG ?= ffmpeg
MP3_QUALITY ?= 2
NO_PURGE ?= 0
TOC_FILE := cfm_voice.toc
WAV_FILES := $(wildcard */*.wav)
MP3_FILES := $(WAV_FILES:.wav=.mp3)

# Help target
help:
	@echo "Makefile targets for cfm_voice:"
	@echo ""
	@echo "  make convert    Convert all .wav sources to .mp3 (ffmpeg), then delete the .wav"
	@echo "  make sounds     Convert audio and regenerate voice pack Lua/TOC registration"
	@echo "  make update     make convert + make sounds, then bump the TOC patch version"
	@echo "                  if anything changed"
	@echo "  make help       Display this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  FFMPEG=<path>        ffmpeg binary to use (default: ffmpeg)"
	@echo "  MP3_QUALITY=<0-9>    libmp3lame VBR quality, lower is better (default: 2)"
	@echo "  NO_PURGE=1           keep .wav sources after conversion instead of deleting them"

# Convert every .wav in any top-level voice pack directory to .mp3
convert: $(MP3_FILES)
	@echo "✓ Converted $(words $(MP3_FILES)) file(s) to mp3"

%.mp3: %.wav
	@echo "Converting $< -> $@..."
	@$(FFMPEG) -y -loglevel error -i $< -codec:a libmp3lame -qscale:a $(MP3_QUALITY) $@
	@echo "✓ Built: $@"
	@if [ "$(NO_PURGE)" != "1" ]; then \
		rm -f $<; \
		echo "✓ Purged: $<"; \
	fi

# Convert audio, then regenerate each voice pack's Lua table and the toc file list
sounds:
	@scripts/update-sounds.sh

# Full refresh: convert audio, regenerate registration, bump version if anything changed
update: convert sounds
	@if [ -n "$$(git -c core.fileMode=false status --porcelain -- '*.mp3' '*.lua' $(TOC_FILE))" ]; then \
		echo "Changes detected, bumping version..."; \
		awk ' \
			/^## Version:/ { \
				split($$0, kv, ": "); \
				split(kv[2], v, "."); \
				v[3] = v[3] + 1; \
				printf "## Version: %s.%s.%s\n", v[1], v[2], v[3]; \
				next; \
			} \
			{ print } \
		' $(TOC_FILE) > $(TOC_FILE).tmp && mv $(TOC_FILE).tmp $(TOC_FILE); \
		echo "✓ $$(grep '^## Version:' $(TOC_FILE))"; \
	else \
		echo "No changes detected; version not bumped."; \
	fi
