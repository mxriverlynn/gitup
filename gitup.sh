GITUP_VERSION="1.0.0"

function gitup {
  # set defaults for all options
  GITUP_MERGE_COMMAND=rebase
  GITUP_BRANCH_NAME=development
  GITUP_REMOTE_NAME=origin
  GITUP_SKIP_UPDATE=0
  GITUP_SKIP_MIGRATIONS=0

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
      -c | --continue )
        shift
        skip_update=1
        ;;
      -s | --skip-migrations )
        shift
        skip_migrations=1
        ;;
      -h | --help )
        shift
        __gitup_help
        return 0
        ;;
      --init )
        __gitup_init
        return 0
        ;;
      -v | --version )
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

  __gitup_run $merge_command $branch_name $remote_name $skip_update $skip_migrations
}

function __gitup_version {
  echo "gitup v$GITUP_VERSION"
}

function __gitup_help {
  echo "gitup v$GITUP_VERSION"
  echo "---------------------"
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
  echo "  -c  --continue             # continues gitup from after the git fetch / update"
  echo "      --init                 # copy the default .gituprc to the current directory"
  echo "  -m  --merge                # merge instead of rebase"
  echo "  -r  --remote <name>        # git remote name. default: origin"
  echo "  -s  --skip-migrations      # git update and bundle install only"
  echo "  -h  --help                 # the help screen you're looking at"
  echo "  -v  --version              # show the current gitup version number"
}

function __gitup_init {
  echo "gitup Initialization"
  echo "--------------------"
  local rc_file_source="$(dirname ${BASH_SOURCE[0]})/.gituprc"
  local rc_file_dest="$PWD/.gituprc"
  cp -fi $rc_file_source $rc_file_dest
  echo ""
  echo .gituprc configuration now available at $rc_file_dest
}

function __gitup_run_bundle {
  echo "GITUP: Checking gem bundle status ..."
  bundle check
  RESULT=$?
  if [ $RESULT != 0 ]; then
    echo "GITUP: Running bundle install ..."
    bundle install
  fi
}

function __gitup_run_dev_migrate {
  echo "GITUP: Checking development database migration status ..."
  local remaining_migration_count=`bundle exec rake db:migrate:status | awk '{ print $1 }' | grep -c down`
  if [[ $remaining_migration_count -eq 0 ]]; then
    echo "GITUP: Development database is up to date ..."
  else
    echo "GITUP: Migrating development database ..."
    bundle exec rake db:migrate
  fi
}

function __gitup_run_test_migrate {
  echo "GITUP: Checking test database migration status ..."
  local remaining_migration_count=`RAILS_ENV=test bundle exec rake db:migrate:status | awk '{ print $1 }' | grep -c down`
  if [[ $remaining_migration_count -eq 0 ]]; then
    echo "GITUP: Test database is up to date ..."
  else
    echo "GITUP: Migrating test database ..."
    RAILS_ENV=test bundle exec rake db:migrate
  fi
}

function __gitup_run_git_update {
  local merge_command=$1
  local branch_name=$2
  local remote_name=$3
  local upstream_branch="$remote_name/$branch_name"

  echo "GITUP: Updating current branch from [$upstream_branch] with [$merge_command] ..."
  git fetch $remote_name $branch_name
  git $merge_command $upstream_branch
}

function __gitup_run {
  local merge_command=$1
  local branch_name=$2
  local remote_name=$3
  local skip_update=$4
  local skip_migrations=$5

  if [[ $skip_update -eq 0 ]]; then
    if [[ $(git status --porcelain) ]]; then
      echo "[GITUP] Local changes found!"
      echo " - Please commit, stash, or reset your local changes before re-running gitup"
      return 1
    fi

    __gitup_run_git_update $merge_command $branch_name $remote_name
    RESULT=$?; if [ $RESULT != 0 ]; then return 1; fi
    echo " "
  fi

  __gitup_run_bundle
  RESULT=$?; if [ $RESULT != 0 ]; then return 1; fi

  if [[ $skip_migrations -eq 0 ]]; then
    echo " "

    __gitup_run_dev_migrate
    RESULT=$?; if [ $RESULT != 0 ]; then return 1; fi
    echo " "

    __gitup_run_test_migrate
  fi
}
