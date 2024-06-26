# SignInRiskChecker

SignInRiskChecker is a PowerShell tool designed to investigate user activity in Microsoft Graph and determine if any users are at risk based on their sign-in logs and associated devices.

## Prerequisites

- PowerShell 7 or later
- Microsoft.Graph PowerShell module

## Permissions

The tool requires the following Microsoft Graph permissions:

- AuditLog.Read.All
- openid
- profile
- User.Read
- email
- User.ReadWrite.All
- Group.ReadWrite.All
- Directory.ReadWrite.All

## Installation

1. Install the Microsoft.Graph PowerShell module if you haven't already:

    ```powershell
    Install-Module Microsoft.Graph -Scope CurrentUser
    ```

2. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/SignInRiskChecker.git
    cd SignInRiskChecker
    ```

3. Open the `SignInRiskChecker.ps1` script in a text editor to customize the `$usersToInvestigate` array with the user display names you want to investigate.

## Usage

1. Open a PowerShell terminal.
2. Run the script:

    ```powershell
    .\SignInRiskChecker.ps1
    ```

3. The script will:
    - Connect to Microsoft Graph using device code authentication.
    - Iterate through the users specified in the `$usersToInvestigate` array.
    - Check for Windows devices that were signed in within the last 7 days.
    - Retrieve sign-in logs and determine if any sign-ins were made from devices other than the user's most recent Windows device.
    - Mark users as "At Risk" if any such sign-ins are found.
    - Output the status of each user.
