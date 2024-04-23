param(
  # Optional parameter to receive workspace path (applicable for YAML pipelines)
  [Parameter(Mandatory=$true)]
  [string] $workspacePath
)

$errorMessages = $null

# Trap terminating errors (errors that would normally stop the pipeline)
trap {
  $errorMessages += $_.Exception.Message
}

# Check for errors from previous steps (including npm test)
$lastExitCode = $LASTEXITCODE
if ($lastExitCode -ne 0) {
  $errorMessages += "Previous step exited with code: $lastExitCode"
}

# Write captured errors to errors.txt if any exist
if ($errorMessages -ne $null) {
  # Determine file path based on environment variable or argument
  if ($workspacePath) {
    $errorsFilePath = Join-Path -Path $workspacePath -ChildPath "errors.txt"  # Use workspace path (from argument)
  } else {
    $errorsFilePath = Join-Path -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY -ChildPath "errors.txt"
  }
  
  # Ensure the directory exists
  $errorsDirectory = Split-Path -Path $errorsFilePath
  if (-not (Test-Path -Path $errorsDirectory)) {
    New-Item -Path $errorsDirectory -ItemType Directory -Force
  }

  Write-Host "Errors detected! Writing to $errorsFilePath..."
  Out-File -FilePath $errorsFilePath -InputObject $errorMessages -Append -Encoding UTF8
  
  # Publish errors.txt as artifact (optional, adjust path if needed)
  if ($env:BUILD_ARTIFACTSTAGINGDIRECTORY) {
    Write-Host "Publishing errors.txt as artifact..."
    Copy-Item -Path $errorsFilePath -Destination $env:BUILD_ARTIFACTSTAGINGDIRECTORY -Force
  } else {
    Write-Warning "Build.ArtifactStagingDirectory not available. Unable to publish artifact."
  }
} else {
  Write-Host "Pipeline execution successful (no errors captured)."
}
