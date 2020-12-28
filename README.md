# Gitup: The Git Update Dance, Automated

Gitup is a small utility I built for my Rails apps, after growing tired of manually running the git update dance. Over time,
it's become a someone intelligent utility that has several options for configuration and runtime execution - including the
ability to change your settings based on what environment you're currently running in, what git branch you're on, etc.

An important note:

Gitup is not a general replacement for your git tools or knowledge. It only automated the git update dance that we do so
frequently, when we need to update our working branch from the main development branch.

## Getting Started

After you clone this repository, you'll want to run the `--make-executable` flag from the script. This will add a symlink
at `/usr/local/bin/gitup`, pionting to the `gitup.sh` file.

```bash
./gitup.sh --make-executable
```

Now you can run `gitup` anywhere on your system!

## Full Features & Use

A shell script to automate the git update dance with a Rails project.
 
core git steps:

  1. Check for uncommitted git changes, and exit if found
  2. Fetch branch from remote (default: origin/development)
  3. Update current branch from remote branch (default: rebase)

default (ruby/rails) steps:

  4. Check bundler for missing ruby gems, and install if needed
  5. Check for and run migrations against 'development' if needed
  6. Check for and run migrations against 'test' if needed
 
Basic use:
 
```bash
gitup [option [value]]
```

Run `gitup` by itself to perform the complete list of steps, as outlined above.
 
For a list of all command line options, run:
 
```bash
gitup --help
```

## Advanced Configuration

Gitup can be customized to be used with other languages fairly easily. You only need to write a few functions
that defined the work to do, and then register these functions.

To configure your new function, you'll need to edit the `.gituprc` file for your project. If you don't have
an rc file yet, you can run `gitup --init` from your project folder to create one.

### Handling Git Updates

```bash
# GITUP_GIT_UPDATE_FN:
#   The method called to update your git branch. Responsible
#   for handling git pull, git merge or rebase, etc.
#
#   Params:
#     $1: Merge Command
#     $2: Branch Name 
#     $3: Remote Name
#
#   Default:
#     GITUP_GIT_UPDATE_FN=__gitup_git_update
```

### Dependency Installation

```bash
# INSTALL DEPENDENCIES
# --------------------
# Function to run after gitup has completed the git update process
#
# Default:
#   GITUP_INSTALL_DEPENDENCIES_FN=__gitup_install_dependencies

GITUP_INSTALL_DEPENDENCIES_FN=install_yarn_packages

function install_yarn_packages {
  echo Installing yarn packages
  yarn install
}
```

This example will run `yarn install` after your git branch has updated

### Run Migraitons

```bash
# RUN MIGRATIONS STEP
# -------------------
# Function to run migrations. Occurs after git update and post-update steps
# Default:
#   GITUP_RUN_MIGRATIONS_FN=__gitup_migrations

```

## Tests

Gitup uses [shunit2](https://github.com/kward/shunit2/) for tests, and has included
the full shunit2 included in this repository.

To run the tests, use the following command from the root of this project repository:

```bash
./gitup-specs.sh
```

## LICENSE

MIT License
