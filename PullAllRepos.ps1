param (
    [string]$basePath = ".",
    [string]$repoPrefix = "",
    [string]$releaseBranchFolder = "release/",
    [string]$developBranch = "master"
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

        Write-Host "** Pulling branch '$developBranch' and merging into current branch '$currentBranch'" -foregroundcolor "Green"
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