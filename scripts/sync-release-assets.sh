#!/usr/bin/env bash
set -euo pipefail
: "${GH_TOKEN:?GH_TOKEN is required}"
repo="${GITHUB_REPOSITORY:-KUAILESHANGWEI/argosbx}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# Keep upstream references here, solely as synchronization sources.
upstream=yonggekkk/argosbx
tag=$(gh api "repos/$upstream/releases/latest" --jq .tag_name)
gh release download "$tag" -R "$upstream" -D "$tmp/upstream"
if ! gh release view "$tag" -R "$repo" >/dev/null 2>&1; then
  gh release create "$tag" -R "$repo" --title "$tag" --notes "Assets mirrored from the upstream release."
fi
gh release upload "$tag" -R "$repo" "$tmp"/upstream/* --clobber
# Runtime URLs use the stable argosbx release even if the upstream tag changes.
if [ "$tag" != argosbx ]; then
  if ! gh release view argosbx -R "$repo" >/dev/null 2>&1; then
    gh release create argosbx -R "$repo" --title argosbx --notes "Stable runtime asset mirror." --latest=false
  fi
  gh release upload argosbx -R "$repo" "$tmp"/upstream/* --clobber
fi
mkdir -p "$tmp/deps"
for arch in amd64 arm64; do
  curl -fL --retry 3 "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$arch" -o "$tmp/deps/cloudflared-linux-$arch"
done
curl -fL --retry 3 'https://github.com/cloudfoundry/cli/releases/download/v8.16.0/cf8-cli_8.16.0_linux_x86-64.tgz' -o "$tmp/deps/cf8-cli_8.16.0_linux_x86-64.tgz"
curl -fL --retry 3 'https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh' -o "$tmp/deps/acme.sh"
for kind in geosite geoip; do
  curl -fL --retry 3 "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/$kind/cn.srs" -o "$tmp/deps/$kind-cn.srs"
done
if ! gh release view dependencies -R "$repo" >/dev/null 2>&1; then
  gh release create dependencies -R "$repo" --title 'Runtime dependencies' --notes 'Mirrored runtime dependencies.' --latest=false
fi
gh release upload dependencies -R "$repo" "$tmp"/deps/* --clobber
