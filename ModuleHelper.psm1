using namespace System

function Set-EnvironmentFromFile {
    param (
        [Alias("FilePath")] [string]$file = ".env"
    )
    $lines = Get-Content -Path $file -ErrorAction SilentlyContinue
    foreach ($line in $lines) {
        $item = $line.Split("=", 2)
        if ($item.Count -eq 2) {
            $key = $item[0].Trim()
            $value = $item[1].Trim()
            if (!$key.StartsWith("#")) { try { [Environment]::SetEnvironmentVariable($key, $value) } catch {} }
        }
    }
}

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
        if (!$repo) { Register-PSResourceRepository -Name $name -Uri $url -Priority 10 -Trusted -ErrorAction Stop }
        elseif ($repo.Uri.ToString().TrimEnd("/") -ne $url.TrimEnd("/")) { Set-PSResourceRepository -Name $name -Uri $url -ErrorAction Stop }
    }
    catch { if ($silent) { return $null } else { throw } }
}
