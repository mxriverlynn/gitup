#!/bin/sh

# SCRIPT VARS TO USE
# ------------------
GITUP=". $PWD/gitup.sh"
LOCAL_REPO='/tmp/gitup-test-repos/test-local-repo'
REMOTE_REPO='/tmp/gitup-test-repos/test-remote-repo'
MAIN_BRANCH='main'
DEV_BRANCH='development'
TEST_BRANCH='test-branch'

# SPECS
# -----

testSkipAll() {
  $GITUP -su -sa -sm
}

testRunAll() {
  $GITUP -sa
}

# SETUP AND TEARDOWN
# ------------------

oneTimeSetUp() {
  echo "GITUP SPECS: SETUP"
  __setup_remote_repo
  __setup_local_repo
}

oneTimeTearDown() {
  echo "GITUP SPECS: TEARDOWN"
  rm -rdf $REMOTE_REPO
  rm -rdf $LOCAL_REPO
}

__setup_remote_repo() {
  echo "GITUP SPECS: - create remote repo"
  pushd $PWD
    mkdir -p $REMOTE_REPO
    cd $REMOTE_REPO

    git init --bare
  popd
}

__setup_local_repo() {
  echo "GITUP SPECS: - create local repo"
  git clone $REMOTE_REPO $LOCAL_REPO

  pushd $PWD
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

setUp() {
  pushd $PWD
  cd $LOCAL_REPO
  git checkout -b $TEST_BRANCH origin/$DEV_BRANCH
  echo
  echo "RUNNING SPEC"
  echo "------------"
}

tearDown() {
  cd $LOCAL_REPO
  git reset --hard
  git checkout $DEV_BRANCH
  git branch -D $TEST_BRANCH
  popd
  echo "-------"
  echo
}

. ./shunit2/shunit2
