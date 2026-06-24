#!/usr/bin/env bash
set -euo pipefail

providers=(
  ".claude"
  ".cursor"
  ".github"
  ".gemini"
)

collections=(
  "skills"
  "rules"
)

sync_collection() {
  local collection="$1"
  local source_dir=".agents/$collection"

  if [[ ! -d "$source_dir" ]]; then
    echo "Missing source directory: $source_dir" >&2
    exit 1
  fi

  for provider in "${providers[@]}"; do
    mkdir -p "$provider/$collection"
  done

  for source_path in "$source_dir"/*; do
    [[ -e "$source_path" ]] || continue
    [[ "$(basename "$source_path")" != ".gitkeep" ]] || continue

    entry_name="$(basename "$source_path")"

    for provider in "${providers[@]}"; do
      link_path="$provider/$collection/$entry_name"
      target="../../.agents/$collection/$entry_name"

      if [[ -L "$link_path" ]]; then
        ln -sfn "$target" "$link_path"
      elif [[ -e "$link_path" ]]; then
        echo "Skipping existing non-symlink path: $link_path" >&2
      else
        ln -s "$target" "$link_path"
      fi
    done
  done

  # Remove stale entries in providers that no longer have a source under .agents/<collection>.
  # Handles three cases per provider entry:
  #   - dangling symlink (target deleted) -> remove
  #   - symlink pointing inside this collection but to a missing source -> remove
  #   - source no longer exists for this entry name -> remove the symlink
  # Non-symlink files/dirs are preserved with a warning so we never delete user content.
  for provider in "${providers[@]}"; do
    local provider_dir="$provider/$collection"
    [[ -d "$provider_dir" ]] || continue

    for entry in "$provider_dir"/*; do
      [[ -e "$entry" || -L "$entry" ]] || continue

      local entry_name
      entry_name="$(basename "$entry")"
      local source_path="$source_dir/$entry_name"

      if [[ -L "$entry" ]]; then
        if [[ ! -e "$source_path" ]]; then
          rm -f "$entry"
          echo "Removed stale symlink: $entry" >&2
        fi
      else
        if [[ ! -e "$source_path" ]]; then
          echo "Skipping non-symlink path with no matching source: $entry" >&2
        fi
      fi
    done
  done
}

for collection in "${collections[@]}"; do
  sync_collection "$collection"
done
