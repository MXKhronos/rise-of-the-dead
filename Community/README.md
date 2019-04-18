# Community Gamemode Development
Want to make a community gamemode for Rise Of The Dead? Follow these steps!

## Map Structure
Inside your map model. It should include:
	- ThumbnailCamera (Camera) for the gamemode thumbnail.
	- Map.lua (ModuleScript) for any map related scripts you want to add to the game. (Optional)
	- MapSpace (Folder) for your map(s).

## Map.lua
Map should be a ModuleScript inside the map model, the server will require() the ModuleScript (if it exist) to start. Map itself is running on a sandboxed environment therefore, you will not be able to access Roblox's global variables and functions.

### void Initialize()
Initialize is called when the map is loaded after the server starts.

### void OnPlayerConnect(Player player)
### void OnPlayerDisconnect(Player player)

