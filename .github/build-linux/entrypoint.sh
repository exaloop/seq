#!/bin/sh -l
set -e
set -x

WORKSPACE="${1:-/github/workspace}"

export ARCHDEFAULT="$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
ARCH=${2:-$ARCHDEFAULT}

TEST=${3:-no}
CODON_VERSION=${4:-0.19.1}

echo "Workspace: ${WORKSPACE}; arch: ${ARCH}"
cd "$WORKSPACE"

curl -L https://github.com/exaloop/codon/releases/download/v${CODON_VERSION}/codon-${ARCH}.tar.gz | tar zxvf -
export CODON_DIR=$(pwd)/codon-deploy-${ARCH}

# Build Seq
cmake -S . -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCODON_PATH=${CODON_DIR} \
  -DCMAKE_C_COMPILER=/opt/llvm-codon/bin/clang \
  -DCMAKE_CXX_COMPILER=/opt/llvm-codon/bin/clang++
cmake --build build
cmake --install build --prefix=${CODON_DIR}/lib/codon/plugins/seq

# Test
if [ "$TEST" = "yes" ]; then
  CODON_PATH=${CODON_DIR}/lib/codon/stdlib build/seqtest
fi

# Package
export BUILD_ARCHIVE=seq-${ARCH}.tar.gz
tar czf ${BUILD_ARCHIVE} -C ${CODON_DIR}/lib/codon/plugins seq/
du -sh ${BUILD_ARCHIVE}
