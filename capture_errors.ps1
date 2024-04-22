param(
  # Optional parameter to receive workspace path (applicable for YAML pipelines)
  [Parameter(Mandatory=$false)]
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

# Check for errors in the current script execution (e.g., syntax errors)
if ($error?) {
  $errorMessages += "Error occurred in current script: $($_.Exception.Message)"
}

# Write captured errors to errors.txt if any exist
if ($errorMessages -ne $null) {
  # Determine file path based on environment variable or argument
  if ($workspacePath) {
    $errorsFilePath = "$($workspacePath)\errors.txt"  # Use workspace path (from argument)
  } else {
    try {
      # Attempt to use Build.ArtifactStagingDirectory (classic editor)
      $errorsFilePath = "$(Build.ArtifactStagingDirectory)\errors.txt" 
    } catch {
      # Fallback to Agent.BuildDirectory if Build.ArtifactStagingDirectory fails
      Write-Warning "Build.ArtifactStagingDirectory not available. Using Agent.BuildDirectory."
      $errorsFilePath = "$(Agent.BuildDirectory)\errors.txt"
    }
  }
  
  Write-Host "Errors detected! Writing to $errorsFilePath..."
  Out-File -FilePath $errorsFilePath -InputObject $errorMessages -Append -Encoding UTF8
  
  # Publish errors.txt as artifact (optional, adjust path if needed)
  Publish-PipelineArtifact -Path $errorsFilePath -ArtifactName "errors.txt"
} else {
  Write-Host "Pipeline execution successful (no errors captured)."
}
