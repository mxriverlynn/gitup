# GLOBAL SPEC SETUP AND TEARDOWN
# ------------------------------

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

__setup_remote_repo
__setup_local_repo
