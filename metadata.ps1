# Let's first define the Azure IMDS endpoint (Googled)
$imdsUrl = "http://169.254.169.254/metadata/instance?api-version=2021-02-01"

try {
    # Send a GET request to fetch the instance metadata
    $instanceMetadata = Invoke-RestMethod -Uri $imdsUrl -Headers @{"Metadata"="true"} -Method Get

    # Convert the metadata to JSON format to enhance the Readability 
    $jsonOutput = ConvertTo-Json $instanceMetadata -Depth 100

    # Output the JSON-formatted metadata
    Write-Output $jsonOutput
} 
catch {
    Write-Error "An error occurred while fetching instance metadata: $_"
}
