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

# Check if any error occurred during the pipeline execution
if ($errorMessages -ne $null) {
  # Write the errors to the error.txt file
  $errorsFilePath = Join-Path -Path $workspacePath -ChildPath "errors.txt"
  
  Write-Host "Errors detected! Writing to $errorsFilePath..."
  Out-File -FilePath $errorsFilePath -InputObject $errorMessages -Encoding UTF8
  
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
