class CfgPatches {
    class My_Custom_Addon {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"A3_Data_F"};
        author = "Azat";
        version = "1.0";
    };
};

class Extended_PostInit_EventHandlers {
    class My_Addon_EH {
        init = "if (hasInterface) then { [] execVM '\pp_markers\init_sys.sqf'; };"; // Originally don't neeed to change anything, but if you're repacking, then change the "pp_markers" to your prefix
    };
};
