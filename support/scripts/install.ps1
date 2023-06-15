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
    # param (
    #     [Parameter(Mandatory=$true)]
    #     $OSType,
    #     [Parameter(Mandatory=$true)]
    #     $PhoneinfogaVersion
    # )
    
    $ProgressPreference = 'SilentlyContinue'

    $InterpolatedString = "https://github.com/sundowndev/phoneinfoga/releases/download/" + $PhoneinfogaVersion + "/phoneinfoga_" + $OSType + ".tar.gz"

    Invoke-WebRequest -Uri $InterpolatedString -OutFile "phoneinfoga.exe"

    $ProgressPreference = 'Continue'
}




$OSType = PlatformCheck
$PhoneinfogaVersion = GetPhoneInfogaVersion

DownloadLatestRelease($OSType, $PhoneinfogaVersion)
