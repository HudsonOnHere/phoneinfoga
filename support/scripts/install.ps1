<#
.SYNOPSIS
   PhoneInfoga Intaller for Windows
.DESCRIPTION
   An installer script for downloading the latest release of PhoneInfoga. Without any arguments, this script will attempt detect your platform architecture (Amd64/ARM) and attempt to download the corresponding version of PhoneInfoga. Please submit an issue on GitHub if you encounter issues with this script."
.PARAMETER Name
   The name of the person to greet.
.EXAMPLE
   Greet -Name "John"
   Greets the person named John.
#>

$OSType
$PhoneinfogaVersion
$Automatic

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
        Write-Error "If this happens again, try running this script with the '--manual' flag."
        throw "Error determining platform architecture automatically."
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
        Write-Error "It is highly recommended that you validate the checksum of any executable downloaded from the Internet, however you can skip this step if it continues to fail by adding the '--skip-checksum' flag."
        throw "Checksum validation failed."
    }
}



$OSType = PlatformCheck
$PhoneinfogaVersion = GetPhoneInfogaVersion

# DownloadLatestRelease($OSType, $PhoneinfogaVersion)
ValidateChecksum
