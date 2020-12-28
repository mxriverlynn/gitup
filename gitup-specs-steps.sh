# SPECS TO RUN AND SKIP STEPS
# ---------------------------

test_run_full_gitup() {
  pushd $PWD
    cd $LOCAL_REPO

    $GITUP
    assertEquals 0 $?
    assertEquals 1 $mock_git_update_called
    assertEquals 1 $mock_install_dependencies_called
    assertEquals 1 $mock_migrations_called
  popd
}

test_skip_all_with_cli() {
  pushd $PWD
    cd $LOCAL_REPO

    $GITUP -sa -su -sm
    assertEquals 0 $?
    assertEquals 0 $mock_git_update_called
    assertEquals 0 $mock_install_dependencies_called
    assertEquals 0 $mock_migrations_called
  popd
}

test_skip_update_with_cli() {
  local called=0

  pushd $PWD
    cd $LOCAL_REPO

    $GITUP -su
    assertEquals 0 $?
    assertEquals 0 $mock_git_update_called
    assertEquals 1 $mock_install_dependencies_called
    assertEquals 1 $mock_migrations_called
  popd
}

test_skip_install_dependencies_with_cli() {
  pushd $PWD
    cd $LOCAL_REPO

    $GITUP -sa
    assertEquals 0 $?
    assertEquals 1 $mock_git_update_called
    assertEquals 0 $mock_install_dependencies_called
    assertEquals 1 $mock_migrations_called
  popd
}

test_skip_migrations_with_cli() {
  pushd $PWD
    cd $LOCAL_REPO

    $GITUP -sm

    assertEquals 0 $?
    assertEquals 1 $mock_git_update_called
    assertEquals 1 $mock_install_dependencies_called
    assertEquals 0 $mock_migrations_called
  popd
}

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
  echo GITUP_GIT_UPDATE_FN=mock_git_update >> $GITUP_RC
  echo GITUP_INSTALL_DEPENDENCIES_FN=mock_install_dependencies >> $GITUP_RC
  echo GITUP_RUN_MIGRATIONS_FN=mock_migrations >> $GITUP_RC

  mock_git_update_called=0
  mock_install_dependencies_called=0
  mock_migrations_called=0
}

tearDown() {
  if [[ -f $GITUP_RC ]]; then
    rm $GITUP_RC
  fi
}
