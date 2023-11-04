Add-Type -AssemblyName System.Web

# Displays next step message while waiting for input.  If input is X, goes directly to CleanUp fucntion
function DisplayStep ([string]$message = "") {
    $done = read-host `n$message
    if ($done -eq "X") {
        CleanUp($done) 
    }
    return $done
}

# Determines if "Clean Up" is going to be displayed
function StartCleanUp ([string] $done) {
    if ($done -ne "X") { read-host "Next Step - Cleans up" }    
}

# Displays message at the start of script to let user know they can exit at any time.
function StartScript {
    read-host "Start of demo script. Enter 'X' at any prompt to clean up resources and exit"
}

# Completes script and exits
function ExitScript {
    Set-Location ..
    write-host "Resources cleaned up"  
    Exit
}

# Sends message to Cluster Info.  Can be bypassed by uncommenting "return"
function SendMessageToCI {
    param (
        $MessageBody, 
        $MessageHeader = "Next Command", 
        $MessageType = "Command")     # MessageTypes: Command, Code, Info

    # Uncomment the return below to prevent messages sent to Cluster Info
    # return
    
    # Set to the Cluster Info REST endpoint
    $CIEntryPoint = "http://localhost:5252/api/ExternalMessages"
    
    # # Set to DNS for the cluster
    if (Test-Path 'env:CIK8swsMode') {
        $CIEntryPoint = "https://clusterinfo.k8sws.com/api/ExternalMessages"
    }    
    
    # $ProgressPreference = 'SilentlyContinue'
    # # For local development (project default port)
    if (Test-Path 'env:CIDeveloperMode') {
        $CIEntryPoint = "http://localhost:6200/api/ExternalMessages"
    }
    try {
        # Write-Host $CIEntryPoint
        $Payload = @{
            Body        = $MessageBody;
            Header      = $MessageHeader;
            MessageType = $MessageType;
        }           
        $Response = Invoke-WebRequest -Uri $CIEntryPoint -Body ($Payload | ConvertTo-Json) -method POST -ContentType "application/json"
    }
    catch {}
}