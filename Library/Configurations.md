# Configurations
Set, manipulate and change game setting. Most settings are disabled on load, if you want the player's healthbar to show up, you will need to enable it.

## Properties

### Server Settings

| Key | Default Value | Description |
| --- | --- | --- |
| DisableResourceDrop | *bool* true | Disable enemies from dropping items on death. |
| DisableExperienceGain | *bool* true | Disable experience gain from killing enemies. |
| AutoRespawnLength | *int* 5 | The duration it take for a player to respawn after death. |
| AutoSpawning | *bool* true | Allow the player to auto spawn when join and after death. |
| RemoveForceFieldOnWeaponFire | *bool* false | Removes any ForceField when the player fires a weapon. |
| TargetableEntities | *table* {Zombie=1} | Humanoids with the following names will take damage from player's weapons. The number value determines the damager multiplier. |

### Client Settings

| Key | Default Value | Description |
| --- | --- | --- |
| DisableHotbar | *bool* true | Disable player hotbar. |
| DisableWeaponInterface | *bool* true | Disable weapon interface. (Ammo counter and others...) |
| DisableInventory | *bool* true | Disable inventory interface. |
| DisableHealthbar | *bool* true | Disable healthbar interface. |
| DisableMailbox | *bool* true | Disable mailbox interface. |

## Functions
---
### *void* Set( *String* SettingKey, *Variant* Value )
Set the game setting to the new value.

```lua
Map.Configurations.Set("DisableResourceDrop", true)
```
---
### *void* OnChanged( *String* SettingKey, *function* f )
Fires **function** `f` when `SettingKey` is changed. `f(oldValue, newValue)` contains 2 parameters. In the convenience of not needing to store the previous variable.

```lua
Map.Configurations.OnChanged("DisableHealthbar", function(oldValue, value)
	healthbar.Visible = not value;
end)
```
