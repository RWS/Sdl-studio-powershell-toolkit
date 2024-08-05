using log4net;
using log4net.Repository.Hierarchy;
using log4net.Appender;
using System.Linq.Expressions;
using log4net.Config;
using System.Xml;

namespace DependencyResolver
{
    public class Log4NetResolver
    {
        private static string log4netConfig = @"<?xml version=""1.0"" encoding=""utf-8""?>
<configuration>
  <configSections>
    <section name=""log4net"" type=""log4net.Config.Log4NetConfigurationSectionHandler, log4net"" />
  </configSections>
  
  <startup useLegacyV2RuntimeActivationPolicy=""true"">
    <supportedRuntime version=""v4.0"" sku="".NETFramework,Version=v4.8"" />
  </startup>
  
  <runtime>
    <NetFx40_PInvokeStackResilience enabled=""1"" />
    <legacyCorruptedStateExceptionsPolicy enabled=""true"" />
    <ThrowUnobservedTaskException enabled=""true"" />
    <assemblyBinding xmlns=""urn:schemas-microsoft-com:asm.v1"">
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.Extensions.DependencyModel"" publicKeyToken=""adb9793829ddae60"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-6.0.0.0"" newVersion=""6.0.0.0"" />
      </dependentAssembly>
      <!--
      <dependentAssembly>
        <assemblyIdentity name=""icu.net"" publicKeyToken=""416fdd914afa6b66"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-2.7.0.0"" newVersion=""2.7.0.0"" />
      </dependentAssembly>
      -->
      <dependentAssembly>
        <assemblyIdentity name=""System.Memory"" publicKeyToken=""cc7b13ffcd2ddd51"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-4.0.1.2"" newVersion=""4.0.1.2"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.Data.SqlClient"" publicKeyToken=""23ec7fc2d6eaa4a5"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-5.0.0.0"" newVersion=""5.0.0.0"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.Extensions.Logging.Abstractions"" publicKeyToken=""adb9793829ddae60"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.0.1"" newVersion=""8.0.0.1"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.Extensions.DependencyInjection.Abstractions"" publicKeyToken=""adb9793829ddae60"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.0.1"" newVersion=""8.0.0.1"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""System.Buffers"" publicKeyToken=""cc7b13ffcd2ddd51"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-4.0.3.0"" newVersion=""4.0.3.0"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""System.Runtime.CompilerServices.Unsafe"" publicKeyToken=""b03f5f7f11d50a3a"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-6.0.0.0"" newVersion=""6.0.0.0"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""System.Threading.Tasks.Extensions"" publicKeyToken=""cc7b13ffcd2ddd51"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-4.2.0.1"" newVersion=""4.2.0.1"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.Web.WebView2.Core"" publicKeyToken=""2a8ab48044d2601e"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-1.0.2210.55"" newVersion=""1.0.2210.55"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.Extensions.Options"" publicKeyToken=""adb9793829ddae60"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.0.2"" newVersion=""8.0.0.2"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""System.Diagnostics.DiagnosticSource"" publicKeyToken=""cc7b13ffcd2ddd51"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.0.0"" newVersion=""8.0.0.0"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""System.Text.Json"" publicKeyToken=""cc7b13ffcd2ddd51"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.0.3"" newVersion=""8.0.0.3"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""System.Text.Encodings.Web"" publicKeyToken=""cc7b13ffcd2ddd51"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.0.0"" newVersion=""8.0.0.0"" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name=""Microsoft.AspNetCore.Http.Connections.Common"" publicKeyToken=""adb9793829ddae60"" culture=""neutral"" />
        <bindingRedirect oldVersion=""0.0.0.0-8.0.3.0"" newVersion=""8.0.3.0"" />
      </dependentAssembly>
    </assemblyBinding>
  </runtime>
  
  <log4net>
    <!-- Set levels to DEBUG for extended logging information -->
    <appender name=""RollingFile"" type=""Sdl.Desktop.Logger.LocalUserAppDataFileAppender, Sdl.Desktop.Logger"">
    </appender>
    <!-- output to debug string -->
    <appender name=""OutputDebug"" type=""log4net.Appender.OutputDebugStringAppender"">
      <layout type=""log4net.Layout.PatternLayout"">
        <conversionPattern value=""%date [%thread] %-5level %logger [%property{NDC}] - %message%newline"" />
      </layout>
    </appender>
    <root>
      <level value=""INFO"" />
      <appender-ref ref=""RollingFile"" />
      <appender-ref ref=""OutputDebug"" />
    </root>
    <logger name=""Sdl.TranslationStudio"">
      <level value=""INFO"" />
    </logger>
    <logger name=""Sdl.Desktop"">
      <level value=""INFO"" />
    </logger>
    <logger name=""Sdl.ProjectApi"">
      <level value=""INFO"" />
    </logger>
    <logger name=""Licensing"">
      <level value=""INFO"" />
    </logger>
    <!--
    <logger name=""Sdl.MultiTerm"">
      <level value=""DEBUG""/>
    </logger>
    -->
  </log4net>
</configuration>";

        public static void ConfigureLog4NetFromString()
        {
            var log4netConfig = new XmlDocument();
            log4netConfig.LoadXml(Log4NetResolver.log4netConfig);

            var repo = LogManager.CreateRepository("NETCoreRepository");
            XmlConfigurator.Configure(repo, log4netConfig.DocumentElement);
        }
    }
}
