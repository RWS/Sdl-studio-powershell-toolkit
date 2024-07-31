namespace DependencyResolver
{
    using System;

    public class CredentialStore
    {
        public System.Uri ServerUri { get; private set; }

        public string UserName { get; private set; }

        public string Password { get; private set; }

        public CredentialStore(
            string uri,
            string userName,
            string password)
        {
            ServerUri = new System.Uri(uri);
            UserName = userName;
            Password = password;
        }
    }
}
