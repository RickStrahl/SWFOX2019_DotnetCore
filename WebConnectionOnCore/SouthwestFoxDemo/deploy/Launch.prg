****************************************************************************
*  Launch.prg   
*  -- Web Connection Application Launch Helper
**********************************************************
***  This is an optional tool to help you launch Web Connection
***  applications more easily. It's completely optional but makes
***  easier to launch especially modes that require starting up support
***  applications like IISExpress and/or Browser sync.
***
***  You can still do:   
***
***        DO SouthwestfoxdemoMain.prg 
***
***  and then manually switch to a browser and or start IISExpress
***  or BrowserSync manually.
***
***  Function: Launches a Web Connection Server in various modes
***            and opens a Web page to the appropriate Web location.
*** 
***      Pass:  lcType:         "IIS"
***                             "IISEXPRESS"
***                             "BROWSERSYNC"
***                             "BROWSERSYNCIISEXPRESS"
***                             "NONE" or "SERVER"
*** 
***             llNoBrowser:    If .T. doesn't open a browser window
*** 
***  Examples:
*** 
***  LAUNCH()                        - Launches IIS and opens browser
***  LAUNCH("IISEXPRESS")            - Launches IIS Express & opens browser
***  LAUNCH("IIS",.T.)        - Launch IIS and don't open browser 
***  LAUNCH("NONE")                  - Just launch the Server
*********************************************************************************
LPARAMETER lcType, llNoBrowser
LOCAL lcUrl, lcLocalUrl, llIsIISExpress, lcAppName, ;
      lcScriptMap, lcFiles, lcWcPath, lcVirtual

*** Generated Defaults
lcVirtual = "SouthwestFoxDemo"
lcAppName = "Southwestfoxdemo"
lcScriptMap = "swf"
lcWcPath = ADDBS("C:\WEBCONNECTION\FOX\")
lcWebPath = LOWER(FULLPATH("..\web"))
lcIisDomain = "localhost"                && Change manually if you use a different domain with IIS
llIisExpress = .T.


IF VARTYPE(lcType) = "L"
   IF llIISExpress 
      lcType = "IISEXPRESS"
   ELSE
      lcType = "IIS"
   ENDIF
ELSE
   lcType = UPPER(lcType)
   DO CASE 
      CASE lcType = "IIS"
      CASE lcType = "BROWSERSYNC"
      CASE lcType = "IISEXPRESS"
      CASE lcType = "BROWSERSYNCIISEXPRESS"
        llNoBrowser = .T.  && Browser Sync will do it
      CASE lcType = "NONE" OR lcType = "SERVER"
        llNoBrowser = .T.
        lcType = "IIS"  && doesn't launch anyting
      CASE lcType = "HELP"
       DO Console WITH "GOURL","https://webconnection.west-wind.com/docs/_5h60q6vu5.htm#launch-modes"
       RETURN
   ENDCASE
ENDIF

llNoBrowser = IIF(EMPTY(llNoBrowser),.f.,.t.)


********************************
*** SET UP ENVIRONMENT AND PATHS
********************************

*** Optionally release everything before you run
* RELEASE ALL
* SET PROCEDURE TO
* SET CLASSLIB TO

*** Reference Web Connection Folders 
*** so Web Connection Framework programs can be found
*** GENERATED BY PROJECT WIZARD: Change if paths change
SET PATH TO (lcWcPath + "classes") ADDITIVE
SET PATH TO (lcWcPath) ADDITIVE
SET PATH TO (lcWcPath + "tools") ADDITIVE


***********************************************************
*** START UP WEB SERVER (IIS Express and BrowserSync only)
***********************************************************
lcUrl = "http://localhost/" + lcVirtual

IF lcType == "IISEXPRESS" OR lcType == "BROWSERSYNCIISEXPRESS"
    *** Launch IIS Express on Port 7000
    DO CONSOLE WITH "IISEXPRESS",lcWebPath,7000,"/","NONAVIGATE"    
    lcUrl = STRTRAN(lcUrl,"localhost/" + lcVirtual,"localhost:7000")
ENDIF
IF lcType == "IIS"
   IF !EMPTY(lcIisDomain)
       lcUrl = STRTRAN(lcUrl,"/localhost/","/" + lcIisDomain +"/")
   ENDIF
ENDIF


*** BROWSERSYNC or BROWSERSYNCIISEXPRESS Options
IF AT("BROWSERSYNC",lcType) > 0
   IF AT("IISEXPRESS",lcType) >0
      lcProxyUrl = "localhost:7000"
      lcUrl = "http://localhost:3000"
   ELSE
       lcProxyUrl = lcIisDomain + "/" + lcVirtual
	   lcUrl = "http://localhost:3000/" + lcVirtual
   ENDIF
   
   lcFiles = "**/*." + lcScriptMap + ", **/*.wcs, **/*.wc, **/*.md, **/*.css, **/*.js, **/*.ts, **/*.htm*"
   LaunchBrowserSync(lcProxyUrl,lcWebPath,lcFiles)
ENDIF



ACTIVATE SCREEN
CLEAR
lnOldFont = _Screen.FontName
lnOldFontSize =  _Screen.FontSize
_Screen.FontName = "Consolas"
_Screen.FontSize = 19



**********************
*** LAUNCH WEB BROWSER
**********************
? "Running:" 
? "DO Launch.prg " + IIF(lcType == "IISEXPRESS" OR lcType == "BROWSERSYNCIISEXPESS",;
                        [WITH "IISEXPRESS"],;
                        [WITH "IIS"])
? ""
? ""
? "Web Server used:"
? IIF(lcType == "IISEXPRESS","IIS Express","IIS")
?
IF lcType == "IISEXPRESS"
   ? "Launched IISExpress with:"
   ? [DO console WITH "IISExpress","..\Web",7000]
   ?
ENDIF

IF !llNoBrowser
    DO CONSOLE WITH "GOURL",lcUrl
    ? "Launching Web Url:" 
    ? lcUrl
    ? 
ENDIF    

***************************************
*** LAUNCH FOXPRO WEB CONNECTION SERVER
***************************************

? "Server executed:"
? "DO " + lcAppName + "Main.prg"

*** Start Web Connection Server
DO ( lcAppName + "Main.prg")

RETURN

************************************************************************
*  BrowserSync
****************************************
***  Function: Live Reload of Web Browser on save operations
***            for files in the Web folder. Make a change,
***            save, and the browser reloads the active page
***            Typically runs on:
***            http://localhost:3000/SouthwestFoxDemo 
***    Assume: Install Browser Sync requires Node/NPM:
***            npm install -g browser-sync
***            https://browsersync.io/
***      Pass: lcUrl   -  your local Web url
***            lcPath  -  local path to the Web site
***            lcFiles -  file specs for files to monitor
***            llLaunchBrowser - if .T. launches the browser
***            all parameters are optional
************************************************************************
FUNCTION LaunchBrowserSync(lcUrl, lcPath, lcFiles, llLaunchBrowser)
LOCAL lcBrowserSyncCommand

IF EMPTY(lcUrl)
   *** Using IIS
   lcUrl = "localhost/SouthwestFoxDemo"

   *** Using IIS Express
   lcUrl = "localhost:7000"
ENDIF


IF EMPTY(lcPath)
   lcPath = lower(fullpath("..\web"))
ELSE  
   lcPath = lower(fullpath(lcPath))
ENDIF

IF EMPTY(lcFiles)
   lcFiles = "**/*.swf, **/*.wcs, **/*.wc, **/*.md, **/*.css, **/*.js, **/*.ts, **/*.htm*"
ENDIF

lcOldPath = CURDIR()
CD (lcPath)

* start - removed auto-start
lcBrowserSyncCommand = "browser-sync start " +;
                       "--proxy " + lcUrl + " " + ;
                       "--files '" + lcFiles + "'"
                       
RUN /n cmd /k &lcBrowserSyncCommand

WAIT WINDOW "" TIMEOUT 1.5
CD (lcOldPath)

ENDFUNC
*   BrowserSync