#!/bin/bash
# Run manually on the login node — NOT via sbatch.
set -euo pipefail

EAGLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tools/eagle" && pwd)"

git clone https://github.com/tony-kuo/eagle.git "$EAGLE_DIR/_src"
mv "$EAGLE_DIR/_src"/* "$EAGLE_DIR/"
mv "$EAGLE_DIR/_src"/.git "$EAGLE_DIR/"   # keep the .git for reference if you want, or drop this line
rmdir "$EAGLE_DIR/_src"

git clone https://github.com/samtools/htslib.git "$EAGLE_DIR/htslib"
(cd "$EAGLE_DIR/htslib" && git submodule update --init --recursive)

make -C "$EAGLE_DIR"

echo "EAGLE-RC built at $EAGLE_DIR/eagle-rc"