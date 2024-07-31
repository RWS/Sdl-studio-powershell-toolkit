
namespace DependencyResolver
{
    using System;
    using System.Collections;

    public class MemoryResource
    {
        public string Path { get; set; }

        public Uri Uri { get; set; }

        public Uri UriSchema { get; set; }

        public string UserNameOrClientId { get; set; }

        public string UserPasswordOrClientSecret { get; set; }

        public bool IsWindowsUser { get; set; }

        public string[] TargetLanguageCodes { get; set; }
    }
}
