param(
  [Parameter(Mandatory=$true)]
  [string] $agentWorkDirectory
)

$errorMessages = ""

# Loop through each job in the pipeline execution
$jobs = Get-ChildItem -Path $agentWorkDirectory -Filter "*.log" | Where-Object { $_.Name -match "Job_\d+" }  # Identify job logs

foreach ($jobLog in $jobs) {
  # Extract job name from the log file name
  $jobName = $jobLog.Name.Split("_")[1]
  Write-Host "Checking logs for job: $jobName..."

  # Find job-specific log files (adjust filter if needed)
  $jobLogFiles = Get-ChildItem -Path $jobLog.FullName.Replace(".log", "") -Filter "*.log"

  $jobErrorMessages = ""
  foreach ($logFile in $jobLogFiles) {
    $jobErrorMessages += Get-Content -Path $logFile.FullName -Raw
    $jobErrorMessages += "`n"  # Add newline between logs
  }

  if ($jobErrorMessages -ne "") {
    $errorMessages += "**Errors in job: $jobName**`n"
    $errorMessages += $jobErrorMessages
    $errorMessages += "`n"  # Newline between jobs
  }
}

# Write captured errors to error.txt (same logic as before)
if ($errorMessages -ne $null) {
  $errorsFilePath = Join-Path -Path $agentWorkDirectory -ChildPath "errors.txt"
  Write-Host "Errors detected! Writing to $errorsFilePath..."
  Out-File -FilePath $errorsFilePath -InputObject $errorMessages -Encoding UTF8
} else {
  Write-Host "Pipeline execution successful (no errors captured)."
}
