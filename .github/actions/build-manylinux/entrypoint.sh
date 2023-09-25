#!/bin/sh -l
set -e

# setup
if [ -n "$(command -v yum)" ]
then
  yum -y update
  yum -y install bzip2-devel
elif [ -n "$(command -v apt-get)" ]
then
  apt-get -y update
  apt-get -y install libbz2-dev
else
  echo "Assuming libbz2 is installed"
fi

case "$(uname -s)" in
  Darwin*)    OPT=/usr/local;;
  *)          OPT=/opt
esac

mkdir $HOME/.codon
cd $HOME/.codon
curl -L https://github.com/exaloop/codon/releases/download/v0.16.3/codon-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz | tar zxvf - --strip-components=1
cd /
curl -L https://github.com/exaloop/llvm-project/releases/download/codon-15.0.1/llvm-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz | tar zxvf -

cd $1
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCODON_PATH=$HOME/.codon \
  -DLLVM_DIR=$OPT/llvm-codon/lib/cmake/llvm \
  -DCMAKE_C_COMPILER=$OPT/llvm-codon/bin/clang \
  -DCMAKE_CXX_COMPILER=$OPT/llvm-codon/bin/clang++
cmake --build build
CODON_PATH=$HOME/.codon/lib/codon/stdlib build/seqtest
cmake --install build --prefix=$HOME/.codon/lib/codon/plugins/seq
tar czvf seq-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz -C $HOME/.codon/lib/codon/plugins seq
echo "Done"
