using namespace System

function Initialize-PrivateGallery {
    param (
        [Alias("GalleryName")] [string]$name,
        [Alias("GalleryUrl")] [string]$url,
        [Alias("OnErrorContinue")] [switch]$silent
    )
    try {
        $name = $name ? $name : ($env:PrivatePSGallery ? "PrivatePSGallery" : $null)
        $url = $url ? $url : [Environment]::GetEnvironmentVariable($name)
        if (!$name) { throw "Environment variable PrivatePSGallery not found" }
        if (!$url) { throw "Invalid url" }
        $repo = Get-PSResourceRepository -Name $name -ErrorAction SilentlyContinue
        if ($repo) {
            if ($repo.Uri.ToString().TrimEnd('/') -ne $url.TrimEnd('/')) {
                Set-PSResourceRepository -Name $name -Uri $url -ErrorAction Stop
            }
        }
        else {
            Register-PSResourceRepository -Name $name -Uri $url -Priority 10 -Trusted -ErrorAction Stop
        }
    }
    catch { if ($silent) { return $null } else { throw } }
}