# Capture errors from pipeline execution
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
  $errorsFilePath = "$(Pipeline.Workspace)\errors.txt"
  Write-Host "Errors detected! Writing to $errorsFilePath..."
  Out-File -FilePath $errorsFilePath -InputObject $errorMessages -Append -Encoding UTF8
  
  # Publish errors.txt as artifact (optional, adjust path if needed)
  Publish-PipelineArtifact -Path $errorsFilePath -ArtifactName "errors.txt"
} else {
  Write-Host "Pipeline execution successful (no errors captured)."
}
