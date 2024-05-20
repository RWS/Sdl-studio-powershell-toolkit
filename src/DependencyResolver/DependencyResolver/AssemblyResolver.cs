namespace DependencyResolver
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Reflection;

    public class AssemblyResolver
    {
        private const string LibraryExtension = ".dll";
        private readonly string _appPath;

        public AssemblyResolver(string appPath)
        => _appPath = appPath;

        public void Resolve()
        => AppDomain.CurrentDomain.AssemblyResolve += ResolveDependencies;

        private Assembly ResolveDependencies(object sender, ResolveEventArgs e)
        => LoadAssembly(e.Name.Split(',').FirstOrDefault());

        public bool AssemblyExists(string assemblyName)
        => File.Exists(_appPath + assemblyName + LibraryExtension);

        private Assembly LoadAssembly(string assemblyName)
        => assemblyName != null && AssemblyExists(assemblyName)
            ? Assembly.LoadFrom(_appPath + assemblyName + LibraryExtension)
            : null;
    }
}
