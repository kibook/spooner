Config = {}

-- Configurable controls
Config.IncreaseSpeedControl = {`INPUT_CREATOR_LT`, `INPUT_PREV_WEAPON`} -- Page Up, Mouse Wheel Up
Config.DecreaseSpeedControl = {`INPUT_CREATOR_RT`, `INPUT_NEXT_WEAPON`} -- Page Down, Mouse Wheel Down
Config.UpControl = `INPUT_JUMP` -- Spacebar
Config.DownControl = `INPUT_SPRINT` -- Shift
Config.ForwardControl = `INPUT_MOVE_UP_ONLY` -- W
Config.BackwardControl = `INPUT_MOVE_DOWN_ONLY` -- S
Config.LeftControl = `INPUT_MOVE_LEFT_ONLY` -- A
Config.RightControl = `INPUT_MOVE_RIGHT_ONLY` -- D
Config.ToggleControl = `INPUT_FRONTEND_DELETE` -- Del
Config.SpawnControl = `INPUT_DYNAMIC_SCENARIO` -- E
Config.SelectControl = `INPUT_CURSOR_ACCEPT` -- Left mouse button
Config.DeleteControl = `INPUT_CONTEXT_LT` -- Right mouse button
Config.AdjustUpControl = `INPUT_FRONTEND_LB` -- Q
Config.AdjustDownControl = `INPUT_FRONTEND_LS` -- Z
Config.AdjustForwardControl = `INPUT_FRONTEND_UP` -- Up arrow key
Config.AdjustBackwardControl = `INPUT_FRONTEND_DOWN` -- Down arrow key
Config.AdjustLeftControl = `INPUT_FRONTEND_LEFT` -- Left arrow key
Config.AdjustRightControl = `INPUT_FRONTEND_RIGHT` -- Right arrow key
Config.RotateRightControl = `INPUT_CREATOR_RS` -- C
Config.RotateLeftControl = `INPUT_NEXT_CAMERA` -- V
Config.RotateModeControl = `INPUT_OPEN_SATCHEL_MENU` -- B
Config.ObjectMenuControl = `INPUT_CONTEXT_B` -- F
Config.DbMenuControl = `INPUT_SWITCH_SHOULDER` -- X
Config.PropMenuControl = `INPUT_CREATOR_MENU_TOGGLE` -- Tab
Config.SaveLoadDbMenuControl = `INPUT_OPEN_JOURNAL` -- J
Config.AdjustModeControl = `INPUT_QUICK_USE_ITEM` -- I
Config.PlaceOnGroundControl = `INPUT_AIM_IN_AIR` -- U
Config.FreeAdjustModeControl = `INPUT_SELECT_QUICKSELECT_PRIMARY_LONGARM` -- 8
Config.AdjustOffControl = `INPUT_SELECT_QUICKSELECT_THROWN` -- 7
Config.HelpMenuControl = {`INPUT_WHISTLE_HORSEBACK`, `INPUT_WHISTLE`} -- H
Config.CloneControl = `INPUT_INTERACT_ANIMAL` -- G
Config.SpeedModeControl = `INPUT_RELOAD` -- R

-- Maximum movement speed
Config.MaxSpeed = 1.00

-- Minimum movement speed
Config.MinSpeed = 0.01

-- How much the speed increases/decreases by when the speed up/down controls are pressed
Config.SpeedIncrement = 0.01

-- Default movement speed
Config.Speed = 0.10

-- Camera rotation X-axis speed
Config.SpeedLr = 8.0

-- Camera rotation Y-axis speed
Config.SpeedUd = 8.0

-- Minimum X, Y, Z adjustment speed
Config.MinAdjustSpeed = 0.001

-- Maximum X, Y, Z adjustment speed
Config.MaxAdjustSpeed = 100.0

-- How much the X, Y, Z adjust speed increases/decreases by when the speed up/down controls are pressed
Config.AdjustSpeedIncrement = 0.001

-- Speed of X, Y, Z adjustments
Config.AdjustSpeed = 0.01

-- Minimum speed of pitch, roll, yaw adjustments
Config.MinRotateSpeed = 0.1

-- Maximum speed of pitch, roll, yaw adjustments
Config.MaxRotateSpeed = 360.0

-- How much the pitch, roll, yaw adjust speed increases/decreased by when the speed up/down controls are pressed
Config.RotateSpeedIncrement = 0.1

-- Speed of pitch, roll, yaw adjustments
Config.RotateSpeed = 1.0

-- Radar blip sprite for group members
Config.GroupMemberBlipSprite = -214162151

-- Max entities that can be spawned at a time by players without spooner.noEntityLimit
Config.MaxEntities = 10

-- Whether to automatically remove all entities from players' databases when the resource is stopped
Config.CleanUpOnStop = true
