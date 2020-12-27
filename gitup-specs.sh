#! /bin/zsh -y
SHUNIT_PARENT=$0
# --------------

GITUP=". $PWD/gitup.sh"

REMOTE_REPO='/tmp/gitup-test-repos/test-remote-repo'
 LOCAL_REPO='/tmp/gitup-test-repos/test-local-repo'
 LOCAL_GITUP_RC="$LOCAL_REPO/.gituprc"

MAIN_BRANCH='main'
 DEV_BRANCH='development'
TEST_BRANCH='test-branch'

# SPECS TO SKIP STEPS
# -------------------

test_skip_all_with_cli() {
  pushd $PWD
    cd $LOCAL_REPO
    $GITUP -sa -su -sm
    assertEquals 0 $?
  popd
}

test_skip_update_with_cli() {
  local called=0

  pushd $PWD
    cd $LOCAL_REPO
    echo GITUP_AFTER_UPDATE_FN=mock_run_after_update >> $LOCAL_GITUP_RC
    echo GITUP_RUN_MIGRATIONS_FN=mock_run_migrations >> $LOCAL_GITUP_RC
    cat $LOCAL_GITUP_RC
    $GITUP -su
    assertEquals 0 $?
    assertEquals 1 $mock_run_after_update_called
    assertEquals 1 $mock_run_migrations_called
  popd
}

test_skip_after_update_with_cli() {
  pushd $PWD
    cd $LOCAL_REPO
    $GITUP -sa
    assertEquals 0 $?
  popd
}

# MOCK FUNCTIONS
# --------------
mock_run_after_update() {
  mock_run_after_update_called=1
}

mock_run_migrations() {
  mock_run_migrations_called=1
}


# SETUP AND TEARDOWN
# ------------------

setUp() {
  mock_run_after_update_called=0
  mock_run_migrations_called=0
}

tearDown() {
  if [[ -f $LOCAL_GITUP_RC ]]; then
    rm $LOCAL_GITUP_RC
  fi
}

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
    echo .gituprc >> $LOCAL_REPO/.gitignore
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
