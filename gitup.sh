#! /bin/bash

GITUP_VERSION="1.1.0"

function gitup {
  # set defaults for all options
  GITUP_MERGE_COMMAND=rebase
  GITUP_BRANCH_NAME=development
  GITUP_REMOTE_NAME=origin
  GITUP_SKIP_UPDATE=0
  GITUP_SKIP_MIGRATIONS=0
  GITUP_INSTALL_DEPENDENCIES_FN=__gitup_install_dependencies
  GITUP_RUN_MIGRATIONS_FN=__gitup_migrations

  # load user level settings as overrides
  local user_config_file="$(echo ~/.gituprc)"
  if [ -f $user_config_file ]; then
    . $user_config_file
  fi

  # load local dir settings as overrides
  local local_config_file="$(echo $PWD/.gituprc)"
  if [ -f $local_config_file ]; then
    . $local_config_file
  fi

  local merge_command=${GITUP_MERGE_COMMAND:-'rebase'}
  local branch_name=${GITUP_BRANCH_NAME:-'development'}
  local remote_name=${GITUP_REMOTE_NAME:-'origin'}
  local skip_update=${GITUP_SKIP_UPDATE:-0}
  local skip_install_dependencies=${GITUP_SKIP_INSTALL_DEPENDENCIES:-0}
  local skip_migrations=${GITUP_SKIP_MIGRATIONS:-0}

  echo " "

  while [ "$1" != "" ]; do
    case $1 in
      -m | --merge )
        shift
        merge_command=merge
        ;;
      -b | --branch )
        shift
        branch_name=$1
        ;;
      -r | --remote )
        shift
        remote_name=$1
        ;;
      --reset )
        merge_command=reset
        shift
        ;;
      -sa | --skip-after-update )
        shift
        skip_install_dependencies=1
        ;;
      -sm | --skip-migrations )
        shift
        skip_migrations=1
        ;;
      -su | --skip-update )
        shift
        skip_update=1
        ;;
      -h | --help )
        shift
        __gitup_help
        return 0
        ;;
      --init )
        shift
        __gitup_init
        return 0
        ;;
      --make-executable )
        shift
        __gitup_make_executable
        return 0
        ;;
      -v | --version )
        shift
        __gitup_version
        return 0
        ;;
      * )
        echo Unrecognized Option: $1
        echo ""
        __gitup_help
        return 0
        ;;
    esac
  done

  __gitup_run $merge_command $branch_name $remote_name $skip_update $skip_install_dependencies $skip_migrations
}

function __gitup_version {
  echo "gitup v$GITUP_VERSION"
  echo "------------"
}

function __gitup_help {
  __gitup_version
  echo "A shell script to automate the git update dance with a Rails project."
  echo " "
  echo "The steps include:"
  echo " "
  echo "  1. Check for uncommitted git changes, and exit if found"
  echo "  2. Fetch branch from remote (default: origin/development)"
  echo "  3. Update current branch from remote branch (default: rebase)"
  echo "  4. Check bundler for missing ruby gems, and install if needed"
  echo "  5. Check for and run migrations against 'development' if needed"
  echo "  6. Check for and run migrations against 'test' if needed"
  echo " "
  echo "Basic use:"
  echo " "
  echo "  gitup [option [value]]"
  echo " "
  echo "Command line options:"
  echo " "
  echo "  -b  --branch <name>        # set the branch to update from. default: development"
  echo "       --init                # copy the default .gituprc to the current directory"
  echo "       --make-executable     # symlink the gitup script to /usr/local/bin"
  echo "  -m   --merge               # merge instead of rebase"
  echo "  -r   --remote <name>       # git remote name. default: origin"
  echo "  -sa  --skip-after-update   # skip the step that runs after git updates"
  echo "  -sm  --skip-migrations     # skip the run migration step"
  echo "  -su  --skip-update         # skip the git update step"
  echo "  -h   --help                # the help screen you're looking at"
  echo "  -v   --version             # show the current gitup version number"
}

function __gitup_make_executable {
  echo "creating symlink"
  local gitup_root_folder=$(dirname $0)
  local gitup_source="$gitup_root_folder/gitup.sh"
  local gitup_dest_folder="/usr/local/bin"

  pushd $PWD >> /dev/null
  cd $gitup_dest_folder
  ln -sfnv $gitup_source "$gitup_dest_folder/gitup"
  popd >> /dev/null
}

function __gitup_init {
  echo "gitup Initialization"
  echo "--------------------"
  local gitup_rc_file="$(dirname $(readlink $0))/.gituprc"
  local rc_file_dest="$PWD/.gituprc"
  cp -fi $gitup_rc_file $rc_file_dest
  echo ""
  echo .gituprc configuration now available at $rc_file_dest
}

function __gitup_install_dependencies {
  echo "GITUP: Checking gem bundle status ..."
  bundle check
  RESULT=$?
  if [ $RESULT != 0 ]; then
    echo "GITUP: Running bundle install ..."
    bundle install
  fi
}

function __gitup_git_update {
  local merge_command=$1
  local branch_name=$2
  local remote_name=$3
  local upstream_branch="$remote_name/$branch_name"

  echo "GITUP: Updating current branch from [$upstream_branch] with [$merge_command] ..."
  git fetch $remote_name $branch_name

  if [ "$merge_command" = "reset" ]; then
    git reset $upstream_branch --hard
  else
    git $merge_command $upstream_branch
  fi
}

function __gitup_migrations {
  echo " "

  __gitup_dev_migrate
  RESULT=$?; if [ $RESULT != 0 ]; then return 1; fi
  echo " "

  __gitup_test_migrate
}

function __gitup_dev_migrate {
  echo "GITUP: Checking development database migration status ..."
  local remaining_migration_count=`bundle exec rake db:migrate:status | awk '{ print $1 }' | grep -c down`
  if [[ $remaining_migration_count -eq 0 ]]; then
    echo "GITUP: Development database is up to date ..."
  else
    echo "GITUP: Migrating development database ..."
    bundle exec rake db:migrate
  fi
}

function __gitup_test_migrate {
  echo "GITUP: Checking test database migration status ..."
  local remaining_migration_count=`RAILS_ENV=test bundle exec rake db:migrate:status | awk '{ print $1 }' | grep -c down`
  if [[ $remaining_migration_count -eq 0 ]]; then
    echo "GITUP: Test database is up to date ..."
  else
    echo "GITUP: Migrating test database ..."
    RAILS_ENV=test bundle exec rake db:migrate
  fi
}

function __gitup_run {
  local merge_command=$1
  local branch_name=$2
  local remote_name=$3
  local skip_update=$4
  local skip_install_dependencies=$5
  local skip_migrations=$6

  if [[ $skip_update -eq 0 ]]; then
    if [[ $(git status --porcelain) ]]; then
      echo "[GITUP] Local changes found!"
      echo " - Please commit, stash, or reset your local changes before re-running gitup"
      return 1
    fi

    __gitup_git_update $merge_command $branch_name $remote_name
    RESULT=$?; if [ $RESULT != 0 ]; then return $RESULT; fi
    echo " "
  fi

  if [[ $skip_install_dependencies -eq 0 ]]; then
    $GITUP_INSTALL_DEPENDENCIES_FN
    RESULT=$?; if [ $RESULT != 0 ]; then return $RESULT; fi
  fi

  if [[ $skip_migrations -eq 0 ]]; then
    $GITUP_RUN_MIGRATIONS_FN
    RESULT=$?; if [ $RESULT != 0 ]; then return $RESULT; fi
  fi
}

gitup "$@"
