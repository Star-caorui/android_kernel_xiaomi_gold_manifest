#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#
# fetch-gki.sh <ci.android.com build id> <dir>: put one of Google's GKI builds into <dir>/<build id>: its kernel
# image, its symbol versions, and the GKI modules its system_dlkm loads (its modules.load), with their index
# files; and in <dir>/<build id>/kleaf the files Kleaf takes a prebuilt GKI build from, the ones the build's
# ci_target_mapping.json names (prebuilt-gki/MODULE.bazel.in points Kleaf there). build_mgk_64_k66.sh runs it.
#
# The build id is the one android15-6.6's release builds page links to. Everything is taken unchanged from that
# build, once the downloads match their SHA-256 in gki.sha256, as stock takes it: stock's system_dlkm loads what
# its GKI build's modules.load lists, in that order. For a build gki.sha256 does not list, it prints the
# lines to put there and stops. Needs curl, sha256sum and python3 on the host.
set -euo pipefail

id=$1
kdir=$2
sums=$(dirname -- "$0")/gki.sha256
url=https://ci.android.com/builds/submitted/$id/kernel_aarch64/latest/raw
out=$kdir/$id


work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# check <file> <name>: the download has the SHA-256 gki.sha256 has for <name> of this build
unlisted=
check() {
    local sum want
    sum=$(sha256sum "$1" | cut -d' ' -f1)
    want=$(awk -v id="$id" -v f="$2" '$1 == id && $3 == f { print $2 }' "$sums")
    if [ -z "$want" ]; then
        echo "$id $sum $2"
        unlisted=1
    elif [ "$sum" != "$want" ]; then
        echo "$2 of build $id does not match gki.sha256" >&2
        exit 1
    fi
}

# the symbol versions the vendor modules are checked against; the rest comes with Kleaf's files
curl -fsSL --retry 3 -o "$work/kernel_aarch64_Module.symvers" "$url/kernel_aarch64_Module.symvers"
check "$work/kernel_aarch64_Module.symvers" kernel_aarch64_Module.symvers

k=$work/kleaf
mkdir "$k"
curl -fsSL --retry 3 -o "$k/ci_target_mapping.json" "$url/ci_target_mapping.json"
check "$k/ci_target_mapping.json" ci_target_mapping.json
# <local name> <remote name> <mandatory>, as Kleaf's kernel_prebuilt_repo reads the mapping
python3 -I - "$id" "$k/ci_target_mapping.json" > "$work/kleaf.list" <<'EOF'
import json, sys
build, mapping = sys.argv[1:]
for local, c in sorted(json.load(open(mapping))["download_configs"].items()):
    print(local, c["remote_filename_fmt"].format(build_number=build), int(c["mandatory"]))
EOF
while read -r local remote mandatory; do
    mkdir -p "$(dirname "$k/$local")"
    if [ "$mandatory" = 1 ]; then
        curl -fsSL --retry 3 -o "$k/$local" "$url/$remote"
    elif ! curl -fsSL --retry 3 -o "$k/$local" "$url/$remote" 2> /dev/null; then
        rm -f "$k/$local"
        echo "not in build $id, which Kleaf does not need: $remote"
        continue
    fi
    check "$k/$local" "$local"
done < "$work/kleaf.list"
if [ -n "$unlisted" ]; then
    echo "gki.sha256 does not list the files above of build $id; these are their lines" >&2
    exit 1
fi
mkdir "$work/sd"
tar -xzf "$k/system_dlkm_staging_archive.tar.gz" -C "$work/sd"

rm -rf "$out"
mkdir -p "$out/system_dlkm/lib/modules"
cp "$k/Image.gz" "$out/kernel"
cp "$work/kernel_aarch64_Module.symvers" "$out/"

python3 - "$id" "$k/Image.gz" "$work/sd/flatten/lib/modules" "$out/system_dlkm/lib/modules" <<'EOF'
import gzip, os, re, shutil, sys

build, image, src, out = sys.argv[1:]

# The image has to be the 4k-page GKI kernel of this build.
banner = re.search(rb"Linux version (\S+)", gzip.open(image).read()).group(1).decode()
if not banner.endswith("-ab%s-4k" % build):
    sys.exit("%s is not the 4k GKI kernel of build %s" % (banner, build))

# The build's own load list, in its order; the staging archive has more modules than system_dlkm loads.
mods = [os.path.basename(m.strip()) for m in open(os.path.join(src, "modules.load")) if m.strip()]
missing = [m for m in mods if not os.path.isfile(os.path.join(src, m))]
if missing:
    sys.exit("modules.load names what the build does not have: " + " ".join(missing))
keep = set(mods)

for m in keep:
    shutil.copy2(os.path.join(src, m), out)
open(os.path.join(out, "modules.load"), "w").write("".join(m + "\n" for m in mods))

name = lambda line: os.path.basename(line.split(":")[0].strip())
dep = [l for l in open(os.path.join(src, "modules.dep")) if name(l) in keep]
for l in dep:
    for d in l.split(":", 1)[1].split():
        if os.path.basename(d) not in keep:
            sys.exit("%s needs %s, which modules.load does not list" % (name(l), os.path.basename(d)))
open(os.path.join(out, "modules.dep"), "w").write("".join(dep))

names = {m[:-3].replace("-", "_") for m in keep}
alias = [l for l in open(os.path.join(src, "modules.alias"))
         if l.startswith("#") or l.split()[-1] in names]
open(os.path.join(out, "modules.alias"), "w").write("".join(alias))
open(os.path.join(out, "modules.softdep"), "w").write(
    "# Soft dependencies extracted from modules themselves.\n")

print("%s: %d modules" % (banner, len(keep)))
EOF
mv "$k" "$out/kleaf"
