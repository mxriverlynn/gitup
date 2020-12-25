# Gitup: The Git Update Dance, Automated

Gitup is a small utility I built for my Rails apps, after growing tired of manually running the git update dance. Over time,
it's become a someone intelligent utility that has several options for configuration and runtime execution - including the
ability to change your settings based on what environment you're currently running in, what git branch you're on, etc.

An important note:

Gitup is not a general replacement for your git tools or knowledge. It only automated the git update dance that we do so
frequently, when we need to update our working branch from the main development branch.

## Features & Use

from `gitup -h`

```
gitup v1.1.0
---------------------
A shell script to automate the git update dance with a Rails project.
 
The steps include:
 
  1. Check for uncommitted git changes, and exit if found
  2. Fetch branch from remote (default: origin/development)
  3. Update current branch from remote branch (default: rebase)
  4. Check bundler for missing ruby gems, and install if needed
  5. Check for and run migrations against 'development' if needed
  6. Check for and run migrations against 'test' if needed
 
Basic use:
 
  gitup [option [value]]
 
Command line options:
 
  -b  --branch <name>        # set the branch to update from. default: development
  -c  --continue             # continues gitup from after the git fetch / update
      --init                 # copy the default .gituprc to the current directory
      --make-executable      # symlink the gitup script to /usr/local/bin
  -m  --merge                # merge instead of rebase
  -r  --remote <name>        # git remote name. default: origin
  -s  --skip-migrations      # git update and bundle install only
  -h  --help                 # the help screen you're looking at
  -v  --version              # show the current gitup version number
```

## LICENSE

MIT License
