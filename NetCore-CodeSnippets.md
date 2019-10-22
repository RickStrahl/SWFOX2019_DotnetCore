
# 

### Create a new project
```ps
cd ~\projects
md FirstDotnet
cd FirstDotnet
dotnet new
```

### Build and Run

```ps
dotnet run
```


### Add ASP.NET

Change to Web SDK:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
```
And add Host Builder and Inline Middleware

```cs
using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace firstdotnet
{
    class Program
    {
        static void Main(string[] args)
        {
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                })
                .Build()
                .Run();
        }
    }

    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        { }

        public void Configure(IApplicationBuilder app,
                              IWebHostEnvironment env)
        {
            app.Run(async (context) =>
            {
                await context.Response.WriteAsync(
                       "Hello World. The Time is: " +
                       DateTime.Now);
            });
        }
    }
}
```


## Add some Middleware 

```cs
app.Use( async (context, next)=> {
    context.Response.WriteAsync("before...");
    await next();
    context.Response.WriteAsync("...after...");
});
```


## Add MVC Controller

Add NewtonSoft package reference
```xml
<ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Mvc.NewtonsoftJson" Version="3.0.0" />
</ItemGroup>
```

Then restore:

```ps
dotnet restore
dotnet build
```

In `ConfigureServices()`:

```cs
svc.AddMvc()
   .AddNewtonsoftJson();
```

in `Configure()`:

```cs
app.UseStaticFiles();

// MVC
app.UseRouting();

app.UseEndpoints(endpoints =>
{
    endpoints.MapGet("/", async context => {
        await context.Response.WriteAsync(
           "Hello World! Test. Time is: " +
            DateTime.Now.ToString("HH:mm:ss"));
    });

    endpoints.MapDefaultControllerRoute();
});
```

Create a controller:

```csharp
public class HelloController : Controller
{
   // json
   [Route("hello/{name?}")]
   public object Hello(string name)
   {
       var model = new HelloModel
       {
           Name = name  ?? "Rick",
           Message = "Getting Started Is Never Easy To Do.",
           TimeStamp = DateTime.UtcNow
       };
       
       return model;
   }

    // html
   [Route("hellopage/{name?}")]
   public ActionResult HelloPage(string name)
   {
       var model = new HelloModel {Name = name ?? "Rick", Message = "Getting Started Is Never Easy To Do.", Timestamp = DateTime.UtcNow};
       return View(model);
   }
}

public class HelloModel
{
    public string Name { get; set; }
    public string Message { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public string Platform { get; set; } = System.Runtime.InteropServices.RuntimeInformation.OSDescription;
}
```

### Add a View
HelloWorld View:

```html
@model firstdotnet.HelloModel

<h1>Hello @Model.Name</h1>


<hr/>
<div style="font-size: 0.8em">
    @System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription

    &bull;

    @System.Runtime.InteropServices.RuntimeInformation.OSDescription

    &bull;

    @DateTime.Now.ToString()
</div>
```

### Creating a Dotnet Tool WebConnectionServer

```ps
dotnet tool install -g WebConnectionWebServer
WebConnectionWebServer --WebRoot c:\Projects\wwthreads\web
```

### Create Package in Project

```xml
<IsPackable>true</IsPackable>
<PackAsTool>true</PackAsTool>
<ToolCommandName>WebConnectionWebServer</ToolCommandName>
<PackageOutputPath>./bin/nupkg</PackageOutputPath>
<GeneratePackageOnBuild>true</GeneratePackageOnBuild>
```    

### Publish Self Contained and Shared

```ps
# Self Contained exe File
dotnet publish -c Release /p:PublishSingleFile=true /p:PublishTrimmed=true  `
       -r win-x64 -o ./bin/ExeFile

# Plain Published folder with Shared Runtime installed
dotnet publish -c Release  -o ./bin/Publish
```

# Create Class for wwDotnetCoreBridge

```ps
md NetLib
cd NetLib
dotnet new classlib
```

Customize the class:

```cs
using System;

namespace Netlib
{
    public class NetLib
    {
        public string HelloWorld(string name)
        {
            return "Hello " + name;
        }

        public int Add(int num1, int num2)
        {
            return num1 + num2;
        }
}
}
```

Publish it:

```ps
dotnet publish -c Release
```

Call it:

```foxpro
do wwDotNetBridge
LOCAL loBridge as wwDotNetBridge
loBridge = CREATEOBJECT("wwDotnetCoreBridge")

*** Load a .NET Core Assembly
IF !loBridge.Loadassembly(".\NetLib\bin\Release\netstandard2.0\publish\NetLib.dll")
   ? "Unable to load assembly: " + loBridge.cErrorMsg
   RETURN
ENDIF

loNet = loBridge.CreateInstance("Netlib.NetLib")

? loNet.HelloWorld("Rick")
? loNet.Add(1,10)
```
