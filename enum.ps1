# PowerShell script to list "Local Group Memberships" and "Global Group Memberships" for all domain users

# Get the list of all domain users
$rawUsers = net user /domain
# Preprocess to extract just the user names, skipping the header/footer
$usersList = $rawUsers -split "`n" | Where-Object {$_ -and $_ -notmatch "The command completed successfully"} | Select-Object -Skip 4 | Out-String
$userNames = $usersList -split " " | Where-Object { $_ -match "\w" }

# Prepare an array to hold the results
$results = @()

foreach ($userName in $userNames) {
    try {
        # Getting user details
        $userDetails = net user $userName /domain

        # Filtering for specific lines
        $localGroup = $userDetails | Where-Object { $_ -match "Local Group Memberships" }
        $globalGroup = $userDetails | Where-Object { $_ -match "Global Group Memberships" }

        # Avoid adding empty or malformed entries
        if ($localGroup -and $globalGroup) {
            # Building the result string
            $resultString = "Username: $userName`r`n$localGroup`r`n$globalGroup`r`n"
            # Adding the result to the results array
            $results += $resultString
        }
    } catch {
        # Optionally log error or handle specific cases
    }
}

# Output the results
foreach ($result in $results) {
    Write-Output $result
}
