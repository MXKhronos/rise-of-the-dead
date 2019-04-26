# Community Project Development
Want to make a community gamemode for Rise Of The Dead? Follow these steps! I, myself, also use this for making the WeaponsKing gamemode.

---
### Contents
- [Map Structure](#map-structure)
- [Scripts](#scripts)
- - [Map Script](#map-script)
- - [Allowed Scripts](#allowed-scripts)
- [Publishing](#publishing)


---
### Map Structure
**Required**: It is recommended to install the Helix Nebula Devkit to create a new project.

1. Create a new file on Roblox Studio and open the devkit from Plugins.
2. With the devkit, you can simply create a new project by clicking **New Project**.
3. Choose a project template. Blank Project for creating a gamemode from strach or select Template Map if you want to build on top of it.
4. After you have created a new project, you will see 6 new objects in your workspace. 

#### Workspace
| ClassName | Name | Description |
| --- | --- | --- |
| Folder | Environment | This is where you place all the parts which are part of the environment. |
| Folder | Interactables | Everything that players can interact with goes here. |
| Folder | PlayerClips | Invisible parts that blocks out an area and can be shot through goes here. |
| Folder | Spawners | These are predefined enemy spawners. |
| ModuleScript | Map | The **Map** script will automatically execute when server starts. Only authorized scripts will run, click [here](#allowed-scripts) for more information. |
| Camera | ThumbnailCamera | This will be the gamemode's thumbnail, when you upload your model, Roblox will use **ThumbnailCamera** as the model's thumbnail. |

---
### Map Script
Map script runs as the server starts, this means that you can program your gamemodes here.

## Properties
| Type | Name | Description |
| --- | --- | --- |
| int64 | MapId | The asset id of the model |

## Functions
| Return | Name |
| --- | --- |
| *void* | [Initialize()](#void-initialize) |
| *void* | [OnPlayerConnect( *Player* player )](#void-onplayerconnect-player-player) |
| *Folder* | [GetFolder()](#folder-getfolder-string-name) |
| *void* | [LoadAudio()](#void-loadaudio-instance-container) |

---
### *void* Initialize()
`Initialize()` gets called by the server.

```lua
function Map:Initialize()
	print("Hello World.")
end
```
---
### *void* OnPlayerConnect( *Player* player )
`OnPlayerConnect()` gets called when a player joins the server. It also gets called for every player who already is on the server after the map loaded.

```lua
function Map:OnPlayerConnect(player)
	print(player.Name.." joined the game.")
end
```

---
### *Folder* GetFolder( *String* Name )
Returns the first folder **Instance** of `Name` that locates in the script directory.

```lua
local assets = Map:GetFolder("Assets");
```
---
### *void* LoadAudio( *Instance* container )
Loads gamemode **Sound** audio files into the game's library.

```lua
Map:LoadAudio(Map:GetFolder("Audio"))
```

---
### Allowed Scripts
Here are some rules for what scripts will be allowed into the server. They are pre-approved and all else which aren't will be delete on load.
All ModuleScript will be converted into StringValue Objects for the server to scan and run. Roblox Server Scripts will not run and will be deleted on load. 

| Name | Description |
| --- | --- |
| Map | Core map script |
| Spawner | Spawner datatable script |
| Interactable | Interaction datatable script |

---
### Publishing
To publish your map, you should first use the devkit to convert the map into a model, the devkit will convert all compatibile ModuleScripts into StringValues so you do not have to do it yourself.

1. On the devkit, click File. (Feel free to name your file from the textbox on the top)
2. Click **Save Project** and it should create a new model in your `game.ServerStorage.ProjectSaves` Folder.
3. Right-click the model and **Save to Roblox**.

---
### Testing
This feature isn't available yet.