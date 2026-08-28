.PHONY: help convert clean

# Default target
.DEFAULT_GOAL := help

# Variables
FFMPEG ?= ffmpeg
MP3_QUALITY ?= 2
VOICE_DIRS := vivian
WAV_FILES := $(wildcard $(addsuffix /*.wav,$(VOICE_DIRS)))
MP3_FILES := $(WAV_FILES:.wav=.mp3)

# Help target
help:
	@echo "Makefile targets for cfm_voice:"
	@echo ""
	@echo "  make convert    Convert all .wav sources to .mp3 (ffmpeg)"
	@echo "  make clean      Remove generated .mp3 files"
	@echo "  make help       Display this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  FFMPEG=<path>        ffmpeg binary to use (default: ffmpeg)"
	@echo "  MP3_QUALITY=<0-9>    libmp3lame VBR quality, lower is better (default: 2)"

# Convert every .wav in VOICE_DIRS to .mp3
convert: $(MP3_FILES)
	@echo "✓ Converted $(words $(MP3_FILES)) file(s) to mp3"

%.mp3: %.wav
	@echo "Converting $< -> $@..."
	@$(FFMPEG) -y -loglevel error -i $< -codec:a libmp3lame -qscale:a $(MP3_QUALITY) $@
	@echo "✓ Built: $@"

# Clean target
clean:
	@echo "Removing generated mp3 files..."
	@rm -f $(MP3_FILES)
	@echo "✓ Clean complete"
