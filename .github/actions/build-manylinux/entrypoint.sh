#!/bin/sh -l
set -e

# setup
TEST=1
if [ -n "$(command -v yum)" ]
then
  yum -y update
  yum -y install bzip2-devel
elif [ -n "$(command -v apt-get)" ]
then
  TEST=0
  apt-get -y update
  apt-get -y install libbz2-dev
else
  echo "Assuming libbz2 is installed"
fi

mkdir $HOME/.codon
cd $HOME/.codon
if [[ $OSTYPE == 'darwin'* ]];
then
curl -L https://github.com/exaloop/codon/releases/download/v0.18.2/codon-$(uname -s | awk '{print tolower($0)}')-arm64.tar.gz | tar zxvf - --strip-components=1
else
curl -L https://github.com/exaloop/codon/releases/download/v0.18.2/codon-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz | tar zxvf - --strip-components=1
fi
cd /opt
curl -L https://github.com/exaloop/llvm-project/releases/download/codon-17.0.6/llvm-codon-17.0.6-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz | tar zxvf -

cd $1
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCODON_PATH=$HOME/.codon \
  -DLLVM_DIR=/opt/llvm-codon/lib/cmake/llvm \
  -DCMAKE_C_COMPILER=/opt/llvm-codon/bin/clang \
  -DCMAKE_CXX_COMPILER=/opt/llvm-codon/bin/clang++
if [ $TEST -eq 1 ]
then
  cmake --build build
  CODON_PATH=$HOME/.codon/lib/codon/stdlib build/seqtest
else
  cmake --build build --target seq
  cmake --build build --target seq_static
fi
cmake --install build --prefix=$HOME/.codon/lib/codon/plugins/seq
tar czvf seq-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz -C $HOME/.codon/lib/codon/plugins seq
echo "Done"
