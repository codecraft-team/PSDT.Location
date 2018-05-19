function Push-LocationToGlobalStack {
    param (
        [string]$Path
    )

    process {
        Push-Location -Path $Path;
    }
}