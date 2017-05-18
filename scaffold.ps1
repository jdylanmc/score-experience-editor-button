<#

    ABSTRACT

    The scaffolding process is used to setup a new solution for Sitecore work on a project to begin.

    Using a templated approach, the scaffolded solution is copied to a directory, then this program is executed to rename
    the various files, projects, solution artifacts, etc. to the name of the project.


    INSTRUCTIONS
    
      1.) Copy the scaffolded solution to a directory where you plan to house the project workspace

      2.) Install the required version of Sitecore into the .\sandbox folder of your solution directory - the .gitignore should be setup to ignore this folder already.
          For this example, it is assumed that the URL of the sandbox site is http://projectname

      3.) Open a command prompt with access in the path to MSBUILD and administrative permissions and run the scaffold.ps1 program with powershell.

          c:\source\projectname> powershell -file scaffold.ps1 -solution "ProjectName" -company "Some Company Name" -site "projectname"

          PARAMETERS

          -solution "Project.Name" - The name of your project.  This should be what you want the solution and project names in the solution to have as a root name.

          -tenant "ProjectName" - The name of your sitecore tenant root element and you area name

          -company "Some Company Name" - the name of the company for which the project is being done

          -site "projectname" - the url of the sandbox site running locally WITHOUT THE http:// on it

          -vsversion "version" - visual studio version if different from 2015. Use Visual Studio notation (11 for VS 2012, 12 for VS 2013 or 14 for VS 2015). Remember for Sitecore 8.2 and higher you should use VS 2015 at least.

#>

Param (
    [Parameter(Mandatory=$True)]
    [string]$solution,

    [Parameter(Mandatory=$True)]
    [string]$tenant,

    [Parameter(Mandatory=$True)]
    [string]$company,

    [Parameter(Mandatory=$True)]
    [string]$site,

    [Parameter(Mandatory=$False)]
    [string]$vsversion="14"
)


function CheckVersion() 
{
    $major = $PSVersionTable.PSVersion.Major;
    $minor = $PSVersionTable.PSVersion.MinorRevision;

	Write-Host "Powershell version on this machine is ${major}.${minor}."; 
        
    if ( $major -lt 3) {
		Write-Host "To run the scaffold script, you must run Powershell version 3.0 or later." -foregroundcolor "red";
        Exit 
    }
}

<#
    The ReplaceInFiles function will find files based on a $filter, look for all occurrances of a $pattern
    and replace the matching text with $replace
#>
function ReplaceInFiles($filter, $pattern, $replace) 
{
    $files = Get-ChildItem -filter $filter -exclude scaffold.ps1 -recurse | 
                Where { ($_.FullName -inotmatch ("^$root\sandbox" -replace "\\","\\")) `
                        -and ($_.FullName -inotmatch ("^$root\packages" -replace "\\","\\")) `
                        -and !$_.PSIsContainer `
                        -and ($_.extension -ne ".dll") `
                        -and ($_.extension -ne ".pdb") `
                        -and ($_.extension -ne ".exe") }

    foreach ($file in $files) 
    {
        (Get-Content $file.FullName) -replace $pattern, $replace | Out-File $file.FullName -Encoding ascii
    }
}


<#
    Begin script execution
#>
CheckVersion

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web

$root = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
. "$root\Automation\shared.ps1"

"Checking if script is running from a folder that contains original files"

if (!(Test-Path .\Rename.Me.Custom.Tests\))
{
    Write-Host "Cannot find original files. Execution Stopped. Please delete all folders except 'sandbox' and copy data from package if process was interrupted." -foregroundcolor "red"
    return
}

" "
"Detecting Sitecore version"
$sitecore = DetectSitecore

$step = 0

"Will now set up local environment"

$step++; "$step. Backing up Web.config. You will thank us for this one later :)"

Copy-Item .\sandbox\Website\Web.config .\sandbox\Website\Web.config.bak

$step++; "$step. Copying license.xml to support unit tests based on Sitecore.FakeDb"

Copy-Item -Force .\sandbox\Data\license.xml .\Rename.Me.Custom.Tests\

$step++; "$step. Renaming solution artifacts to $solution"

"   - Renaming file names"

Get-ChildItem -filter "*Rename.Me*" -recurse | Rename-Item -NewName { $_.name -replace "Rename\.Me","$solution" }

"   - Renaming file contents"

ReplaceInFiles * "Rename\.Me" $solution

"   - Renaming Area folder and Area Registration class"

Get-ChildItem -filter "*RenameMeArea*" -recurse | Rename-Item -NewName { $_.name -replace "RenameMeArea","$tenant" }

"   - Renaming Area references"
ReplaceInFiles *.csproj RenameMeArea $tenant
ReplaceInFiles *.config RenameMeArea $tenant
ReplaceInFiles *.cs RenameMeArea $tenant
ReplaceInFiles *.cshtml RenameMeArea $tenant
ReplaceInFiles *.js RenameMeArea $tenant

$step++; "$step. Renaming company name on the assembly and TDS packages to $company"

ReplaceInFiles AssemblyInfo.cs "Rename Me Company" $company
ReplaceInFiles *.scproj "Rename Me Company" "$([System.Web.HttpUtility]::HtmlEncode($company))"

$step++; "$step. Renaming local site reference to point to http://$site"

"   - Renaming TDS deployment targets"

ReplaceInFiles *.scproj http://renameme "http://$site"

"   - Renaming Sitecore <site> configuration patches for Sandbox profiles"

ReplaceInFiles *.config renameme $site

$step++; "$step. Generating new GUIDs for solution project files and TDS connector"

$guids = @("94D68EEC-1D7C-44C8-B88D-77B13B2EB0C9",
           "3E9DE83C-1950-40EF-9FDF-4F314CCBE3E3",
           "668F676F-70FB-4683-B65F-C22DBBCD2C2A",
           "22FB2DFF-5BB5-4882-91C7-A20C046FF3AA",
           "1FD3AE5D-2764-4DAD-8AAC-8AEFB2A649D3",
           "F9A08539-4186-42FC-B9FD-A9581D9D23C5",
           "050B1C62-63D1-478F-A98F-FCFA240FE4F2",
           "5F0FDFF8-F527-4A42-8F92-F7D7A79F2303",
           "79C7C11D-293A-40B8-AFF5-40196ACEB1FE",
           "A97C277A-BCA5-4500-8021-497905DCF2D2",
           "cfa3e187-8e42-4e43-a4af-8da497648d7d")

foreach ($guid in $guids)
{
    $newguid = [guid]::NewGuid().ToString().ToUpper()

    ReplaceInFiles *.sln $guid $newguid
    ReplaceInFiles *.csproj $guid $newguid
    ReplaceInFiles *.scproj $guid $newguid
}


$step++; "$step. Setup MVC references in solution based on Sitecore release"
<# 
For Reference: 
Sitecore  Razor  MVC
========  =====  ===
   7.0      1    3.0
   7.1      2    4.0 
   7.2      3    5.1
   7.5      3    5.1
   8.0      3    5.1
   8.1      3    5.2
   8.2      3    5.2
#>
" "
" "
"   - For Sitecore $($sitecore.Version) - Copy pre-built config files"
"     ==============================================================="
"   - Copying - .\Automation\Sitecore-Versions\$($sitecore.Version)\packages.config ==> .\$solution.Web\"
Copy-Item -force ".\Automation\Sitecore-Versions\$($sitecore.Version)\packages.config" .\$solution.Web\

# Sitecore nuget feed has different package versions from the Kernal for some Sitecore versions.
$sitecoreNugetVersion = "$($sitecore.Version).$($sitecore.Revision)";
switch ($sitecoreNugetVersion) {
    # Sitecore 7.2 Update 4
    "7.2.150407" { $sitecoreNugetVersion = "7.2.150408"; }
    # Sitecore 7.2 Update 6
    "7.2.160122" { $sitecoreNugetVersion = "7.2.160123"; }
}
ReplaceInFiles packages.config "\$\{sitecore\.nuget\.version\}" $sitecoreNugetVersion

"   - Copying - .\Automation\Sitecore-Versions\$($sitecore.Version)\Web.config ==> .\$solution.Web\Areas\$tenant\Views\"
Copy-Item -force ".\Automation\Sitecore-Versions\$($sitecore.Version)\Web.config" .\$solution.Web\Areas\$tenant\Views\

"   - Copying - .\Automation\Sitecore-Versions\$($sitecore.Version)\nunit.app.config ==> .\$solution.Web\Areas\$tenant\Views\app.config"
Copy-Item -force ".\Automation\Sitecore-Versions\$($sitecore.Version)\nunit.app.config" .\$solution.Custom.Tests\app.config


"   - Copying - .\Automation\README.md ==> .\README.md"
Copy-Item -force ".\Automation\README.md" ".\README.md"

"   - Update README.md file for your project"
ReplaceInFiles README.md "\$\{sitecore\.version\}" "$($sitecore.Version).$($sitecore.Revision)"
ReplaceInFiles README.md "\$\{site\}" $site
ReplaceInFiles README.md "\$\{solution\}" $solution

# Sitecore doesn't provide nuget packages for Sitecore 7.5 and 7.1, so we decided to copy required dlls from Sandbox
if(($sitecore.Version -eq 7.5) -or ($sitecore.Version -eq 7.1) )
{
    $step++; "$step. Copying Sitecore binary dependencies into Libs\Sitecore"

    $libs = @("Lucene.Net.dll", 
            "Sitecore.Analytics.dll", 
            "Sitecore.Buckets.dll", 
            "Sitecore.Kernel.dll",
            "Sitecore.Logging.dll",
            "Sitecore.Mvc.dll",
            "Sitecore.Mvc.Analytics.dll",
            "sitecore.nexus.dll",

            "Sitecore.Update.dll",
            "Sitecore.Zip.dll")

    New-Item -Path ".\Libs\Sitecore" -ItemType Directory -Force   
    foreach ($lib in $libs) 
    {
        "   - Copying - .\sandbox\Website\bin\$lib ==> .\Libs\Sitecore"
        Copy-Item -force ".\sandbox\Website\bin\$lib" .\Libs\Sitecore\
    }
}
$step++; "$step. Add Sitecore and MVC references..."

$references = (Get-Content ".\Automation\Sitecore-Versions\$($sitecore.Version)\references.xml" | out-string) -replace "\$\{sitecore\.nuget\.version\}", $sitecoreNugetVersion;

ReplaceInFiles *.csproj '<Reference Include="Scafolding.References.Placeholder" />' $references;

$step++; "$step. Setup .NET framework version..."

$frameworkDef = (Get-Content ".\Automation\Sitecore-Versions\$($sitecore.Version)\framework.xml");
ReplaceInFiles *.csproj '<TargetFrameworkVersion Name=\"Scafolding.Framework.Placeholder\" />' $frameworkDef

$frameworkDef -match ">([^<]+)<" | Out-null;
$frameworkVersion = $matches[1];
(Get-Content ".\$($solution).Web\web.config") -replace 'targetFramework\=\"[^"]+"', "targetFramework=`"$($frameworkVersion -replace '^[^\d]+', '')`"" | Out-File ".\$($solution).Web\web.config" -Encoding ascii
"   - Solution configured for .NET Framework $($frameworkVersion)";

if(Test-Path ".\Automation\Sitecore-Versions\$($sitecore.Version)\sitecoreassemblypath.xml")
{
    # If current Sitecore version doesn't support the nuget feed, then we should configure TDS projects to look for Sitecore dependencies in the certain folder instead of packages.
    $step++; "$step. Configure TDS projects..."
    ReplaceInFiles *.scproj '<SitecoreAssemblyPath></SitecoreAssemblyPath>' `
        (Get-Content ".\Automation\Sitecore-Versions\$($sitecore.Version)\sitecoreassemblypath.xml")
}

$step++; "$step. Restoring NuGet packages..." 

.\.nuget\nuget.exe restore "$solution.sln"

$step++; "$step. Will now build and deploy Sandbox configuration"

$msBuildPath = "${env:windir}\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe";

# We had an issue with building the project against .NET 4.5.2 on dev instance with more that 1 VS installed. 
If (Test-Path "${env:ProgramFiles(x86)}\MSBuild\$vsversion.0\Bin\MSBuild.exe")
{
    $msBuildPath = "${env:ProgramFiles(x86)}\MSBuild\$vsversion.0\Bin\MSBuild.exe";
}

& $msBuildPath $solution.sln /p:Configuration=Sandbox /p:Platform="Any CPU" /p:VisualStudioVersion=$vsversion.0 /v:normal /nologo

Write-Host "All Done." -foregroundcolor "green";
