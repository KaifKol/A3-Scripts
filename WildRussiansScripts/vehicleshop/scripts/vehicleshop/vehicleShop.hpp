class VehicleShopDialog
{
    idd = 9100;
    movingEnable = true;
    enableSimulation = true;
    onLoad = "";

    #define DLG_W  0.45
    #define DLG_H  0.60
    #define DLG_X  ((safezoneX + safezoneW * 0.5) - DLG_W * 0.5)
    #define DLG_Y  ((safezoneY + safezoneH * 0.5) - DLG_H * 0.5)

    #define FONT_NORM  "RobotoCondensed"
    #define FONT_BOLD  "RobotoCondensedBold"

    class Controls
    {
        class BG
        {
            idc = -1;
            type = 0;
            style = 0;
            colorBackground[] = {0.08, 0.08, 0.08, 0.95};
            colorText[] = {1, 1, 1, 1};
            font = FONT_NORM;
            sizeEx = 0;
            text = "";
            x = DLG_X; 
            y = DLG_Y; 
            w = DLG_W; 
            h = DLG_H;
        };

        class Header
        {
            idc = -1;
            type = 0;
            style = 2;
            colorBackground[] = {0.15, 0.45, 0.15, 1};
            colorText[] = {1, 1, 1, 1};
            font = FONT_BOLD;
            sizeEx = 0.042;
            text = "МАГАЗИН ТЕХНИКИ";
            x = DLG_X; 
            y = DLG_Y; 
            w = DLG_W; 
            h = 0.055;
        };

        class PointsBar
        {
            idc = 9101;
            type = 0;
            style = 2;
            colorBackground[] = {0.05, 0.05, 0.05, 1};
            colorText[] = {0.2, 1, 0.2, 1};
            font = FONT_BOLD;
            sizeEx = 0.036;
            text = "Очки команды: ...";
            x = DLG_X; 
            y = DLG_Y + 0.057; 
            w = DLG_W; 
            h = 0.040;
        };

        class VehicleList
        {
            idc = 9102;
            type = 5;
            style = 0;
            font = FONT_NORM;
            sizeEx = 0.033;
            rowHeight = 0.038;
            colorBackground[] = {0.06, 0.06, 0.06, 1};
            colorText[] = {0.95, 0.95, 0.95, 1};
            colorSelect[] = {0, 0, 0, 1};
            colorSelectBackground[] = {0.18, 0.48, 0.18, 1};
            colorDisabled[] = {0.5, 0.5, 0.5, 1};
            colorScrollbar[] = {1, 1, 1, 0.3};
            soundSelect[] = {"", 0.1, 1};
            soundExpand[] = {"", 0.1, 1};
            soundCollapse[] = {"", 0.1, 1};
            maxHistoryDelay = 1.0;
            autoScrollSpeed = -1;
            autoScrollDelay = 5;
            autoScrollRewind = 0;
            arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
            arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
            border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
            text = "";
            x = DLG_X + 0.008; 
            y = DLG_Y + 0.105;
            w = DLG_W - 0.016; 
            h = DLG_H - 0.23;
            
            class ListScrollBar
            {
                color[] = {1, 1, 1, 0.6};
                colorActive[] = {1, 1, 1, 1};
                colorDisabled[] = {0.5, 0.5, 0.5, 1};
                thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
            };
        };

        class InfoLine
        {
            idc = 9105;
            type = 0;
            style = 2;
            colorBackground[] = {0.0, 0.0, 0.0, 0.0};
            colorText[] = {0.8, 0.8, 0.2, 1};
            font = FONT_NORM;
            sizeEx = 0.030;
            text = "Выберите технику из списка";
            x = DLG_X + 0.008; 
            y = DLG_Y + DLG_H - 0.115;
            w = DLG_W - 0.016; 
            h = 0.034;
        };

        class BuyBtn
        {
            idc = 9103;
            type = 1;
            style = 2;
            colorBackground[] = {0.12, 0.48, 0.12, 1};
            colorBackgroundActive[] = {0.18, 0.65, 0.18, 1};
            colorBackgroundDisabled[] = {0.1, 0.1, 0.1, 1};
            colorText[] = {1, 1, 1, 1};
            colorDisabled[] = {0.5, 0.5, 0.5, 1};
            colorFocused[] = {0.18, 0.65, 0.18, 1};
            colorBorder[] = {0, 0, 0, 0};
            colorShadow[] = {0, 0, 0, 0};
            font = FONT_BOLD;
            sizeEx = 0.038;
            offsetX = 0;
            offsetY = 0;
            offsetPressedX = 0;
            offsetPressedY = 0;
            borderSize = 0;
            soundEnter[] = {"", 0.1, 1};
            soundPush[] = {"", 0.1, 1};
            soundClick[] = {"", 0.1, 1};
            soundEscape[] = {"", 0.1, 1};
            text = "КУПИТЬ";
            action = "[] call VS_fnc_buyVehicle";
            x = DLG_X + 0.008; 
            y = DLG_Y + DLG_H - 0.072;
            w = (DLG_W - 0.024) * 0.49; 
            h = 0.055;
        };

        class CloseBtn
        {
            idc = 9104;
            type = 1;
            style = 2;
            colorBackground[] = {0.48, 0.10, 0.10, 1};
            colorBackgroundActive[] = {0.65, 0.15, 0.15, 1};
            colorBackgroundDisabled[] = {0.1, 0.1, 0.1, 1};
            colorText[] = {1, 1, 1, 1};
            colorDisabled[] = {0.5, 0.5, 0.5, 1};
            colorFocused[] = {0.65, 0.15, 0.15, 1};
            colorBorder[] = {0, 0, 0, 0};
            colorShadow[] = {0, 0, 0, 0};
            font = FONT_BOLD;
            sizeEx = 0.038;
            offsetX = 0;
            offsetY = 0;
            offsetPressedX = 0;
            offsetPressedY = 0;
            borderSize = 0;
            soundEnter[] = {"", 0.1, 1};
            soundPush[] = {"", 0.1, 1};
            soundClick[] = {"", 0.1, 1};
            soundEscape[] = {"", 0.1, 1};
            text = "ЗАКРЫТЬ";
            action = "closeDialog 0";
            x = DLG_X + 0.008 + (DLG_W - 0.024) * 0.51;
            y = DLG_Y + DLG_H - 0.072;
            w = (DLG_W - 0.024) * 0.49; 
            h = 0.055;
        };
    };
};

class KSMDialog
{
    idd = 9200;
    movingEnable = true;
    enableSimulation = true;
    onLoad = "";

    #define KSM_W  0.40
    #define KSM_H  0.50
    #define KSM_X  ((safezoneX + safezoneW * 0.5) - KSM_W * 0.5)
    #define KSM_Y  ((safezoneY + safezoneH * 0.5) - KSM_H * 0.5)

    #define FONT_NORM  "RobotoCondensed"
    #define FONT_BOLD  "RobotoCondensedBold"

    class Controls
    {
        class BG
        {
            idc = -1; 
            type = 0; 
            style = 0;
            colorBackground[] = {0.08, 0.08, 0.08, 0.95};
            colorText[] = {1,1,1,1};
            font = FONT_NORM; 
            sizeEx = 0;
            x = KSM_X; 
            y = KSM_Y; 
            w = KSM_W; 
            h = KSM_H;
            text = "";
        };
        
        class Header
        {
            idc = -1; 
            type = 0; 
            style = 2;
            colorBackground[] = {0.45, 0.15, 0.15, 1};
            colorText[] = {1,1,1,1};
            font = FONT_BOLD; 
            sizeEx = 0.040;
            x = KSM_X; 
            y = KSM_Y; 
            w = KSM_W; 
            h = 0.050;
            text = "ОБОРОНИТЕЛЬНЫЕ ПОЗИЦИИ";
        };
        
        class PointsBar
        {
            idc = 9201; 
            type = 0; 
            style = 2;
            colorBackground[] = {0.05, 0.05, 0.05, 1};
            colorText[] = {0.2, 1, 0.2, 1};
            font = FONT_BOLD; 
            sizeEx = 0.034;
            x = KSM_X; 
            y = KSM_Y + 0.052; 
            w = KSM_W; 
            h = 0.036;
            text = "Очки команды: ...";
        };
        
        class RadiusInfo
        {
            idc = -1; 
            type = 0; 
            style = 2;
            colorBackground[] = {0.0, 0.0, 0.0, 0.0};
            colorText[] = {0.6, 0.6, 0.6, 1};
            font = FONT_NORM; 
            sizeEx = 0.026;
            x = KSM_X; 
            y = KSM_Y + 0.090; 
            w = KSM_W; 
            h = 0.028;
            text = "Размещение в радиусе 50м от КШМ";
        };
        
        class DefenseList
        {
            idc = 9202; 
            type = 5;
            style = 0;
            colorBackground[] = {0.06, 0.06, 0.06, 1};
            colorText[] = {0.95, 0.95, 0.95, 1};
            colorSelect[] = {0, 0, 0, 1};
            colorSelectBackground[] = {0.48, 0.15, 0.15, 1};
            colorDisabled[] = {0.5, 0.5, 0.5, 1};
            colorScrollbar[] = {1, 1, 1, 0.3};
            soundSelect[] = {"", 0.1, 1};
            soundExpand[] = {"", 0.1, 1};
            soundCollapse[] = {"", 0.1, 1};
            maxHistoryDelay = 1.0;
            autoScrollSpeed = -1;
            autoScrollDelay = 5;
            autoScrollRewind = 0;
            arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
            arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
            border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
            font = FONT_NORM; 
            sizeEx = 0.033; 
            rowHeight = 0.038;
            x = KSM_X + 0.008; 
            y = KSM_Y + 0.124;
            w = KSM_W - 0.016; 
            h = KSM_H - 0.225;
            text = "";
            
            class ListScrollBar
            {
                color[] = {1,1,1,0.6};
                colorActive[] = {1,1,1,1};
                colorDisabled[] = {0.5,0.5,0.5,1};
                thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
            };
        };
        
        class InfoLine
        {
            idc = 9203; 
            type = 0; 
            style = 2;
            colorBackground[] = {0.0, 0.0, 0.0, 0.0};
            colorText[] = {0.8, 0.8, 0.2, 1};
            font = FONT_NORM; 
            sizeEx = 0.028;
            x = KSM_X + 0.008; 
            y = KSM_Y + KSM_H - 0.105;
            w = KSM_W - 0.016; 
            h = 0.030;
            text = "Выберите оборонительное средство";
        };
        
        class PlaceBtn
        {
            idc = 9204; 
            type = 1; 
            style = 2;
            colorBackground[] = {0.48, 0.12, 0.12, 1};
            colorBackgroundActive[] = {0.65, 0.18, 0.18, 1};
            colorBackgroundDisabled[] = {0.1, 0.1, 0.1, 1};
            colorText[] = {1,1,1,1};
            colorDisabled[] = {0.5, 0.5, 0.5, 1};
            colorFocused[] = {0.65, 0.18, 0.18, 1};
            colorBorder[] = {0,0,0,0};
            colorShadow[] = {0,0,0,0};
            font = FONT_BOLD; 
            sizeEx = 0.036;
            offsetX = 0; 
            offsetY = 0;
            offsetPressedX = 0; 
            offsetPressedY = 0;
            borderSize = 0;
            soundEnter[] = {"", 0.1, 1};
            soundPush[] = {"", 0.1, 1};
            soundClick[] = {"", 0.1, 1};
            soundEscape[] = {"", 0.1, 1};
            x = KSM_X + 0.008; 
            y = KSM_Y + KSM_H - 0.066;
            w = (KSM_W - 0.024) * 0.49; 
            h = 0.050;
            text = "РАЗМЕСТИТЬ";
            action = "[] call VS_fnc_ksmPlaceDefense";
        };
        
        class CloseBtn
        {
            idc = 9205; 
            type = 1; 
            style = 2;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            colorBackgroundActive[] = {0.3, 0.3, 0.3, 1};
            colorBackgroundDisabled[] = {0.1, 0.1, 0.1, 1};
            colorText[] = {1,1,1,1};
            colorDisabled[] = {0.5, 0.5, 0.5, 1};
            colorFocused[] = {0.3, 0.3, 0.3, 1};
            colorBorder[] = {0,0,0,0};
            colorShadow[] = {0,0,0,0};
            font = FONT_BOLD; 
            sizeEx = 0.036;
            offsetX = 0; 
            offsetY = 0;
            offsetPressedX = 0; 
            offsetPressedY = 0;
            borderSize = 0;
            soundEnter[] = {"", 0.1, 1};
            soundPush[] = {"", 0.1, 1};
            soundClick[] = {"", 0.1, 1};
            soundEscape[] = {"", 0.1, 1};
            x = KSM_X + 0.008 + (KSM_W - 0.024) * 0.51;
            y = KSM_Y + KSM_H - 0.066;
            w = (KSM_W - 0.024) * 0.49; 
            h = 0.050;
            text = "ЗАКРЫТЬ";
            action = "closeDialog 0";
        };
    };
};