# Utility Scripts

## PullAllRepos.ps1

Pulls all defined main branches in all repositories in a defined folder and merges them to the current branch.

* $basePath = "." - Path of folder that contains repository files
* $repoPrefix = "" - Repository folders start with this prefix; if blank than all folders are taken
* $releaseBranchFolder = "release/" - This defines release branches that are pushed to production. Main development branch will not be merged to this, but a warning will be outputed.
* $developBranch = "master" - This is the main development branch that will be pulled to currently checked out branches
