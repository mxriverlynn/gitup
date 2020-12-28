#! /bin/sh
# --------

GITUP=". $PWD/gitup.sh"

REMOTE_REPO="$SHUNIT_TMPDIR/gitup-test-repos/test-remote-repo"
 LOCAL_REPO="$SHUNIT_TMPDIR/tmp/gitup-test-repos/test-local-repo"

GITUP_RC="$LOCAL_REPO/.gituprc"

MAIN_BRANCH='main'
 DEV_BRANCH='development'
TEST_BRANCH='test-branch'

__run_specs() {
  SHUNIT_PARENT=$1
  source ./shunit2/shunit2
}

source ./gitup-specs-setup.sh

# RUN SPECS
# ---------

__run_specs ./gitup-specs-steps.sh
