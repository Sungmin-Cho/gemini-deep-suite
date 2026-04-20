#!/usr/bin/env bash
# publish-subtree.sh — split a monorepo package and push to its mirror repo.
#
# Usage:
#   publish-subtree.sh <package-name> [git-ref]
# Example:
#   publish-subtree.sh deep-work v0.1.0
#
# Behavior:
#   1. `git subtree split -P packages/<pkg>` → ephemeral branch `publish/<pkg>`
#   2. `git push <mirror-remote> publish/<pkg>:main --force-with-lease`
#   3. If [git-ref] given, tag mirror with `<pkg>-<ref>`
#
# Mirror remote convention: `mirror-<pkg>` pointing to github.com/sungmin-cho/gemini-<pkg>.
#   Add with: git remote add mirror-deep-work git@github.com:sungmin-cho/gemini-deep-work.git
#
# Safety:
#   - Uses --force-with-lease (not --force) to avoid clobbering remote changes.
#   - Aborts if working tree is dirty (no uncommitted changes allowed).
#   - Aborts if mirror remote missing.

set -euo pipefail

PKG="${1:-}"
REF="${2:-}"

if [[ -z "$PKG" ]]; then
  echo "Usage: $0 <package-name> [git-ref]" >&2
  echo "Example: $0 deep-work v0.1.0" >&2
  exit 2
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if [[ ! -d "packages/$PKG" ]]; then
  echo "❌ packages/$PKG not found" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ working tree dirty — commit or stash before publishing" >&2
  git status --short >&2
  exit 1
fi

MIRROR_REMOTE="mirror-$PKG"
if ! git remote get-url "$MIRROR_REMOTE" >/dev/null 2>&1; then
  echo "❌ mirror remote '$MIRROR_REMOTE' missing" >&2
  echo "   Add with: git remote add $MIRROR_REMOTE git@github.com:sungmin-cho/gemini-$PKG.git" >&2
  exit 1
fi

PUBLISH_BRANCH="publish/$PKG"

echo "▶ splitting packages/$PKG → $PUBLISH_BRANCH"
git subtree split -P "packages/$PKG" -b "$PUBLISH_BRANCH" --rejoin 2>&1 | tail -5 || true

echo "▶ pushing $PUBLISH_BRANCH → $MIRROR_REMOTE:main (--force-with-lease)"
git push "$MIRROR_REMOTE" "$PUBLISH_BRANCH:main" --force-with-lease

if [[ -n "$REF" ]]; then
  TAG="$PKG-$REF"
  echo "▶ tagging $TAG on mirror"
  # Create tag on the subtree-split commit
  SPLIT_SHA="$(git rev-parse "$PUBLISH_BRANCH")"
  git push "$MIRROR_REMOTE" "$SPLIT_SHA:refs/tags/$REF"
  # Also tag locally (convention: <pkg>-<ref>)
  if ! git rev-parse "$TAG" >/dev/null 2>&1; then
    git tag -a "$TAG" "$SPLIT_SHA" -m "Publish $PKG $REF"
  fi
  git push origin "$TAG" || true
fi

echo "▶ cleanup publish branch (keep for incremental --rejoin)"
# NOTE: --rejoin mode keeps the split branch for future incremental splits.
# If you want fresh history each time, remove --rejoin and git branch -D "$PUBLISH_BRANCH".

echo "✅ published $PKG${REF:+ ($REF)} → $MIRROR_REMOTE"
