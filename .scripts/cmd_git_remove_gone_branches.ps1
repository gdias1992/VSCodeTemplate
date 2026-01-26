# This script removes local branches that no longer exist on the remote (origin)
# It uses 'git fetch -p' to prune remote-tracking branches first.

Write-Host "Fetching and pruning remote-tracking branches..." -ForegroundColor Cyan
git fetch --prune

# Get the list of branches that are "gone" on the remote
$goneBranches = git branch -vv | Select-String ": gone\]" | ForEach-Object {
    $_.ToString().Trim().Split(" ")[0]
}

if ($goneBranches.Count -eq 0 -or $null -eq $goneBranches) {
    Write-Host "No local branches found that are missing on the remote." -ForegroundColor Green
} else {
    Write-Host "The following local branches are marked as 'gone' and will be deleted:" -ForegroundColor Yellow
    $goneBranches | ForEach-Object { Write-Host " - $_" }

    foreach ($branch in $goneBranches) {
        if ($branch -eq "*" -or $branch -eq "") { continue }
        
        # Remove metadata like * if it's the current branch (though you shouldn't delete the current branch)
        $cleanBranch = $branch.Replace("*", "").Trim()
        
        Write-Host "Deleting branch: $cleanBranch" -ForegroundColor Gray
        git branch -D $cleanBranch
    }
    
    Write-Host "Cleanup complete." -ForegroundColor Green
}
