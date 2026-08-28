[] spawn {
    waitUntil { !isNull (findDisplay 46) };

    // Initialization
    if (isNil "TAG_VAR_States") then { 
        TAG_VAR_States = createHashMapFromArray [["map", false], ["bullets", false], ["drones", false], ["planes", false]]; 
    };

    // Performance & View Distance tweaks
    CHVD_allowNoGrass = true; 
    CHVD_maxView = 12000; 
    CHVD_maxObj = 12000;

    // 1. Data Collector Thread (Single instance)
    if (scriptDone (missionNamespace getVariable ["TAG_handle_dataCollector", scriptNull])) then {
        TAG_handle_dataCollector = [] spawn {
            while {true} do {
                if (TAG_VAR_States get "drones") then {
                    missionNamespace setVariable ["TAG_List_Drones", (vehicles select { 
                        alive _x && 
                        {(player distance _x) < 2000} && 
                        {(toLower (typeOf _x) find "mavi") != -1} // As I said in README, mechanism of searching is hardcoded, and it's searching only for Mavic drones
                    })];
                } else { missionNamespace setVariable ["TAG_List_Drones", []]; };

                if (TAG_VAR_States get "planes") then {
                    missionNamespace setVariable ["TAG_List_Planes", (vehicles select { 
                        alive _x && 
                        {_x isKindOf "Plane"} && 
                        {(toLower (typeOf _x) find "su") != -1} // Same with the planese, only Sukhoi planes will be showed off
                    })];
                } else { missionNamespace setVariable ["TAG_List_Planes", []]; };
                sleep 1;
            };
        };
    };

    // 2. Draw3D HUD
    if (isNil "TAG_EH_Draw3D") then {
        TAG_EH_Draw3D = addMissionEventHandler ["Draw3D", {
            {
                if (alive _x) then {
                    drawIcon3D [
                        "\A3\ui_f\data\map\markers\military\circle_CA.paa", 
                        [0,1,0,0.8], 
                        _x modelToWorldVisual [0,0,0], 
                        1, 1, 0, 
                        format["MAVIC [%1m]", round(player distance _x)], 
                        2, 0.03, "PuristaMedium"
                    ];
                };
            } forEach (missionNamespace getVariable ["TAG_List_Drones", []]);

            {
                if (alive _x) then {
                    drawIcon3D [
                        "\A3\ui_f\data\map\markers\military\circle_CA.paa", 
                        [1,0,0,0.8], 
                        _x modelToWorldVisual [0,0,0], 
                        1.5, 1.5, 0, 
                        format["AIRCRAFT [%1m]", round(player distance _x)], 
                        2, 0.04, "PuristaBold"
                    ];
                };
            } forEach (missionNamespace getVariable ["TAG_List_Planes", []]);
        }];
    };

    // 3. Toggle Utility
    TAG_fnc_toggle = {
        params ["_key"];
        private _state = !(TAG_VAR_States get _key);
        TAG_VAR_States set [_key, _state];
        if (_state) then { playSoundUI ["HintExpand", 0.5, 1]; } else { playSoundUI ["HintCollapse", 0.5, 1]; };
        _state
    };

    // 4. Map Event Handler (Static persistent binding)
    if (isNil "TAG_fnc_drawMapIcons") then {
        TAG_fnc_drawMapIcons = {
            params ["_map"];
            if !(TAG_VAR_States getOrDefault ["map", false]) exitWith {};
            
            private _processed = [];
            {
                if (alive _x) then {
                    private _v = vehicle _x;
                    if !(_v in _processed) then {
                        _processed pushBack _v;
                        
                        // Color resolution
                        private _color = [0, 0.3, 0.8, 1];
                        if (side (group _x) == east) then { _color = [0.8, 0, 0, 1]; };
                        if (_x == player || player in crew _v) then { _color = [1, 0.9, 0, 1]; };
                        
                        // Cached DisplayName to save performance
                        private _text = if (_v isKindOf "Man") then { 
                            name _x 
                        } else { 
                            private _displayName = _v getVariable ["TAG_cache_name", ""];
                            if (_displayName == "") then {
                                _displayName = getText(configFile >> "CfgVehicles" >> typeOf _v >> "displayName");
                                _v setVariable ["TAG_cache_name", _displayName];
                            };
                            format ["%1 (%2)", _displayName, count (crew _v select {alive _x})] 
                        };
                        
                        private _icon = if (_v isKindOf "Man") then { 
                            "\A3\ui_f\data\map\markers\military\dot_CA.paa" 
                        } else { 
                            "\A3\ui_f\data\map\markers\military\box_CA.paa" 
                        };
                        
                        _map drawIcon [_icon, _color, getPosVisual _v, 22, 22, getDirVisual _v, _text, 1, 0.04, "RobotoCondensed", "right"];
                    };
                };
            } forEach allUnits;
        };
    };

    // Attach Draw EH to Map Display whenever opened
    if (isNil "TAG_EH_MapOpened") then {
        TAG_EH_MapOpened = addMissionEventHandler ["Map", {
            params ["_mapIsOpened", "_mapIsForced"];
            if (_mapIsOpened) then {
                private _mapCtrl = (findDisplay 12) displayCtrl 51;
                _mapCtrl ctrlRemoveEventHandler ["Draw", _mapCtrl getVariable ["TAG_EH_DrawID", -1]];
                private _ehID = _mapCtrl ctrlAddEventHandler ["Draw", TAG_fnc_drawMapIcons];
                _mapCtrl setVariable ["TAG_EH_DrawID", _ehID];
            };
        }];
    };

    // 5. Key Handler
    if (!isNil "TAG_EH_KeyDownID") then { (findDisplay 46) displayRemoveEventHandler ["KeyDown", TAG_EH_KeyDownID]; };

    TAG_EH_KeyDownID = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_key", "_shift", "_ctrl", "_alt"];
        if (!_ctrl) exitWith {false};

        private _handled = false;
        switch (_key) do {
            case 0x42: { ["planes"] call TAG_fnc_toggle; _handled = true; }; // Ctrl + F8
            case 0x43: { ["map"] call TAG_fnc_toggle; _handled = true; };    // Ctrl + F9
            case 0x44: {                                                     // Ctrl + F10
                private _st = ["bullets"] call TAG_fnc_toggle;
                [player, if(_st) then {99999} else {0}] spawn BIS_fnc_traceBullets;
                _handled = true;
            };
            case 0x57: { ["drones"] call TAG_fnc_toggle; _handled = true; };  // Ctrl + F11
        };
        _handled
    }];
};
