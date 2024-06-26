#CHANGE THIS. Must exactly match the 'Display Name' field in 365.
$usersToInvestigate = @(
    "user1",
    "user2"
)
#Set the required graph permissions
$permissions = @(
    "AuditLog.Read.All",
    "openid",
    "profile",
    "User.Read",
    "email",
    "User.ReadWrite.All",
    "Group.ReadWrite.All",
    "Directory.ReadWrite.All"
)
#Custom PS Object to prettify the output
$allUsersStatus = @()
foreach ($username in $usersToInvestigate) {
    $allUsersStatus += [PSCustomObject]@{
        UserName = $username
        Status   = 'No Risk'
        Logs     = $null
    }
}
connect-mggraph -deviceCode -ContextScope Process -Scopes $permissions
foreach ($user in $usersToInvestigate) {
    write-host -ForegroundColor green "Investigating $user, ignore errors!!"
    $userObject = (Get-MgUser -Filter "displayname eq '$user'")
    #Gets the windows device that is most recently active. This might break if more than one device has been used in the last week
    $deviceId = (Get-MgUserRegisteredDevice -UserId $userObject.id | `
                 Where-Object { $_.AdditionalProperties['operatingSystem'] -eq 'Windows' -and [DateTime]$_.AdditionalProperties['approximateLastSignInDateTime'] -ge (Get-Date).AddDays(-7) } -ErrorAction SilentlyContinue | `
                 Sort-Object { $_.AdditionalProperties['approximateLastSignInDateTime'] } -Descending | `
                 Select-Object -First 1).AdditionalProperties['deviceId']
    #Skip user if no device found
    if ($null -eq $deviceID) {
        write-host -ForegroundColor red "No devices found for $($userObject.UserPrincipalName.tolower())"
        continue
    }
    $signInLogs = Get-MgAuditLogSignIn -Filter "userId eq '$($userobject.id)'" -all | where {$_.DeviceDetail.deviceid -ne "$deviceid" -and $_.status.errorcode -eq 0}
    if ($signInLogs) {
        $variableName = "$($userObject.UserPrincipalName.tolower().Split('@')[0])SignInLogs"
        New-Variable -Name $variableName -Value $signInLogs -force
        $user = $allUsersStatus | Where-Object { $_.UserName -eq $username }
        $user.Status = 'At Risk'
        $user.Logs = ("$" + $variableName)
    }
}
$allUsersStatus