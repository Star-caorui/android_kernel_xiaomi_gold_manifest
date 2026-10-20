#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#
# fetch-gki.sh <ci.android.com build id> <dir>: put one of Google's GKI builds into <dir>/<build id>: its kernel
# image, its symbol versions, and the GKI modules stock's system_dlkm has (gki/modules.load.system_dlkm), with
# their index files. build_mgk_64_k66.sh runs it.
#
# The build id is the one android15-6.6's release builds page links to. Everything is taken unchanged from that
# build, once the downloads match their SHA-256 in gki.sha256; modules stock has that the build no longer has are
# left out and named. For a build gki.sha256 does not list, the lines to add are printed. Needs curl, sha256sum and
# python3 on the host.
set -euo pipefail

id=$1
kdir=$2
sums=$(dirname -- "$0")/gki.sha256
list=$(dirname -- "$0")/gki/modules.load.system_dlkm
url=https://ci.android.com/builds/submitted/$id/kernel_aarch64/latest/raw
out=$kdir/$id


work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
for f in Image.gz kernel_aarch64_Module.symvers system_dlkm_staging_archive.tar.gz; do
    curl -fsSL -o "$work/$f" "$url/$f"
    sum=$(sha256sum "$work/$f" | cut -d' ' -f1)
    want=$(awk -v id="$id" -v f="$f" '$1 == id && $3 == f { print $2 }' "$sums")
    if [ -z "$want" ]; then
        echo "not in gki.sha256: $id $sum $f"
    elif [ "$sum" != "$want" ]; then
        echo "$f of build $id does not match gki.sha256" >&2
        exit 1
    fi
done
mkdir "$work/sd"
tar -xzf "$work/system_dlkm_staging_archive.tar.gz" -C "$work/sd"

rm -rf "$out"
mkdir -p "$out/system_dlkm/lib/modules"
cp "$work/Image.gz" "$out/kernel"
cp "$work/kernel_aarch64_Module.symvers" "$out/"

python3 - "$id" "$work/Image.gz" "$work/sd/flatten/lib/modules" \
    "$list" "$out/system_dlkm/lib/modules" <<'EOF'
import gzip, os, re, shutil, sys

build, image, src, stock_load, out = sys.argv[1:]

# The image has to be the 4k-page GKI kernel of this build.
banner = re.search(rb"Linux version (\S+)", gzip.open(image).read()).group(1).decode()
if not banner.endswith("-ab%s-4k" % build):
    sys.exit("%s is not the 4k GKI kernel of build %s" % (banner, build))

# Stock's load list, in its order, without what this build does not ship.
stock = [m.strip() for m in open(stock_load) if m.strip()]
gone = sorted({m for m in stock if not os.path.exists(os.path.join(src, m))})
mods = [m for m in stock if m not in gone]
keep = set(mods)

for m in keep:
    shutil.copy2(os.path.join(src, m), out)
open(os.path.join(out, "modules.load"), "w").write("".join(m + "\n" for m in mods))

name = lambda line: os.path.basename(line.split(":")[0].strip())
dep = [l for l in open(os.path.join(src, "modules.dep")) if name(l) in keep]
for l in dep:
    for d in l.split(":", 1)[1].split():
        if os.path.basename(d) not in keep:
            sys.exit("%s needs %s, which stock does not load" % (name(l), os.path.basename(d)))
open(os.path.join(out, "modules.dep"), "w").write("".join(dep))

names = {m[:-3].replace("-", "_") for m in keep}
alias = [l for l in open(os.path.join(src, "modules.alias"))
         if l.startswith("#") or l.split()[-1] in names]
open(os.path.join(out, "modules.alias"), "w").write("".join(alias))
open(os.path.join(out, "modules.softdep"), "w").write(
    "# Soft dependencies extracted from modules themselves.\n")

print("%s: %d modules" % (banner, len(keep)))
if gone:
    print("not in this build, left out: " + " ".join(gone))
EOF
