param (
    [string]$basePath = ".", # Path of folder that contains repository files
    [string]$repoPrefix = "", # Repository folders start with; if blank than all folders are taken
    [string]$releaseBranchFolder = "release/", # All branches that are pushed automatically to production start with this. Main development branch will not be merged to this, but a warning will be outputed.
    [string]$developBranch = "master" # This is the main development branch that will be pulled to currently checked out branches
)

function IsRepo ($repo) {
    return $repo.StartsWith($repoPrefix)
}

function IsReleaseBranch ($branch) {
    return $branch.StartsWith($releaseBranchFolder)
}

function UpdateListOfRemoteBranches {
    git remote update origin --prune
}

function PullCurrentBranch {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Host "** Pulling current branch '$currentBranch'" -foregroundcolor "Green"
    [void] (git pull)

    return $currentBranch
}

function PullDevelopIfNotCurrentBranch ($currentBranch) {
    if ($currentBranch -ne $developBranch) {
        if (IsReleaseBranch($currentBranch)) {
            Write-Host "** Current branch is a release branch. Skipping pull of '$developBranch'. Merge manually if needed." -foregroundcolor "Red"
            return
        }

        Write-Host "** Pulling branch '$developBranch'" -foregroundcolor "Green"
        git pull origin $developBranch
    } 
}

function GetAllRepoFolders {
    Get-ChildItem | 
       Where-Object {$_.PSIsContainer} | 
       Foreach-Object {$_.Name}
}

function PullAllRepos ($basePath, $repoPrefix) {
    Set-Location $basePath
    $currentPath = (Get-Item -Path ".\").FullName

    $repositories = GetAllRepoFolders
    
    foreach ($repo in $repositories) {
        if (!(IsRepo $repo)) {
            continue;
        }

        Write-Host "`n*** Pulling repo $repo" -foregroundcolor "Yellow"
        
        Set-Location $repo
        UpdateListOfRemoteBranches

        $currentBranch = PullCurrentBranch

        PullDevelopIfNotCurrentBranch $currentBranch

        Set-Location $currentPath
    }
}


PullAllRepos $basePath $repoPrefix