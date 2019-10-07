CLEAR
SET MEMOWIDTH TO 255

do wwDotNetBridge
LOCAL loBridge as wwDotNetBridge
loBridge = CREATEOBJECT("wwDotnetCoreBridge")

? loBridge.GetDotnetVersion()
?
?


*** Load a .NET Core Assembly
IF !loBridge.Loadassembly(".\NetCoreFromFoxPro\NetCoreFromFoxPro\bin\Debug\netcoreapp3.0\NetCoreFromFoxPro.dll")
   ? "Unable to load assembly: " + loBridge.cErrorMsg
   RETURN
ENDIF

loNet = loBridge.CreateInstance("NetCoreFromFoxPro.DotnetSamples")

? "*** Calling Hello World:"
? loNet.HelloWorld("rick")
?

? "*** Returning a Person"
loPerson = loNet.GetPerson()
? loPerson
? loPerson.Name
? loPerson.Company
? loPerson.Entered
?

? "*** Passing a Person"
loPerson.Company = "East Wind Technologies"
? loNet.SetPerson(loPerson)



*** Create a built-in .NET class and run a method
loHttp = loBridge.CreateInstance("System.Net.WebClient")
loHttp.DownloadFile("https://west-wind.com/files/MarkdownMonsterSetup.exe",;
                    "MarkdownMonsterSetup.exe")


*** Get all the local User Certificates
loStore = loBridge.CreateInstance("System.Security.Cryptography.X509Certificates.X509Store")

? loBridge.cErrorMsg

*** Grab a static Enum value
leReadOnly = loBridge.GetEnumvalue("System.Security.Cryptography.X509Certificates.OpenFlags.ReadOnly")

*** Use the enum value
loStore.Open(leReadOnly)   && 0 - if value is known

*** Returns a .NET Collection of store items
laCertificates = loStore.Certificates

*** Collections don't work over regular COM Interop
*** so use indirect access
lnCount = loBridge.GetProperty(laCertificates,"Count")

*** Loop through Certificates
FOR lnX = 0 TO lnCount -1
	*** Access collection item indirectly using extended syntax
	*** that supports nested objects and array/collection [] brackets
	LOCAL loCertificate as System.Security.Cryptography.X509Certificates.X509Certificate2	
	loCertificate = loBridge.GetProperty(loStore,"Certificates[" + TRANSFORM(lnX) + "]")
			
	IF !ISNULL(loCertificate)
		? loCertificate.FriendlyName
		? loCertificate.SerialNumber
		? loCertificate.GetName()
		*? loBridge.GetPropertyEx(loCertificate,"IssuerName.Name")
	ENDIF
ENDFOR

