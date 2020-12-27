#!/bin/sh

GITUP=". $PWD/gitup.sh"
REMOTE_REPO='/tmp/gitup-test-repos/test-remote-repo'
LOCAL_REPO='/tmp/gitup-test-repos/test-local-repo'
MAIN_BRANCH='main'
DEV_BRANCH='development'
TEST_BRANCH='test-branch'

# SPECS
# -----

testSkipAll() {
  pushd $PWD
    cd $LOCAL_REPO
    $GITUP -sa -su -sm
    assertEquals 0 $?
  popd
}

testSkipAfterUpdate() {
  pushd $PWD
    cd $LOCAL_REPO
    $GITUP -sa
    assertEquals 0 $?
  popd
}

# SETUP AND TEARDOWN
# ------------------

oneTimeSetUp() {
  __setup_remote_repo
  __setup_local_repo
}

oneTimeTearDown() {
  rm -rdf $REMOTE_REPO
  rm -rdf $LOCAL_REPO
}

__setup_remote_repo() {
  pushd $PWD
    mkdir -p $REMOTE_REPO
    cd $REMOTE_REPO
    git init --bare
  popd
}

__setup_local_repo() {
  pushd $PWD
    git clone $REMOTE_REPO $LOCAL_REPO
    cd $LOCAL_REPO

    git checkout -b $MAIN_BRANCH
    touch main_sample
    git add .
    git commit -m 'added sample commit'
    git push origin $MAIN_BRANCH

    git checkout -b $DEV_BRANCH
    touch dev_sample
    git add .
    git commit -m 'added development commit'
    git push origin $DEV_BRANCH
  popd
}

. ./shunit2/shunit2
