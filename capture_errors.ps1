$errorMessages = $error.NonTerminating | Out-String
if ($errorMessages -ne "") {
    Write-Host "Errors encountered during pipeline execution:"
    Write-Host $errorMessages
    # Save errors to a text file
    $errorMessageFile = "errors.txt"
    Out-File -FilePath $errorMessageFile -InputObject $errorMessages -Encoding UTF8
    # Add the error file to artifacts
    Write-Host "Adding errors.txt to pipeline artifacts..."
    Publish-PipelineArtifact -Path $errorMessageFile -ArtifactName "errors"
} else {
    Write-Host "Pipeline execution successful!"
}
