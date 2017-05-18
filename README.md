Local Environment Setup
=======================

**Prerequisites**

* Visual Studio 2013
* TDS (latest version) (http://www.teamdevelopmentforsitecore.com/Download)
* SQL Server 2012+ / SQL Server 2014+
* nodejs and less (https://brainjocks.atlassian.net/wiki/display/PER/Copy+of+As+part+of+MSBuild)

**Before opening the solution in Visual Studio:**

* Install **Sitecore 8.2.170407** into `<solution root>\sandbox`. Use **sc823** as your site name.

* Install MongoDb. I recommend installing Mongo as a service and configure it to start automatically

```
#!none
set mongodbpath=c:\Program Files\MongoDB\Server\3.0
mkdir "%mongodbpath%\data"
mkdir "%mongodbpath%\data\log"
mkdir "%mongodbpath%\data\db"
echo logpath=%mongodbpath%\data\log\mongod.log> "%mongodbpath%\mongod.cfg"
echo dbpath=%mongodbpath%\data\db>> "%mongodbpath%\mongod.cfg"
sc.exe create MongoDB binPath= "\"%mongodbpath%\bin\mongod.exe\" --service --config=\"%mongodbpath%\mongod.cfg\"" DisplayName= "MongoDB" start= "auto"
net start MongoDB

```

* If you are running multiple Sitecore instances please update `App_Config\ConnectionString.config` to make sure xDB databases are prefixed with your instance name:

```xml
<add name="analytics" connectionString="mongodb://localhost/customer_analytics"/>
<add name="tracking.live" connectionString="mongodb://localhost/customer_tracking_live"/>
<add name="tracking.history" connectionString="mongodb://localhost/customer_tracking_history"/>
<add name="tracking.contact" connectionString="mongodb://localhost/customer_tracking_contact"/>
```

* Add your `score.license` to `<sandbox>\website\App_Data` and restart your IIS app to activate the license.  If you don't find the folder then you will have to create it.

* I would also recommend that you copy your `Web.config` to `Web.config.bak`.  It is located under <sandbox>\Website\Web.config.

**Now Open your solution in Visual Studio.**

* Restore all NuGet packages

* Open Tools -> NuGet Package Manager -> Powershell Console and make sure you see SCORE and SCORE Bootstrap UI deploy. If you don't see anything in the console, re-open your solution and pull up the console again. 

* Install Sitecore Powershell Extensions if it is not already installed
https://marketplace.sitecore.net/en/Modules/Sitecore_PowerShell_console.aspx

  * Once downloaded then log into sitecore admin

  *  Desktop > Development Tools > Installation Wizard

  * Install it and you should be set


* Rebuild and Deploy ( right click on the Solution in Visual Studio and click Deploy Solution )


```
If you don't have Ruby installed on your computer then you will need 
it in order to install SASS below. To install it click on 
the link below and download and install it:

http://rubyinstaller.org/
```

```
If you receive .css errors in your build you will need the LESS compiler
installed on your machine.  To install it just do the following:
Open Powershell or DOS window
Type gem install sass
Hit Enter and it should install it for you
```

```
If your project setup use LESS compiler. You need NMP installed.
To install it click on the link below and download and install it:

https://nodejs.org/en/

After that do the following to install LESS compiler:
Open Powershell or DOS window
Type npm install -g less
Hit Enter and it should install it for you
```

```
If you receive license.xml errors in your build you will need 
to place the sitecore license under each test project.
Ex sc823.Custom.Tests\License.xml
```

* Please also verify you are running the right version of SCORE with a valid license by going to `http://sc823/score/about/version`


* For local developer environments add these lines before ```<system.web>``` node:
```
<!-- Make TDS Sync in Visual Studio ignore custom error pages in order to work properly -->
<location path="_DEV">
   <system.webServer>
       <httpErrors errorMode="Custom" existingResponse="Auto" />
   </system.webServer>
</location>
```
