# Server Check
Checks to see that servers are online and working as intended.

So far the only checks it does is:

**Hyper-V**: It checks the servers running status i.e. Running, Paused, Stopped...etc
If it comes back anything bar "Running" it will error in the output and log.

**Ping**: Pings the server(s).

**WMI**: Tries to connect to the server WMI.

**Admin Share**: It tests if it can connect to the servers admin share (\\[servername]\c$)
