# RedM Object Spooner

Tool for spawning, placing, and removing entities in RedM, inspired by Menyoo's Object Spooner.

# Features

- Freecam mode with a variety of options for placing and adjusting entities
- Searchable lists of peds, vehicles and objects
- View and set properties of an entity, including attaching entities to one another
- Save and load sets of entities
- Import and export sets of entities to share with others or to convert to a permanent map

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
| Tab            | Open the Properties menu for the selected entity                                 |
| J              | Open the Save/Load Database menu                                                 |
| Delete         | Exit Object Spooner                                                              |

## Menus

### Spawn menu - F

The **Spawn** menu provides searchable lists to select an entity to spawn. Left-clicking on an entity sets it as your current spawn.

If an entity is not included in the list, you can still spawn it by entering the full model name in the search field and clicking **Spawn By Name**.

### Database menu - X

The **Database** menu stores a list of entities. When an entity is spawned, it is automatically added to the current database. Existing entities can be added/removed from the database via the **Properties** menu.

- Left-click on an entity to open it in the **Properties** menu
- Right-click on an entity to delete it
- Click **Remove All** to delete all entities in the database

### Properties menu - Tab

The **Properties** menu lists and allows you to edit properties of an entity.

### Save/Load Database menu - J

The **Save/Load Database** menu allows you to store your current database with a name, and then load all the entities from it again later.

- To save your current database, enter name in the field and click **Save**.
- To load a saved database, left-click on the name of the database.
- To delete a saved database, right-click on the name of the database.
- To import a database or export the current database, click **Import/Export**.

Checking the **Load relative to cursor position** box will spawn the entities in the selected database relative to the current cursor position, rather than exactly where they were originally placed.

### Import/Export menu

The **Import/Export** menu allows you to import a database into your current database, or export your current database in either JSON or Map Editor XML format.
