using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Westwind.AspNetCore.LiveReload;


namespace CoreOfDotnetCore
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
        {
            if (services == null)
            {
                throw new ArgumentNullException(nameof(services));
            }

            var provider =services.BuildServiceProvider();
            var env = provider.GetService<IWebHostEnvironment>();
            
            if (env.IsDevelopment()) { 
                services.AddMvc()
                    .AddNewtonsoftJson()
                    .AddRazorRuntimeCompilation();

            }
            else
            {
                services.AddMvc()
                    .AddNewtonsoftJson();
            }
                   
        }


        public void Configure(IApplicationBuilder app, IHostEnvironment env)
        {

            //app.UseLiveReload();

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            { 
                // route to an exception
                app.UseExceptionHandler("/hello/error");
            }

            //app.UseDefaultFiles();
            //app.UseStaticFiles();
            

            // Inline Middleware
            //app.Use(async (context, next) =>
            //{
            //    //context.Response.ContentType = "text/plain";

            //    await context.Response.WriteAsync("Pre Processing\n");

            //    await next();

            //    await context.Response.WriteAsync("\nPost Processing");
            //});




            //// Terminating EndPoint
            //app.Run(async (context) =>
            //{
            //    //context.Response.ContentType = "text/plain";
            //    await context.Response.WriteAsync(
            //           "Hello World. The Time is: " + 
            //           DateTime.Now);                            
            //});





            //// Inline Routed Map
            //app.UseRouting();
            //app.UseEndpoints(endpoints =>
            //{

            //    endpoints.MapGet("/", async context =>
            //    {
            //        await context.Response.WriteAsync(
            //           "Hello World! Test. Time is: " +
            //           DateTime.Now.ToString("HH:mm:ss"));
            //    });

            //    endpoints.MapGet("/testJson", async context =>
            //    {
            //        var data = new
            //        {
            //            Message = "Hello World",
            //            Time = DateTime.Now
            //        };

            //        string json = JsonConvert.SerializeObject(data);

            //        context.Response.ContentType = "application/json";
            //        await context.Response.WriteAsync(json);

            //    });
            //});

            // MVC
            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapDefaultControllerRoute();
            });
        }
    }


    public class HelloController : Controller
    {
        public ActionResult Index()
        {
            var model = new HelloWorldModel
            {
                Name = "Rick",
                Message = "Getting Started Is Never Easy To Do.",
            };
            return Json(model);
        }

        //public ActionResult Index()
        //{
        //    ViewBag.Message = "Rick";
        //    ViewBag.Message = "Getting Started is never easy to do.";

        //    return View();
        //}


        [Route("api/Hello/{name}")]
        public ActionResult HelloWorldApi(string name)
        {
            if (string.IsNullOrEmpty(name))
                return new NotFoundResult();
            return Json(new
            {
                Message = $"Hello {name}",
                Time = DateTime.Now,
                Framework = RuntimeInformation.FrameworkDescription,
                Os = RuntimeInformation.OSDescription
            });
        }

        [HttpPost,Route("api/Hello")]
        public object HelloWorldApi([FromBody] HelloMessageRequest request)
        {
            try
            {
                return new
                {
                    Message = string.Format(request.Message, request.Name),
                    Time = DateTime.Now,
                    Framework = RuntimeInformation.FrameworkDescription,
                    Os = RuntimeInformation.OSDescription
                };
            }
            catch (Exception ex)
            {
                return new {IsError = true, Message = ex.Message};
            }
        }


        public ActionResult Throw()
        {
            throw new ApplicationException("Throwing an exception - catch it if you can!");
        }


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

    }

    public class HelloMessageRequest
    {
        public string Message { get; set; }
        public string Name { get; set; }
    }

    public class HelloWorldModel
    {
        public string Message { get; set; }
        public string Name { get; set; }
        public DateTime Time { get; set; } = DateTime.Now;

        public string TimeString => Time.ToString("HH:mm:ss");
    }


    public class ErrorModel
    {
        public string Message { get; set; }

        public string Location { get; set; }

        public Exception Exception { get; set; }
    }

}
