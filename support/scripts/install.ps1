<#
.SYNOPSIS
   This function greets a person by name.
.DESCRIPTION
   The Greet function takes a name as input and outputs a greeting message.
   It displays a friendly greeting message with the provided name.
.PARAMETER Name
   The name of the person to greet.
.EXAMPLE
   Greet -Name "John"
   Greets the person named John.
#>

# Windows_arm64.tar.gz
# Windows_armv6.tar.gz
function GetPhoneInfogaVersion {    

    $RawContent = (invoke-webrequest -uri https://api.github.com/repos/sundowndev/phoneinfoga/releases/latest -usebasicparsing).Content | convertfrom-json
    $LatestReleaseTag = $RawContent.tag_name

    return $PhoneinfogaVersion
}

function PlatformCheck {
    $PlatformCheckCommand = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemType
    
    if ($PlatformCheckCommand -like "*x64-based PC*") {
        return "Windows_arm64"
    } elseif ($PlatformCheckCommand -like "*ARM64-based PC*") {
        return "Windows_armv6"
    } else {
        Write-Output "Something else happened"
    }
}

function DownloadLatestRelease {
    # Disabling the progress bar dramatically improves the download speed    
    $ProgressPreference = 'SilentlyContinue'

    $InterpolatedString = "https://github.com/sundowndev/phoneinfoga/releases/download/" + $PhoneinfogaVersion + "/phoneinfoga_" + $OSType + ".tar.gz"

    Invoke-WebRequest -Uri $InterpolatedString -OutFile "phoneinfoga.exe"

    $ProgressPreference = 'Continue' # Default restored
}

function ValidateChecksum {

    $LatestReleaseChecksum = "https://github.com/sundowndev/phoneinfoga/releases/download/" + $PhoneinfogaVersion + "/phoneinfoga_checksums.txt"

    $ProgressPreference = 'SilentlyContinue'

    Invoke-WebRequest -Uri $LatestReleaseChecksum -OutFile "phoneinfoga_checksums.txt"

    $ProgressPreference = 'Continue'

    $FileContents = Get-Content -Path ".\phoneinfoga_checksums.txt"
    $TargetString = "phoneinfoga_" + $OSType + ".tar.gz"
    
    foreach ($Line in $FileContents) {
        if ($Line -like "*$TargetString*") {
            $TargetHash = $Line.Split(" ")[0]
            break
        }
    }

    $ComputedHash = (Get-FileHash .\phoneinfoga.exe -Algorithm SHA256).hash

    if ($TargetHash.ToLower() -eq $ComputedHash.ToLower()) {
        Write-Host "Valid Checksum!"
    } else {
        Write-Host "Invalid Checksum!"
    }
}



$OSType = PlatformCheck
$PhoneinfogaVersion = GetPhoneInfogaVersion

# DownloadLatestRelease($OSType, $PhoneinfogaVersion)
ValidateChecksum
