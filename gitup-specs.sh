#!/bin/sh
source ./gitup-specs.config.sh

TEST_BRANCH='test-branch'

setUp() {
  pushd $PWD
  cd $LOCAL_BRANCH
  git checkout -b $TEST_BRANCH origin/$DEV_BRANCH
}

tearDown() {
  cd $LOCAL_REPO
  git reset --hard
  git checkout $DEV_BRANCH
  git branch -D $TEST_BRANCH
  popd
}

testSkipAll() {
  $GITUP -su -sa -sm
}

testRunAll() {
  $GITUP
}

. ./shunit2/shunit2
