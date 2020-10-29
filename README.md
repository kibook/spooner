# RedM Object Spooner

Tool for spawning, placing, and removing objects in RedM, inspired by Menyoo's Object Spooner.

# Example

[![Object Spooner Example](https://i.imgur.com/foLmX9rm.jpg)](https://imgur.com/foLmX9r)

# Usage

## Cursor colours

| Colour | Meaning            |
|--------|--------------------|
| white  | No entity selected |
| green  | Entity highlighted |
| blue   | Entity attached    |

## Controls

| Control        | Function                                                                         |
|----------------|----------------------------------------------------------------------------------|
| W/A/S/D        | Move                                                                             |
| Spacebar/Shift | Up/Down                                                                          |
| Left click     | No entity selected: Spawn, Entity highlighted: Attach, Entity attached: Detach   |
| Right click    | Delete selected entity                                                           |
| C/V            | Rotate                                                                           |
| B              | Change rotation axis                                                             |
| Q/Z/Arrow keys | Adjust selected entity position                                                  |
| I              | Cycle between controlled mouse adjustment modes                                  |
| U              | Toggle whether entities stick to the ground in controlled mouse adjustment modes |
| 8              | Return to Free mouse adjustment mode                                             |
| G              | Clone selected entity                                                            |
| F              | Open the Spawn menu                                                              |
| X              | Open the Database menu                                                           |
| Enter          | Open the Properties menu for the selected entity                                 |
| J              | Open the Save/Load Database menu                                                 |
| Delete         | Exit Object Spooner                                                              |

## Menus

### Spawn menu

The Spawn menu provides searchable lists to select an entity to spawn. Left-clicking on an entity sets it as your current spawn.

If an entity is not included in the list, you can still spawn it by entering the full model name in the search field and clicking Spawn By Name.

### Database menu

The Database menu stores a list of entities. When an entity is spawned, it is automatically added to the current database. Entities can be added/removed from the database via the Properties menu.

- Left-click on an entity to open it in the Properties menu
- Right-click on an entity to delete it
- Click Remove All to delete all entities in the database

### Properties menu

The Properties menu lists and allows you to edit properties of an entity.

### Save/Load Database menu

The Save/Load Database menu allows you to store your current database with a name, and then load all the entities from it again later.

- To save your current database, enter name in the field and click Save.
- To load a saved database, left-click on the name of the database.
- To delete a saved database, right-click on the name of the database.

Checking the Relative box will spawn the entities in the selected database relative to your current position, rather than exactly where they were originally placed.
