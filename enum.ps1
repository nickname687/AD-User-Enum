# Capture the output of 'net user /domain'
$output = net user /domain

# Parse usernames from the output
$usersList = $output -split "`n" | Where-Object {
    $_ -match '\S' -and $_ -notmatch "The command completed successfully|User accounts for|--More--|The syntax of this command is"
}

# Trim and extract usernames into an array
$userNames = $usersList -replace "---", "" -replace "The request will be processed at a domain controller for domain .*", "" -split '\s+' | Where-Object { $_ }

# Prepare an array to hold the results
$results = @()

foreach ($userName in $userNames) {
    try {
        # Trim any extra whitespace from the username
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
        Write-Output "Failed to process user $userName"
    }
}

# Output the results
$results | ForEach-Object { Write-Output $_ }
