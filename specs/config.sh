LOCAL_REPO='test-local-repo'
REMOTE_REPO='test-remote-repo'

oneTimeSetUp() {
  echo "GITUP SPECS: SETUP"
  __setup_remote_repo
  __setup_local_repo
}

oneTimeTearDown() {
  echo "GITUP SPECS: TEARDOWN"

  pushd $PWD >> /dev/null
    cd specs
    rm -rdf $REMOTE_REPO
    rm -rdf $LOCAL_REPO
  popd >> /dev/null
}

__setup_remote_repo() {
  echo "GITUP SPECS: - create remote repo"
  pushd $PWD >> /dev/null
    cd specs
    mkdir $REMOTE_REPO
    cd $REMOTE_REPO
    git init .
    touch sample
    git add .
    git commit -m 'added sample commit'
  popd >> /dev/null
}

__setup_local_repo() {
  echo "GITUP SPECS: - create local repo"

  pushd $PWD >> /dev/null
    cd specs
    git clone $REMOTE_REPO $LOCAL_REPO
  popd >> /dev/null
}
