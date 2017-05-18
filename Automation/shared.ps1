function DetectSitecore()
{
    Write-Host "Detecting Sitecore..."

    if (!(Test-Path ".\sandbox\Website\sitecore\shell\sitecore.version.xml"))
    {
        throw "No Sitecore detected in the .\sandbox. Please first install Sitecore and then run the setup wizard again"
    }

    $xml = [xml](Get-Content ".\sandbox\Website\sitecore\shell\sitecore.version.xml" -Raw)

    $version = "$($xml.information.version.major).$($xml.information.version.minor)";
    $revision = $xml.information.version.revision;

    Write-Host "Detected $version.$revision"

    Return @{"Version"="$version"; "Revision"="$revision"}
}
