#!/bin/sh
source ./gitup-specs.config.sh

testSkipAll() {
  ./gitup.sh -su -sa -sm
}

testRunAll() {
  pushd $PWD
    cd 
    ./gitup.sh
  popd
}

. ./shunit2/shunit2
