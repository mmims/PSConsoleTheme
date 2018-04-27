param (
    [ValidateSet('Release','Debug')]
    [string]$Configuration = (property 'Configuration' 'Release'),
    [string]$NuGetApiKey = (property 'NuGetApiKey' ''),
    [switch]$User,
    [string]$Version
)

$targetDir = Join-Path $BuildRoot "module/$Configuration/PSConsoleTheme"
if ($Configuration -eq 'Debug') {
    $Global:PSConsoleThemeDebugSessionPath = $targetDir
}

function Get-Version {
    $manifest = Import-PowerShellDataFile 'PSConsoleTheme/PSConsoleTheme.psd1'
    [System.Version]::Parse($manifest.ModuleVersion)
}

$mamlHelpParams = @{
    Inputs = (Get-ChildItem docs/*.md -Exclude about_*.md)
    Outputs = (Join-Path $targetDir 'en-US/PSConsoleTheme-help.xml')
}

# Synopsis: Build external help file from markdown documentation
task BuildMamlHelp @mamlHelpParams -If ($Configuration -eq 'Release') {
    $oldProgress = $Global:ProgressPreference
    $Global:ProgressPreference = 'SilentlyContinue'
    PlatyPS\New-ExternalHelp -Path docs -OutputPath $targetDir\en-US\PSConsoleTheme-help.xml -Force | Out-Null
    $Global:ProgressPreference = $oldProgress
}

# Synopsis: Remove all build related artifacts
task Clean {
    Remove-Item module -Recurse -Force -ErrorAction Ignore
    if ($User -and (($userProfile = Join-Path $env:USERPROFILE '.psconsoletheme') | Test-Path)) {
        Remove-Item $userProfile -Recurse -Force -Confirm
    }
}

# Synopsis: Import the module for use in the current session
task Install LayoutModule, {
    switch ($Configuration) {
        Debug {
            Remove-Module PSConsoleTheme -Force -ErrorAction Ignore
            Import-Module (Join-Path $targetDir 'PSConsoleTheme.psm1') -Force
        }
        Release {
            $paths = $env:PSModulePath -split ';' | Where-Object { $_ -like "${env:USERPROFILE}*" }
            foreach ($path in $paths) {
                if (!(Test-Path $paths)) {
                    New-Item $path -ItemType Directory -Force | Out-Null
                }

                try {
                    if (Test-Path "$path\PSConsoleTheme") {
                        Remove-Item "$path\PSConsoleTheme" -Recurse -Force -ErrorAction Stop
                    }
                    Copy-Item $targetDir $path -Recurse
                }
                catch {
                    Write-Error "Cannot install to $path. Module might be in use."
                }
            }
        }
    }
}

$layoutModuleParams = @{
    Inputs = {
        Get-ChildItem `
            PSConsoleTheme/*.ps*,
            PSConsoleTheme/Private/*.ps1,
            PSConsoleTheme/Public/*.ps1,
            PSConsoleTheme/Themes/*.json
    }
    Outputs = {
        process {
            Join-Path $targetDir ($_ -replace [regex]::Escape($BuildRoot + '\PSConsoleTheme\'), '')
        }
    }
}

# Synopsis: Copy all of the files that belong in the module to one place for installation
task LayoutModule -Partial @layoutModuleParams BuildMamlHelp, {
    process {
        if (-Not (Test-Path (Split-Path $2) -PathType Container)) {
            New-Item (Split-Path $2) -ItemType Directory -Force | Out-Null
        }
            Write-Verbose "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $($2 -replace [regex]::Escape($BuildRoot + '\'), '')"
            Copy-Item $_ $2 -Force
        }
    }

# Synopsis: Publish the module to PSGallery
task Publish -If ($Configuration -eq 'Release') {
    if ($NuGetApiKey -eq '') {
        throw "Cannot publish. NuGet API key not set."
    }

    $publishParams = @{
        Path = $targetDir
        NuGetApiKey = $NuGetApiKey
        Repository = 'PSGallery'
    }

    Publish-Module @publishParams
}

# Synopsis: Update the module version in the manifest file
task UpdateVersion {
    if ($Version -eq '') {
        throw 'No version specified'
    }

    $current = Get-Version
    switch ($Version) {
        Major {
            $update = "$($current.Major + 1).0.0"
        }
        Minor {
            $update = "$($current.Major).$($current.Minor + 1).0"
        }
        Patch {
            $update = "$($current.Major).$($current.Minor).$($current.Build + 1)"
        }
        Default {
            if ([System.Version]::TryParse($Version, [ref]$null)) {
                $update = $Version
            } else {
                throw "Invalid version specified: $Version"
            }
        }
    }

    Write-Host "Updating version from [$current] to [$update]"
    $file = Resolve-Path 'PSConsoleTheme/PSConsoleTheme.psd1'
    $manifest = Get-Content $file -Raw
    $manifest = [regex]::Replace($manifest, "ModuleVersion = '.*'", "ModuleVersion = '$update'")
    $manifest | Set-Content $file -Encoding UTF8 -NoNewline
}

# Synopsis: Create an archive of the module for release
task ZipRelease -If ($Configuration -eq 'Release') LayoutModule, {
    $version = Get-Version
    Compress-Archive $targetDir -DestinationPath ((Split-Path $targetDir) + "/PSConsoleTheme-$version.zip") -Force
}

task . LayoutModule