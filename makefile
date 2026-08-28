.PHONY: help convert sounds update release version clean

# Default target
.DEFAULT_GOAL := help

# Variables
FFMPEG ?= ffmpeg
MP3_QUALITY ?= 2
NO_PURGE ?= 0
TOC_FILE := cfm_voice.toc
DIST_DIR := dist
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
	@echo "  make release VERSION [DRY]"
	@echo "                  Tag a release, build a zip, and publish it to GitHub"
	@echo "  make version    Print the version currently set in the TOC"
	@echo "  make clean      Remove the dist/ directory"
	@echo "  make help       Display this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  FFMPEG=<path>        ffmpeg binary to use (default: ffmpeg)"
	@echo "  MP3_QUALITY=<0-9>    libmp3lame VBR quality, lower is better (default: 2)"
	@echo "  NO_PURGE=1           keep .wav sources after conversion instead of deleting them"
	@echo ""
	@echo "Examples:"
	@echo "  make release v1.0.0        Tag, build, and publish v1.0.0"
	@echo "  make release v1.0.0 DRY    Preview what would happen"

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

# Tag a release on main, build a zip from the tag, and publish it to GitHub.
# Voice pack directories are discovered the same way as scripts/update-sounds.sh
# (top-level dirs, excluding .git/hooks/scripts/dist and dotfiles, containing *.mp3).
release:
	@bash -c 'VERSION="$(word 2,$(MAKECMDGOALS))"; \
	DRY_RUN="$(word 3,$(MAKECMDGOALS))"; \
	if [ -z "$$VERSION" ] || [ "$$VERSION" = "release" ]; then \
		echo "ERROR: No version provided"; \
		echo "Usage: make release VERSION [DRY]"; \
		echo "Examples:"; \
		echo "  make release v1.0.0"; \
		echo "  make release v1.0.0 DRY"; \
		exit 1; \
	fi; \
	if ! echo "$$VERSION" | grep -qE "^v[0-9]+\.[0-9]+\.[0-9]+$$"; then \
		echo "ERROR: Invalid version format: $$VERSION"; \
		echo "Must be semantic versioning format: vX.Y.Z (e.g., v1.0.0)"; \
		exit 1; \
	fi; \
	if ! command -v gh >/dev/null 2>&1; then \
		echo "ERROR: GitHub CLI not found"; \
		echo "Install from: https://cli.github.com"; \
		exit 1; \
	fi; \
	BRANCH="$$(git branch --show-current)"; \
	if [ "$$BRANCH" != "main" ]; then \
		echo "ERROR: Must release from main (currently on $$BRANCH)"; \
		exit 1; \
	fi; \
	if [ -n "$$(git status --porcelain)" ]; then \
		echo "ERROR: Working tree is not clean; commit or stash changes first"; \
		exit 1; \
	fi; \
	if git rev-parse -q --verify "refs/tags/$$VERSION" >/dev/null 2>&1; then \
		echo "ERROR: Tag $$VERSION already exists"; \
		echo "To see existing tags, run: git tag -l"; \
		exit 1; \
	fi; \
	TOC_VERSION="$${VERSION#v}"; \
	ZIP="$(DIST_DIR)/cfm_voice-$$VERSION.zip"; \
	PACK_DIRS=""; \
	for entry in */; do \
		d="$${entry%/}"; \
		case "$$d" in .git|hooks|scripts|$(DIST_DIR)|.*) continue ;; esac; \
		if ls "$$d"/*.mp3 >/dev/null 2>&1; then PACK_DIRS="$$PACK_DIRS $$d"; fi; \
	done; \
	if [ "$$DRY_RUN" = "DRY" ]; then \
		echo "DRY-RUN MODE (no changes will be made)"; \
		echo ""; \
		echo "Release: $$VERSION"; \
		echo "TOC version field would become: $$TOC_VERSION"; \
		echo "Voice packs to include:$$PACK_DIRS"; \
		echo ""; \
		echo "Would perform:"; \
		echo "  1. Set cfm_voice.toc Version to $$TOC_VERSION"; \
		echo "  2. Commit: Release $$VERSION"; \
		echo "  3. Tag $$VERSION"; \
		echo "  4. Build $$ZIP from the tag"; \
		echo "  5. Push main and the tag to origin"; \
		echo "  6. gh release create $$VERSION $$ZIP"; \
		echo ""; \
		echo "To execute, run: make release $$VERSION"; \
	else \
		echo "Releasing $$VERSION..."; \
		echo ""; \
		echo "Step 1/6: Setting $(TOC_FILE) Version to $$TOC_VERSION..."; \
		sed -i.bak "s/^## Version: .*/## Version: $$TOC_VERSION/" $(TOC_FILE) || { echo "ERROR: Failed to update $(TOC_FILE)"; exit 1; }; \
		rm -f $(TOC_FILE).bak; \
		echo "✓ Updated $(TOC_FILE)"; \
		echo ""; \
		echo "Step 2/6: Committing release..."; \
		git add $(TOC_FILE); \
		git commit -m "Release $$VERSION" >/dev/null || { echo "ERROR: Failed to commit"; exit 1; }; \
		echo "✓ Committed"; \
		echo ""; \
		echo "Step 3/6: Tagging $$VERSION..."; \
		git tag -a "$$VERSION" -m "Release $$VERSION" || { echo "ERROR: Failed to create tag"; exit 1; }; \
		echo "✓ Tagged $$VERSION"; \
		echo ""; \
		echo "Step 4/6: Building $$ZIP..."; \
		mkdir -p $(DIST_DIR); \
		git archive --prefix=cfm_voice/ -o "$$ZIP" "$$VERSION" -- $(TOC_FILE) CFM_Voice.lua $$PACK_DIRS || { echo "ERROR: Failed to build zip"; exit 1; }; \
		echo "✓ Built $$ZIP"; \
		echo ""; \
		echo "Step 5/6: Pushing to origin..."; \
		git push origin main || { echo "ERROR: Failed to push main"; exit 1; }; \
		git push origin "$$VERSION" || { echo "ERROR: Failed to push tag"; exit 1; }; \
		echo "✓ Pushed main and $$VERSION"; \
		echo ""; \
		echo "Step 6/6: Creating GitHub release..."; \
		gh release create "$$VERSION" "$$ZIP" --title "$$VERSION" --generate-notes || { echo "ERROR: Failed to create GitHub release"; exit 1; }; \
		echo ""; \
		echo "✓ Released $$VERSION"; \
	fi'
	@true

# Print the version currently set in the TOC
version:
	@awk -F': ' '/^## Version:/ { print $$2 }' $(TOC_FILE)

# Remove build output
clean:
	@rm -rf $(DIST_DIR)
	@echo "✓ Removed $(DIST_DIR)"

# Catch-all so extra words after a target (e.g. "v1.0.0", "DRY") are treated as
# arguments, not unknown make targets
%:
	@true
