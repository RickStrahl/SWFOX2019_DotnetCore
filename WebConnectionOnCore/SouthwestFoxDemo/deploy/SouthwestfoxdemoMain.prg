************************************************************************
*FUNCTION SouthwestfoxdemoMain
******************************
***   Created: 10/06/2019
***  Function: Web Connection Mainline program. Responsible for setting
***            up the Web Connection Server and get it ready to
***            receive requests in file messaging mode.
***
***            You can configure your server with
***            Southwestfoxdemo.exe "config"
***            Southwestfoxdemo.exe "config" "IIS://localhost/w3svc/21/root"
************************************************************************
LPARAMETER lcAction, lvParm1, lvParm2

*** This is the file based start up code that gets
*** the server form up and running
#INCLUDE WCONNECT.H

*** PUBLIC flag allows server to never quit
*** - unless EXIT button code is executed
RELEASE goWCServer
PUBLIC goWCServer

SET TALK OFF
SET NOTIFY OFF


*** Load the Web Connection class libraries
IF FILE("WCONNECT.APP")  
   DO ("WCONNECT.APP") 
ELSE
      DO WCONNECT
ENDIF

*** Optionally add Server Config execution
IF VARTYPE(lcAction) = "C" AND StartsWith(LOWER(lcAction),"config")
         do Southwestfoxdemo_ServerConfig.prg with lvParm1
      RETURN 
ENDIF

*** Load the server - wc3DemoServer class below
goWCServer = CREATE("SouthwestfoxdemoServer")

IF !goWCServer.lDebugMode
      SET DEBUG OFF
      SET STATUS BAR OFF
      SET DEVELOP OFF
      SET RESOURCE OFF
      SET SYSMENU OFF
ENDIF   

IF goWCServer.oConfig.lLiveReloadEnabled
   DO LiveReloadServer
   *** If BrowserSync is running this will refresh the active page
	STRTOFILE(TRANSFORM(DateTime()),"..\web\__CodeUpdate.html")   
ENDIF

IF TYPE("goWCServer")#"O"
   =MessageBox("Unable to load Web Connection Server",48,;
               "Web Connection Error")
   RETURN
ENDIF

*** Make the server live - Show puts the server online and in polling mode
READ EVENTS



*** Check if server is requesting an auto-restart
llAutoRestart = goWcServer.lAutoRestart

ON ERROR
RELEASE goWCServer

SET SYSMENU ON
SET DEBUG ON
SET DEVELOP ON
SET STATUS BAR ON
SET TALK ON

CLOSE DATA
RELEASE all EXCEPT llAutoRestart

 
IF llAutoRestart
   LiveReloadShutdown("DO SouthwestfoxdemoMain.prg")
ELSE
   *** USE THIS FOR DEBUGGING OBJECT HANGING - fires all outstanding DESTROY()
   *** and you should see which objects are hanging
   *SET STEP ON  
   CLEAR ALL
   
   IF Application.StartMode = 0
      ACTIVATE WINDOW COMMAND
      SET RESOURCE ON
   ENDIF
ENDIF



RETURN


**************************************************************
****          YOUR SERVER CLASS DEFINITION                 ***
**************************************************************
DEFINE CLASS SouthwestfoxdemoServer AS WWC_SERVER OLEPUBLIC
*************************************************************
***  Function: This is a subclass of the wwServer class
***            that is application specific. Each Web Connection
***            server you create *MUST* create a subclass of the
***            class and at least implement the Process and
***            SetServerEnvironment methods to  receive requests!
*************************************************************

*** Add any custom properties here
*** These can act as 'global' vars


************************************************************************
* SouthwestfoxdemoServer :: OnInit
******************************************
***  Function: This method fires at the beginning of the server's
***            initialization sequence. It's fired from the Init
***            method and you can return .F. here to cause the
***            server to not load.
***
***            Only use this method to setup any server configuration 
***            that the server needs to configure itself, such as
***            pointing at the configuration file and configuring
***            the configuration object to use
***
***            Don't put application specific initialization logic 
***            into this  in order to maximize server load performance.
***
***            THIS.cAppStartPath returns your application's startup
***            path regardless of start mode (COM, File, IDE). 
***            If you need to override this path in code you should
***            do so here. This value is used to SET DEFAULT TO in
***            the Init() following this code. You can set this value
***            on the WC Status form's Startup Path.
************************************************************************
PROTECTED FUNCTION OnInit

*** If you need to override your application's startup path
*** to something other than the current directory do it here:
*** THIS.cAppStartPath = <your custom path>
*** THIS.cAppIniFile = addbs(THIS.cAppStartPath) + "Southwestfoxdemo.ini"

THIS.cAppName = "Southwestfoxdemo"
THIS.cAppIniFile = addbs(THIS.cAppStartPath) + "Southwestfoxdemo.ini"

*** Custom Server Configuration object - created at bottom of this PRG
*** Server and Process Config Settings are read from the INI above
THIS.oConfig = CREATEOBJECT("SouthwestfoxdemoConfig")
THIS.oConfig.cFileName = THIS.cAppIniFile 


ENDFUNC
* OnInit

************************************************************************
* SouthwestfoxdemoServer :: OnLoad
****************************************
***  Function: This method should be used to set any server properties
***            and any relative paths. You can also use this method
***            to set application specific configuration settings
***            and perform application specific initialization of
***            components paths etc.
***
***            The most common use of this method is to load class
***            libraries and set paths to data folders, configure
***            SQL connections and the like.
***
***            OnLoad() is called exactly once when the first request
***            to this server instance is made. It does not necessarily
***            fire immediately after OnInit() or OnInitCompleted() are
***            fired, but only on the first hit to the server, which
***            may occur much later
************************************************************************
PROTECTED FUNCTION OnLoad

*** This URL is executed when clicking on the Automation Server
*** Form's Exit button. It forces operation through a browser!
THIS.cCOMReleaseUrl=THIS.oConfig.cComReleaseUrl



*** Add persistent SQL Server Connection
#IF WWC_USE_SQL_SYSTEMFILES
    THIS.AddProperty("oSQL", CREATE("wwSQL"))
    IF !THIS.oSQL.Connect(THIS.oConfig.cSQLConnectString)
	    ERROR "Couldn't connect to SQL Service. Check your SQL Connect string in the application startup INI file." 
    ENDIF
#ENDIF

*** Add any of YOUR data paths and code 
*** SET DEFAULT is at EXE/Start path by default
SET PATH TO "..\Data" ADDITIVE   && optional

*** Force .NET version to 4.0
*DO wwDotnetBridge
*InitializeDotnetVersion("V4")  && Use Version 4

*** Add any SET CLASSLIB or SET PROCEDURE code here

ENDFUNC
* OnLoad


************************************************************************
*  SouthwestfoxdemoServer :: OnInitCompleted
****************************************
***  Function: Called after server is initialized but before the first
***            hit and OnLoad() fire.
*** 
***            You rarely need to implement this method unless you
***            need something to fire after the server has initialized
***            but before the first request comes in.
************************************************************************
*!*	PROTECTED FUNCTION OnInitCompleted()
*!*
*!*	*** Any settings you want to make to the server
*!*	IF THIS.lShowServerForm
*!*	  THIS.oServerForm.Caption =This.cServerId + " - " + this.cAppName
*!*	ENDIF
*!*
*!*	ENDFUNC
*   OnInitCompleted


************************************************************************
* SouthwestfoxdemoServer :: Process
******************************
***  Function: This procedure's main purpose is to route incoming
***            requests to individual project PRGs/APPs.
***
***            Routings should be set up for both parameterized
***            urls (wc.dll?Process~Method~Parm1) and scriptmaps
***            (Method.map?Parm1=Value)
************************************************************************
PROTECTED FUNCTION Process
LOCAL lcParameter, lcExtension, lcPhysicalPath

*** Retrieve first parameter
lcParameter=UPPER(THIS.oRequest.Querystring(1))

*** Set up project types and call external processing programs:
DO CASE

     CASE lcParameter == "SWFOXPROCESS"
         DO swfoxprocess with THIS

      *** SUB APPLETS ADDED ABOVE - DO NOT MOVE THIS LINE ***

     CASE lcParameter == "WWMAINT"
        DO wwMaint with  THIS
OTHERWISE
     *** Check for Script Mapped files for: .WC, .WCS, .FXP
     lcExtension = Upper( JustExt(THIS.oRequest.GetPhysicalPath() ) )

     DO CASE

     CASE lcExtension == "SWF"
        DO swfoxprocess with THIS

     *** ADD SCRIPTMAP EXTENSIONS ABOVE - DO NOT MOVE THIS LINE ***

     *** Generic Web Connection Script Template handling
     CASE lcExtension == "WC" OR lcExtension == "WCS" OR ;
          lcExtension == "FXP" OR lcExtension == "MD"
        DO wwScriptMaps with THIS


#IF WWC_LOAD_WEBCONTROLS  
     CASE lcExtension == "WCSX" OR lcExtension == "ASPX"
        DO wwWebPageHandler with THIS
#ENDIF

#IF WWC_LOAD_WWSOAP
     *** Default Web Service Handler
     CASE lcExtension == "WWSOAP"
        DO wwDefaultWebService with THIS
#ENDIF

   OTHERWISE
     	this.ErrorMsg("Unhandled Request","The server is not set up to handle this type of request: ." +  lcExtension)
				
      IF THIS.oConfig.lAdminSendErrorEmail   
         THIS.SendAdminEmail("Web Connection Error: Unhandled Request ." + lcExtension,;
            "The server is not setup to handle this type of extension or route: ." + lcExtension + CRLF + ;
            CRLF +;
            CRLF +;
            "Full Url: " + this.oRequest.GetCurrentUrl(),;
            THIS.oConfig.cAdminEmail,;
            THIS.oConfig.cAdminEmail, .F., .t.)      
      ENDIF								
   ENDCASE


ENDCASE

RETURN
ENDFUNC
* Process

ENDDEFINE
* EOC Southwestfoxdemo


***************************************************************
DEFINE CLASS SouthwestfoxdemoConfig AS wwServerConfig
***************************************************************
*: Author: Rick Strahl
*:         (c) West Wind Technologies, 1999
*:Contact: http://www.west-wind.com
*******&&******************************************************
#IF .F.
*:Help Documentation
*:Topic:
Class Southwestfoxdemo

*:Description:
This class is used as a global configuration object to
contain application global data that persists for the
lifetime of the server.

Optionally you can have sub-application objects for each
Process class implementation.
*:ENDHELP
#ENDIF
****************************************************************


oswfoxprocess = .NULL.

*** ADD CONFIG OBJECT TO CLASS ABOVE - DO NOT MOVE THIS LINE ***

owwMaint = .NULL.

FUNCTION Init

THIS.oswfoxprocess = CREATEOBJECT("swfoxprocessConfig")

*** ADD CONFIG INIT CODE ABOVE - DO NOT MOVE THIS LINE ***

THIS.owwMaint = CREATEOBJECT("wwMaintConfig")

ENDFUNC

ENDDEFINE
*EOC SouthwestfoxdemoConfig


DEFINE CLASS wwMaintConfig as RELATION

cHTMLPagePath = "c:\WebConnectionProjects\SouthwestFoxDemo\Web\"
cDATAPath = ".\"
cVirtualPath = "/SouthwestFoxDemo/"

ENDDEFINE



*** Configuration class for the swfoxprocess Process class
DEFINE CLASS swfoxprocessConfig as wwConfig

cHTMLPagePath = "c:\WebConnectionProjects\SouthwestFoxDemo\Web\"
cDATAPath = ""
cVirtualPath = "/SouthwestFoxDemo/"

ENDDEFINE

*** ADD PROCESS CONFIG CLASSES ABOVE - DO NOT MOVE THIS LINE ***

