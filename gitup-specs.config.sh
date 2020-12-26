LOCAL_REPO='test-repos/test-local-repo'
REMOTE_REPO='test-repos/test-remote-repo'

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
  pushd $PWD >> /dev/null
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
  git clone $REMOTE_REPO $LOCAL_REPO
}
