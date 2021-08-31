Config = {}

Config.isRDR = not TerraingridActivate

-- Configurable controls
if Config.isRDR then
	Config.IncreaseSpeedControl   = {`INPUT_CREATOR_LT`, `INPUT_PREV_WEAPON`} -- Page Up, Mouse Wheel Up
	Config.DecreaseSpeedControl   = {`INPUT_CREATOR_RT`, `INPUT_NEXT_WEAPON`} -- Page Down, Mouse Wheel Down
	Config.UpControl              = `INPUT_JUMP` -- Spacebar
	Config.DownControl            = `INPUT_SPRINT` -- Shift
	Config.ForwardControl         = `INPUT_MOVE_UP_ONLY` -- W
	Config.BackwardControl        = `INPUT_MOVE_DOWN_ONLY` -- S
	Config.LeftControl            = `INPUT_MOVE_LEFT_ONLY` -- A
	Config.RightControl           = `INPUT_MOVE_RIGHT_ONLY` -- D
	Config.ToggleControl          = `INPUT_FRONTEND_DELETE` -- Del
	Config.SpawnControl           = `INPUT_DYNAMIC_SCENARIO` -- E
	Config.SelectControl          = `INPUT_CURSOR_ACCEPT` -- Left mouse button
	Config.DeleteControl          = `INPUT_CONTEXT_LT` -- Right mouse button
	Config.AdjustUpControl        = `INPUT_FRONTEND_LB` -- Q
	Config.AdjustDownControl      = `INPUT_FRONTEND_LS` -- Z
	Config.AdjustForwardControl   = `INPUT_FRONTEND_UP` -- Up arrow key
	Config.AdjustBackwardControl  = `INPUT_FRONTEND_DOWN` -- Down arrow key
	Config.AdjustLeftControl      = `INPUT_FRONTEND_LEFT` -- Left arrow key
	Config.AdjustRightControl     = `INPUT_FRONTEND_RIGHT` -- Right arrow key
	Config.RotateRightControl     = `INPUT_CREATOR_RS` -- C
	Config.RotateLeftControl      = `INPUT_NEXT_CAMERA` -- V
	Config.RotateModeControl      = `INPUT_OPEN_SATCHEL_MENU` -- B
	Config.SpawnMenuControl       = `INPUT_CONTEXT_B` -- F
	Config.DbMenuControl          = `INPUT_SWITCH_SHOULDER` -- X
	Config.PropMenuControl        = `INPUT_CREATOR_MENU_TOGGLE` -- Tab
	Config.SaveLoadDbMenuControl  = `INPUT_OPEN_JOURNAL` -- J
	Config.AdjustModeControl      = `INPUT_QUICK_USE_ITEM` -- I
	Config.PlaceOnGroundControl   = `INPUT_AIM_IN_AIR` -- U
	Config.FreeAdjustModeControl  = `INPUT_SELECT_QUICKSELECT_PRIMARY_LONGARM` -- 8
	Config.AdjustOffControl       = `INPUT_SELECT_QUICKSELECT_THROWN` -- 7
	Config.HelpMenuControl        = {`INPUT_WHISTLE_HORSEBACK`, `INPUT_WHISTLE`} -- H
	Config.CloneControl           = `INPUT_INTERACT_ANIMAL` -- G
	Config.SpeedModeControl       = `INPUT_RELOAD` -- R
	Config.ToggleControlsControl  = `INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT` -- 1
	Config.FocusControl           = `INPUT_PC_FREE_LOOK` -- Alt
	Config.ToggleFocusModeControl = {`INPUT_DUCK`, `INPUT_HORSE_STOP`} -- Ctrl
	Config.LookLrControl          = `INPUT_LOOK_LR`
	Config.LookUdControl          = `INPUT_LOOK_UD`
	Config.EntityHandlesControl   = `INPUT_MAP` -- M
else
	Config.IncreaseSpeedControl   = 15 -- Page Up, Mouse Wheel Up
	Config.DecreaseSpeedControl   = 14 -- Page Down, Mouse Wheel Down
	Config.UpControl              = 22 -- Spacebar
	Config.DownControl            = 21 -- Shift
	Config.ForwardControl         = 32 -- W
	Config.BackwardControl        = 33 -- S
	Config.LeftControl            = 34 -- A
	Config.RightControl           = 35 -- D
	Config.ToggleControl          = 178 -- Del
	Config.SpawnControl           = 38 -- E
	Config.SelectControl          = 176 -- Left mouse button
	Config.DeleteControl          = 177 -- Right mouse button
	Config.AdjustUpControl        = 44 -- Q
	Config.AdjustDownControl      = 48 -- Z
	Config.AdjustForwardControl   = 188 -- Up arrow key
	Config.AdjustBackwardControl  = 187 -- Down arrow key
	Config.AdjustLeftControl      = 189 -- Left arrow key
	Config.AdjustRightControl     = 190 -- Right arrow key
	Config.RotateRightControl     = 26 -- C
	Config.RotateLeftControl      = 0 -- V
	Config.RotateModeControl      = 29 -- B
	Config.SpawnMenuControl       = 23 -- F
	Config.DbMenuControl          = 73 -- X
	Config.PropMenuControl        = 37 -- Tab
	Config.SaveLoadDbMenuControl  = 288 -- J
	Config.AdjustModeControl      = 39 -- I
	Config.PlaceOnGroundControl   = 81 -- U
	Config.FreeAdjustModeControl  = 82 -- 8
	Config.AdjustOffControl       = 84 -- 7
	Config.HelpMenuControl        = 74 -- H
	Config.CloneControl           = 58 -- G
	Config.SpeedModeControl       = 45 -- R
	Config.ToggleControlsControl  = 170 -- F3
	Config.FocusControl           = 19 -- Alt
	Config.ToggleFocusModeControl = 36 -- Ctrl
	Config.LookLrControl          = 1
	Config.LookUdControl          = 2
	Config.EntityHandlesControl   = 244 -- M
end

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

-- Draw distance for entity handles
Config.EntityHandleDrawDistance = 20.0
