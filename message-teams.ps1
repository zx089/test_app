# webhook url into teams
# $teamsWebhookUrl = $args[0]
$teamsWebhookUrl = 'https://inlinemarketevolutionoy.webhook.office.com/webhookb2/0da9231a-2d3c-4f8e-bda1-767017fbee8b@1e3ee4c0-94a9-45a4-9151-07e1858e6372/IncomingWebhook/471e30b85bff43fb97d37a5235b38799/4b3fb30e-1e8c-4832-be5d-df3bcd5271bc'
$targetEnv = if ($env.isMaster -eq 'True') {'stage'} else {'prod'}

function Send-Message {
    param (
        [string]$Number,
        [string]$DefinitionName,
        [string]$AgentJobStatus,
        [string]$TriggeredBy,
        [string]$SummaryUri,
        [string]$TargetEnv
    )
    $message = [PSCustomObject]@{
        '@type' = "MessageCard"
        '@context' = "https://schema.org/extensions"
        "themeColor" = if ($AgentJobStatus -eq "Succeeded") {"008000"} else {"ff0000"}
        "title" = "$DefinitionName $Number ${TargetEnv}: **$AgentJobStatus**"
        "text" = "Triggered by $TriggeredBy"
        "potentialAction" = @(@{
            '@type' = "OpenUri"
            "name" = "Open Summary"
            "targets" = @(@{
                "os" = "default"
                "uri" = $SummaryUri
            })
        })
    }

    Invoke-RestMethod -Method Post -ContentType 'Application/Json' -Body (ConvertTo-Json -Compress -Depth 5 -InputObject $message) -Uri $teamsWebhookUrl
    Write-Host "Json output:"
    Write-Host (ConvertTo-Json -Compress -Depth 5 -InputObject $message)
}

$AgentJobStatus = ${env:agent.jobstatus}
if ($env:RELEASE_DEFINITIONNAME) {
    $Number = "${env:RELEASE_RELEASEID} released to ${env:RELEASE_ENVIRONMENTNAME}"
    $DefinitionName = $env:RELEASE_DEFINITIONNAME
    $TriggeredBy = $env:RELEASE_REQUESTEDFOR
    $TeamEncoded = [uri]::EscapeDataString($env:SYSTEM_TEAMPROJECT)
    $SummaryUri = "${env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI}$TeamEncoded/_apps/hub/ms.vss-releaseManagement-web.hub-explorer?definitionId=${env:RELEASE_DEFINITIONID}&_a=release-summary&releaseId=${env:RELEASE_RELEASEID}"
}
else {
    $Number = $env:BUILD_BUILDNUMBER
    $DefinitionName = $env:BUILD_DEFINITIONNAME
    $TriggeredBy = $env:BUILD_QUEUEDBY
    $TeamEncoded = [uri]::EscapeDataString($env:SYSTEM_TEAMPROJECT)
    $SummaryUri = "${env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI}$TeamEncoded/_build?buildId=${env:BUILD_BUILDID}&_a=summary"
}

# for testing
# Write-Host "Output of variables:"
# Write-Host "AgentJobstatus" $AgentJobstatus
# Write-Host "Number" $Number
# Write-Host "DefinitionName" $DefinitionName
# Write-Host "TriggeredBy" $TriggeredBy
# Write-Host "SummaryUri" $SummaryUri
# Write-Host "Target enviroment" $targetEnv

# Run
Send-Message `
-Number $Number `
-DefinitionName $DefinitionName `
-AgentJobStatus $AgentJobStatus `
-TriggeredBy $TriggeredBy `
-SummaryUri $SummaryUri `
-argetEnv $targetEnv 