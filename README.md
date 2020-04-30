# zsh-git-config

This zsh script customizes the prompt in zsh to show git statuses.

Place the .zsrhc file in your ${HOME} dir or under /etc/ dir.

Make sure you don't override an existing .zshrc file. You can copy the contents of this file and paste them into the existing one.

Restart your terminal and go to a git repo in your file system, git markers should display as follows:

- name of the current branch
- if there are any untracked files (a yellow + )
- if there are any files/changes not staged (a yellow \*)
- if there  changes not committed yet (a cyan \*)
- if local repo is ahead of or behind remote (magenta arrow up and number of commits ahead / magenta arrow down and number of commits behind)

Enjoy.
