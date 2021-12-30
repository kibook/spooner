# Spooner

Tool for spawning, placing, and removing entities, inspired by Menyoo's Object Spooner.

# Features

- Freecam mode with a variety of options for placing and adjusting entities
- Searchable lists of peds, vehicles and objects
- View and set properties of an entity, including attaching entities to one another
- Save and load sets of entities
- Saved databases are stored client-side, so you can load them on any server with this resource
- Import and export sets of entities to share with others or to convert to a permanent map
- Permissions system for controlling access to individual features

# Example

[![Spooner Example](https://i.imgur.com/HLzNYUIm.jpg)](https://imgur.com/HLzNYUI)

# Requirements

- [uiprompt](https://github.com/kibook/redm-uiprompt) (only required when using spooner on RedM)

# Installation

1. Place in the resources directory.

2. Edit fxmanifest.lua and set the `gameName` variable to either `"gta5"` (for FiveM) or `"rdr3"` (for RedM).

3. Add the following to server.cfg:

   ```
   exec @spooner/permissions.cfg
   start spooner
   ```

   The name of the resource folder must be `spooner`, otherwise players' saved databases will not be accessible.

4. Restart the server.

# Permissions

The default permissions give full access to the object spooner to all players. You can limit which players can use the spooner or what parts they can access by modifying `permissions.cfg`.

For example:

```
add_ace builtin.everyone spooner.view allow
add_ace builtin.everyone spooner.spawn allow
add_ace builtin.everyone spooner.modify.own allow
add_ace builtin.everyone spooner.delete.own allow
add_ace builtin.everyone spooner.properties allow

add_ace group.admin spooner.noEntityLimit allow
add_ace group.admin spooner.modify.other allow
add_ace group.admin spooner.delete.other allow
```

The above configuration would allow all users to spawn a limited number of entities, and only modify or delete the objects they spawn, while an admin can spawn any number of entities and modify or delete other players' entities.

If you need to change any permissions while the server is running, after adding/removing any spooner-related aces, run `spooner_refresh_perms` to refresh the permissions on all clients, or restart the resource.

# Usage

## Cursor colours

| Colour | Meaning            |
|--------|--------------------|
| white  | No entity selected |
| green  | Entity highlighted |
| blue   | Entity attached    |

## Controls

| Control                   | Function                                                                         |
|---------------------------|----------------------------------------------------------------------------------|
| W/A/S/D                   | Move                                                                             |
| Spacebar/Shift            | Up/Down                                                                          |
| E                         | Spawn                                                                            |
| Left click                | Entity highlighted: Attach, Entity attached: Detach                              |
| Right click               | Delete selected entity                                                           |
| C/V                       | Rotate                                                                           |
| B                         | Change rotation axis                                                             |
| Q/Z/Arrow keys            | Adjust selected entity position                                                  |
| I                         | Cycle between controlled mouse adjustment modes                                  |
| U                         | Toggle whether entities stick to the ground in controlled mouse adjustment modes |
| 7                         | Turn off mouse adjustment                                                        |
| 8                         | Return to Free mouse adjustment mode                                             |
| G                         | Clone selected entity                                                            |
| Pg Up/Pg Down/Mouse wheel | Change currently selected speed                                                  |
| R                         | Cycle between which speed to change                                              |
| F                         | Open the Spawn menu                                                              |
| X                         | Open the Database menu                                                           |
| Tab                       | Open the Properties menu for the selected entity                                 |
| J                         | Open the Save/Load Database menu                                                 |
| Delete                    | Exit Object Spooner                                                              |

## Menus

### Spawn menu - F

The **Spawn** menu provides searchable lists to select an entity to spawn. Left-clicking on an entity sets it as your current spawn.

If an entity is not included in the list, you can still spawn it by entering the full model name in the search field and clicking **Spawn By Name**.

Right-clicking an entity in any of the spawn menus will add that entity as a favourite. Clickin the favourites button will toggle displaying only your favourited entities.

### Database menu - X

The **Database** menu stores a list of entities. When an entity is spawned, it is automatically added to the current database. Existing entities can be added/removed from the database via the **Properties** menu.

- Left-click on an entity to open it in the **Properties** menu
- Right-click on an entity to delete it
- Click **Delete All** to delete all entities in the database

### Properties menu - Tab

The **Properties** menu lists and allows you to edit properties of an entity.

### Save/Load Database menu - J

The **Save/Load Database** menu allows you to store your current database with a name, and then load all the entities from it again later.

- To save your current database, enter name in the field and click **Save**.
- To load a saved database, left-click on the name of the database.
- To delete a saved database, right-click on the name of the database.
- To import a database or export the current database, click **Import/Export**.

Checking the **Load relative to cursor position** box will spawn the entities in the selected database relative to the current cursor position, rather than exactly where they were originally placed.

Checking the **Replace current DB** box will replace your current database with the loaded database, rather than merging the two.

Checking the **Save/Load deletions** box will save what entities you delete, and delete them again when the database is loaded.

### Import/Export menu

The **Import/Export** menu allows you to import and export databases in a number of different formats:

| Format | Description | Export? | Import? |
|--------|-------------|---------|---------|
| Spooner DB JSON | The native format used by the spooner | Yes | Yes |
| Map Editor XML | XML format used by the [Lambdarevolution map editor](https://allmods.net/red-dead-redemption-2/tools-red-dead-redemption-2/rdr2-map-editor-v0-10/) and the [objectloader](https://github.com/kibook/redm-objectloader) resource | Yes | No |
| Ymap | Native map format used by GTA V/RDR2 | Yes | No |
| propplacer JSON | [RedEM:RP propplacer](https://github.com/RedEM-RP/redemrp_propplacer) JSON database | Yes | No |
| Spooner Backup | Backup of all spooner databases | Yes | Yes |

To export, select the desired format and click **Export**. The output will be displayed in the text box, and you can copy it to save it to an external file.

To import, paste the input into the text box, select the appropriate format, and click **Import**. Objects imported will be added to your current database.

Entering a URL of a JSON/XML file in the **Import from URL** field and clicking **Import** allows you to import from external web sources, such as pastebin.com, without needing to copy and paste. Be sure that the URL points to the raw version of the file when using such services.
