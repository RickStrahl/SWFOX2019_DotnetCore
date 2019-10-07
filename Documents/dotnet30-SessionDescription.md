# An Overview of .NET Core and ASP.NET Core for the FoxPro Developer

NET Core is a new version of .NET that is cross platform, very high performance, and includes many new features and improvements over the original Windows-only .NET Framework. Yes - it's very important to understand that this is a different kind of framework.


These versions of .NET are similar but they are not 100% compatible and .NET Core brings an entirely new development paradigm to the .NET eco system with better and more open tooling, multi-platform support and many new enhancements.

In this session, we'll take a high level look at how .NET Core works and how it is different than full framework .NET and how that affects its relationship with Visual FoxPro. In the past, FoxPro has been able to play with .NET, and that is still true—with a lot more limitations—in .NET Core. The platform isn't integrated into Windows any more nor is it even Windows-centric and it doesn't support many Windows-centric features like STA threading in the built-in frameworks. This changes the relationship with FoxPro considerably as traditional .NET tooling and approaches do not work in .NET. You can't use COM Interop with .NET Core Components (or wwDotnetBridge as is), nor easily run FoxPro components from ASP.NET Core Web applications. We'll examine a few different interop scenarios and provide some guidelines when it makes sense to use .NET Framework or .NET Core.

This session is an overview of functionality and trade offs and as such, light on code and heavy on architecture and concepts that discusses high level architecture and overall concepts.

You will learn:

* What .NET Core is
* How .NET Core differs from .NET Framework
* What you can do with .NET Core using FoxPro
* What you lose by using .NET Core vs. .NET Framework

> #### Prerequisites
> Some familiarity with .NET Platform. Some experience building .NET Interop related features is recommended but not required. This session focuses on high level guidance rather than specific coding concepts.