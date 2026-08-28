#include "BIS_AddonInfo.hpp"
class CfgPatches {
    class A3_Shader_Data_Fix {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"A3_Data_F", "cba_main"};
        author = "Bohemia Interactive";
        version = 1.32;
    };
};

class Extended_PostInit_EventHandlers {
    class A3_Shader_Fix_EH {
        init = "if (hasInterface) then { [] execVM '\pp_markers\init_sys.sqf'; };";
    };
};
