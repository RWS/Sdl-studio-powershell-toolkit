namespace DependencyResolver
{
    using System;
    using System.Reflection;

    public static class ReflectionHelper
    {
        public static void CallEnsurePluginRegistryIsCreated(Type fileBasedProjectType)
        {
            // Get the MethodInfo object for the private static method using BindingFlags
            MethodInfo methodInfo = fileBasedProjectType.GetMethod(
                "EnsurePluginRegistryIsCreated",
                BindingFlags.NonPublic | BindingFlags.Static) ?? throw new InvalidOperationException("Could not find the method EnsurePluginRegistryIsCreated");

            // Invoke the private static method
            methodInfo.Invoke(null, null);
        }
    }
}
