return {
  ssh_domains = {
    {
      -- This name identifies the domain
      name = "test",
      -- The hostname or address to connect to. Will be used to match settings
      -- from your ssh config file
      remote_address = "localhost:2000",
      -- The username to use on the remote host
      username = "root",
    }
  },
}
