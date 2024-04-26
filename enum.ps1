# Get the list of all domain users
$rawUsers = net user /domain
# Preprocess to extract just the user names, handling pagination and skipping headers/footers
$usersList = $rawUsers -replace '.*--.*' -replace '\s+', "`n" | Where-Object { $_ -and $_ -notmatch "The command completed successfully|User accounts for|\b---" }

# Prepare an array to hold the results
$results = @()

foreach ($userName in $usersList) {
    try {
        # Trimming username in case of extra spaces
        $userName = $userName.Trim()
        # Getting user details
        $userDetails = net user $userName /domain | Out-String

        # Filtering for specific lines
        $localGroup = $userDetails -split "`n" | Where-Object { $_ -match "Local Group Memberships" }
        $globalGroup = $userDetails -split "`n" | Where-Object { $_ -match "Global Group Memberships" }

        # Avoid adding empty or malformed entries
        if ($localGroup -and $globalGroup) {
            # Building the result string
            $resultString = "Username: $userName`r`n$localGroup`r`n$globalGroup`r`n"
            # Adding the result to the results array
            $results += $resultString
        }
    } catch {
        # Optionally log error or handle specific cases
        Write-Output "Failed to process user $userName"
    }
}

# Output the results
foreach ($result in $results) {
    Write-Output $result
}
