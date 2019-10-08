# Module 1 Code Snippets

## Switching to ASP.NET Core

### Web Builder

```cs
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
```

### First Startup
```csharp
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
```

### Inline Middleware

```csharp
app.Use(async (context, next) =>
{
    await context.Response.WriteAsync("Pre Processing\n");

    await next();

    await context.Response.WriteAsync("\nPost Processing");
});
```

### Mapped EndPoints

```cs
app.UseRouting();
app.UseEndpoints(endpoints =>
{
    endpoints.MapGet("/", async context =>
    {
        await context.Response.WriteAsync("Hello World! " +
          "Time is: " + DateTime.Now.ToString("HH:mm:ss"));
    });

    endpoints.MapGet("/testJson", async context =>
    {
        var data = new
        {
            Message = "Hello World",
            Time = DateTime.Now
        };

        string json = JsonConvert.SerializeObject(data);
        
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsync(json);
    });
});
```

## API Controllers

### First Controller

```cs
public class Startup
{
   public void ConfigureServices(IServiceCollection services)
   {
       services.AddMvc()
           .AddMvcOptions(o => {o.SerializerOptions.PropertyNameCaseInsensitive = true;});
           //.AddNewtonsoftJson();
   }


   public void Configure(IApplicationBuilder app)
   {
       app.UseRouting();
       app.UseEndpoints(endpoints =>
       {
           endpoints.MapDefaultControllerRoute();
       });
   }
}

public class HelloController 
{
    public object HelloWorldApi()
    {
        return new
        {
            message = "Hello World",
            time = DateTime.Now
        };
    }
}
```

### Updated Parameterized Route 


```cs
[Route("api/Hello/{name}")]
public object HelloWorldApi(string name)
{
    return new
    {
        message = $"Hello {name}",
        time = DateTime.Now,
        Os = System.Runtime.InteropServices.RuntimeInformation.OSDescription
    };
}
```
### Posting Data

```csharp
[HttpPost,Route("api/Hello")]
public object HelloWorldApi([FromBody] 
                HelloMessageRequest request)
{
    return new
    {
        message = string.Format(request.Message,
                                request.Name),
        time = DateTime.Now
    };
}

public class HelloMessageRequest
{
    public string Message { get; set; }
    public string Name { get; set; }
}
```


### First MVC View Controller

```csharp
public ActionResult Index()
{
    ViewBag.Name = "Rick";
    ViewBag.Message = "Getting Started is never easy to do.";

    return View();
}
```

## View Controllers

### First MVC View
```html
@model  CoreOfDotnetCore.HelloWorldModel
<!DOCTYPE html><html><body>
<h1>Hello World, @Model.Name</h1>

<hr />

<div style="margin: 30px 10px">
    @Model.Message
</div>

<hr />
<small>
    created on: 
    @Model.TimeString
</small>
</body></html>
```

### Add a For Loop String

```html
@foreach (var c in Model.Message)
{
    <span style="padding: 2px;">
        @if (c >= 'A' && c <= 'Z')
        { <b>@c</b> }
        else
        { <span>@c</span> }
    </span>
}
```

### Error Controller Action Method

```csharp
public ActionResult Error()
{
    var errorInfo = HttpContext.Features.Get<IExceptionHandlerPathFeature>();
    
    // Logging can be hooked up here
    
    var exception = errorInfo.Error;
    var path = errorInfo.Path;

    var model = new ErrorModel()
    {
        Message = exception.Message,
        Location = path,
        Exception = exception
    };

    return View(model);
}
```

### Error View

```html
@using Microsoft.Extensions.Hosting
@model  CoreOfDotnetCore.ErrorModel
@inject  IHostEnvironment env
<!DOCTYPE html>
<html>
<body>
<h1>Oops - An Error occurred in the Application</h1>

<hr />

<div style="margin: 30px 10px">
    @Model.Message
</div>

<p>
    The error has been logged and the authorities have been notified.
</p>


@if (env.IsDevelopment())
{
    <label>Stack Trace:</label>

    <pre>@Model.Exception.StackTrace</pre>
}

<p>
    <a href="~/">Back to Safety</a>
</p>

<hr />

Your Application Team

</body>
</html>
```

## Cross Platform

### Enable WSL

```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

### Local Project Cloning in Bash

```bash
cd ~/projects
git clone https://github.com/RickStrahl/DotNetCoreTraining.git
cd DotNetCoreTraining/Code/Module1/CoreOfDotnetCore
```