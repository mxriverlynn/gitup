#! /bin/sh
# --------

GITUP=". $PWD/gitup.sh"

REMOTE_REPO='/tmp/gitup-test-repos/test-remote-repo'
 LOCAL_REPO='/tmp/gitup-test-repos/test-local-repo'
 LOCAL_GITUP_RC="$LOCAL_REPO/.gituprc"

MAIN_BRANCH='main'
 DEV_BRANCH='development'
TEST_BRANCH='test-branch'

# SPECS TO SKIP STEPS
# -------------------

test_run_full_gitup() (
  cd $LOCAL_REPO

  $GITUP
  assertEquals 0 $?
  assertEquals 1 $mock_git_update_called
  assertEquals 1 $mock_install_dependencies_called
  assertEquals 1 $mock_migrations_called
)

test_skip_all_with_cli() (
  cd $LOCAL_REPO

  $GITUP -sa -su -sm
  assertEquals 0 $?
  assertEquals 0 $mock_git_update_called
  assertEquals 0 $mock_install_dependencies_called
  assertEquals 0 $mock_migrations_called
)

test_skip_update_with_cli() (
  cd $LOCAL_REPO

  $GITUP -su
  assertEquals 0 $?
  assertEquals 0 $mock_git_update_called
  assertEquals 1 $mock_install_dependencies_called
  assertEquals 1 $mock_migrations_called
)

test_skip_install_dependencies_with_cli() (
  cd $LOCAL_REPO

  $GITUP -sa
  assertEquals 0 $?
  assertEquals 1 $mock_git_update_called
  assertEquals 0 $mock_install_dependencies_called
  assertEquals 1 $mock_migrations_called
)

test_skip_migrations_with_cli() (
  cd $LOCAL_REPO

  $GITUP -sm

  assertEquals 0 $?
  assertEquals 1 $mock_git_update_called
  assertEquals 1 $mock_install_dependencies_called
  assertEquals 0 $mock_migrations_called
)

# MOCK FUNCTIONS
# --------------
mock_git_update() {
  mock_git_update_called=1
}

mock_install_dependencies() {
  mock_install_dependencies_called=1
}

mock_migrations() {
  mock_migrations_called=1
}


# SETUP AND TEARDOWN
# ------------------

setUp() {
  echo GITUP_GIT_UPDATE_FN=mock_git_update >> $LOCAL_GITUP_RC
  echo GITUP_INSTALL_DEPENDENCIES_FN=mock_install_dependencies >> $LOCAL_GITUP_RC
  echo GITUP_RUN_MIGRATIONS_FN=mock_migrations >> $LOCAL_GITUP_RC

  mock_git_update_called=0
  mock_install_dependencies_called=0
  mock_migrations_called=0
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

__setup_remote_repo() (
  mkdir -p $REMOTE_REPO
  cd $REMOTE_REPO
  git init --bare
)

__setup_local_repo() (
  git clone $REMOTE_REPO $LOCAL_REPO
  cd $LOCAL_REPO

  git checkout -b $MAIN_BRANCH
  echo .gituprc >> $LOCAL_REPO/.gitignore
  touch 'main_sample'
  git add .
  git commit -m 'added sample commit'
  git push origin $MAIN_BRANCH

  git checkout -b $DEV_BRANCH
  touch 'dev_sample'
  git add .
  git commit -m 'added development commit'
  git push origin $DEV_BRANCH
)

source ./shunit2/shunit2
