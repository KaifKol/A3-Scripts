// =============================================================================
// VEM_GUI_defines.hpp  v1.7
// #include "scripts\VEM\VEM_GUI_defines.hpp"
// Камуфляж отключён — вкладка удалена.
// =============================================================================

#define VEM_BTN_COMMON \
    type                    = 1; \
    style                   = 2; \
    font                    = "RobotoCondensed"; \
    sizeEx                  = 0.022; \
    colorText[]             = {1, 1, 1, 1}; \
    colorFocused[]          = {1, 1, 1, 1}; \
    colorShadow[]           = {0, 0, 0, 0}; \
    colorBorder[]           = {0, 0, 0, 0}; \
    colorDisabled[]         = {0.4, 0.4, 0.4, 1}; \
    colorBackgroundDisabled[]= {0.1, 0.1, 0.1, 1}; \
    borderSize              = 0; \
    offsetX                 = 0; \
    offsetY                 = 0; \
    offsetPressedX          = 0; \
    offsetPressedY          = 0; \
    soundEnter[]            = {"", 0, 1}; \
    soundPush[]             = {"", 0, 1}; \
    soundClick[]            = {"", 0, 1}; \
    soundEscape[]           = {"", 0, 1}; \
    default                 = false;

class VEM_GUI
{
    idd              = 5100;
    movingEnable     = false;
    enableSimulation = true;
    onLoad           = "[] call fnc_VEM_GUI_check;";
    onUnload         = "[] spawn fnc_VEM_variable_cleaner;";

    class controlsBackground
    {
        class VEM_BG
        {
            idc               = -1;
            type              = 0;  style = 0;
            x                 = 0.25;  y = 0.10;
            w                 = 0.50;  h = 0.80;
            colorBackground[] = {0.05, 0.05, 0.05, 0.92};
            colorText[]       = {1, 1, 1, 1};
            font              = "RobotoCondensed";
            sizeEx            = 0.025;
            text              = "";
        };
    };

    class controls
    {
        // Заголовок
        class VEM_Title
        {
            idc               = 5150;
            type              = 0;  style = 2;
            x                 = 0.26;  y = 0.11;
            w                 = 0.48;  h = 0.04;
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {0.85, 0.85, 0.0, 1};
            font              = "RobotoCondensedBold";
            sizeEx            = 0.028;
            text              = "[VEM] Vehicle Exterior Manager";
        };

        // Разделитель
        class VEM_Divider
        {
            idc               = -1;
            type              = 0;  style = 0;
            x                 = 0.26;  y = 0.155;
            w                 = 0.48;  h = 0.003;
            colorBackground[] = {0.8, 0.8, 0.0, 0.7};
            colorText[]       = {1, 1, 1, 1};
            font              = "RobotoCondensed";
            sizeEx            = 0.018;
            text              = "";
        };

        // Статус-строка
        class VEM_Status
        {
            idc               = 5162;
            type              = 0;  style = 0;
            x                 = 0.26;  y = 0.165;
            w                 = 0.48;  h = 0.024;
            colorBackground[] = {0.10, 0.10, 0.10, 1};
            colorText[]       = {0.5, 0.9, 0.5, 1};
            font              = "RobotoCondensed";
            sizeEx            = 0.018;
            text              = "";
        };

        // Список компонентов (единственный список, всегда виден)
        class VEM_List_Comp
        {
            idc                     = 5181;
            type                    = 5;  style = 0;
            x                       = 0.26;  y = 0.196;
            w                       = 0.48;  h = 0.540;
            colorBackground[]       = {0.08, 0.08, 0.08, 1};
            colorSelect[]           = {1, 1, 1, 1};
            colorSelectBackground[] = {0.10, 0.14, 0.18, 1};
            colorText[]             = {0.85, 0.85, 0.85, 1};
            colorDisabled[]         = {0.85, 0.85, 0.85, 1};
            soundSelect[]           = {"", 0, 1};
            soundExpand[]           = {"", 0, 1};
            soundCollapse[]         = {"", 0, 1};
            maxHistoryDelay         = 1;
            autoScrollDelay         = 5;
            autoScrollEnabled       = 0;
            autoScrollRewind        = 0;
            autoScrollSpeed         = 0;
            font                    = "RobotoCondensed";
            sizeEx                  = 0.022;
            rowHeight               = 0.030;
            class ListScrollBar
            {
                color[]           = {0.6, 0.6, 0.6, 1};
                colorActive[]     = {0.9, 0.9, 0.9, 1};
                colorDisabled[]   = {0.3, 0.3, 0.3, 1};
                thumb             = "\A3\ui_f\data\GUI\RscCommon\RscScrollbar\thumb_ca.paa";
                arrowFull         = "\A3\ui_f\data\GUI\RscCommon\RscScrollbar\arrowFull_ca.paa";
                arrowEmpty        = "\A3\ui_f\data\GUI\RscCommon\RscScrollbar\arrowEmpty_ca.paa";
                border            = "\A3\ui_f\data\GUI\RscCommon\RscScrollbar\border_ca.paa";
                width             = 0.018;
                autoScrollEnabled = false;
                autoScrollSpeed   = 0.05;
                autoScrollDelay   = 3;
                autoScrollRewind  = false;
            };
        };

        // Кнопка «Применить / Отключить»
        class VEM_Btn_Apply
        {
            idc = 5175;
            VEM_BTN_COMMON
            x = 0.26;   y = 0.745;
            w = 0.48;   h = 0.036;
            text                    = "Применить / Отключить";
            colorBackground[]       = {0.08, 0.22, 0.08, 1};
            colorBackgroundActive[] = {0.12, 0.38, 0.12, 1};
            colorBackgroundFocused[]= {0.10, 0.30, 0.10, 1};
        };

        // Кнопка «Сброс»
        class VEM_Btn_Reset
        {
            idc = 5170;
            VEM_BTN_COMMON
            x = 0.26;   y = 0.788;
            w = 0.235;  h = 0.036;
            text                    = "Сброс";
            colorBackground[]       = {0.30, 0.08, 0.08, 1};
            colorBackgroundActive[] = {0.50, 0.12, 0.12, 1};
            colorBackgroundFocused[]= {0.40, 0.10, 0.10, 1};
        };

        // Кнопка «Закрыть»
        class VEM_Btn_Close
        {
            idc = 5199;
            VEM_BTN_COMMON
            x = 0.505;  y = 0.788;
            w = 0.235;  h = 0.036;
            text                    = "Закрыть";
            colorBackground[]       = {0.08, 0.08, 0.30, 1};
            colorBackgroundActive[] = {0.12, 0.12, 0.50, 1};
            colorBackgroundFocused[]= {0.10, 0.10, 0.40, 1};
        };
    };
};
