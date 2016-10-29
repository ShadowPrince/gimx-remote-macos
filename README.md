## GIMX remote client
This is GIMX (Game Input MultipleXer, http://gimx.fr) remote client, capable of sending keyboard inputs as a controller to the GIMX server.

### Usage
1. Startup GIMX instance using `gimx --config CONFIG.xml --src IP:PORT --port TTY --type DS4`, where:
  * CONFIG - your config
  * IP:PORT - desired IP:PORT 
  * TTY - /dev/ttyUSB[X]
  * **important: --src argument should always go before --port!**
2. Start `gimx-remote-macos`, load configuration using `Select config`
1. Enter `IP:PORT`, press connect
1. Activate gamepad area by clicking on it

If everything's done you should see your input in gamepad area. If the area is grey it means that it's not active.
