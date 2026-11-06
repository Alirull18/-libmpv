#!/bin/bash
# Records where every source tree used by the build came from, and archives the trees themselves.
#
# Usage: archive-sources.sh <src_packages directory> <output directory>
#
# Writes into the output directory:
#   SOURCES.txt                              name | git remote | commit, one line per source tree
#   kayro-libmpv-sources.tar.xz.part-NN      the source trees, version-control data excluded,
#                                            split so each file fits a GitHub release asset
# Rebuild the archive with:  cat kayro-libmpv-sources.tar.xz.part-* > kayro-libmpv-sources.tar.xz
set -euo pipefail

src=${1:?source directory}
out=${2:?output directory}
mkdir -p "$out"

{
  echo "# Corresponding source for this libmpv build."
  echo "# Rebuild the archive with: cat kayro-libmpv-sources.tar.xz.part-* > kayro-libmpv-sources.tar.xz"
  echo "# name | git remote | commit"
  for d in "$src"/*/; do
    n=$(basename "$d")
    # A tree is its own checkout only when it holds a .git entry; otherwise git would walk up to a parent repository.
    if [ -e "$d/.git" ]; then
      url=$(git -C "$d" config --get remote.origin.url || echo unknown)
      sha=$(git -C "$d" rev-parse HEAD)
      echo "$n | $url | $sha"
    else
      echo "$n | (not a git checkout, archived as extracted) | -"
    fi
  done
} > "$out/SOURCES.txt"

# Working trees without .git, so patched files and checked-out submodules are included as built.
tar -C "$src" --exclude='.git' -cf - . | xz -T0 -6 | split -b 1900m -d - "$out/kayro-libmpv-sources.tar.xz.part-"

ls -l "$out"
