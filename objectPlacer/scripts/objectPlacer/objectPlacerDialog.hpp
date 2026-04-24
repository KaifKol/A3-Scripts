class RscListBox {
    access = 0;
    type = 5;
    style = 0;
    rowHeight = 0.04;
    colorBackground[] = {0,0,0,0.5};
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.5,0.5,0.5,1};
    colorSelect[] = {0,0,0,1};
    colorSelectBackground[] = {0.9,0.9,0.9,1};
    font = "PuristaMedium";
    sizeEx = 0.03;
    colorScrollbar[] = {1,1,1,1};
    soundSelect[] = {"",0,1};
    soundExpand[] = {"",0,1};
    soundCollapse[] = {"",0,1};
    maxHistoryDelay = 1;
    class ScrollBar {
        color[] = {1,1,1,0.6};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        thumb = "\A3\ui_f\data\GUI\cfg\scrollbar\thumb_ca.paa";
        arrowFull = "\A3\ui_f\data\GUI\cfg\scrollbar\arrowFull_ca.paa";
        arrowEmpty = "\A3\ui_f\data\GUI\cfg\scrollbar\arrowEmpty_ca.paa";
        border = "\A3\ui_f\data\GUI\cfg\scrollbar\border_ca.paa";
    };
    class ListScrollBar {
        color[] = {1,1,1,0.6};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        thumb = "\A3\ui_f\data\GUI\cfg\scrollbar\thumb_ca.paa";
        arrowFull = "\A3\ui_f\data\GUI\cfg\scrollbar\arrowFull_ca.paa";
        arrowEmpty = "\A3\ui_f\data\GUI\cfg\scrollbar\arrowEmpty_ca.paa";
        border = "\A3\ui_f\data\GUI\cfg\scrollbar\border_ca.paa";
    };
};

class RscButton {
    access = 0;
    type = 1;
    style = 0;
    text = "";
    colorBackground[] = {0,0,0,0.5};
    colorBackgroundActive[] = {0.5,0.5,0.5,0.8};
    colorBackgroundDisabled[] = {0,0,0,0.5};
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.5,0.5,0.5,1};
    colorFocused[] = {0.5,0.5,0.5,0.8};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,0};
    font = "PuristaMedium";
    sizeEx = 0.03;
    soundEnter[] = {"",0,1};
    soundPush[] = {"",0,1};
    soundClick[] = {"",0,1};
    soundEscape[] = {"",0,1};
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0;
};

class ObjectPlacerDialog {
    idd = 9002;
    movingEnable = false;
    class controls {
        class CategoryList : RscListBox {
            idc = 2001;
            x = 0.25;
            y = 0.25;
            w = 0.2;
            h = 0.45;
            onLBSelChanged = "[] call fnc_updateObjectList;";
        };
        class ObjectList : RscListBox {
            idc = 2002;
            x = 0.46;
            y = 0.25;
            w = 0.28;
            h = 0.45;
        };
        class BtnConfirm : RscButton {
            idc = 2003;
            text = "Выбрать";
            x = 0.46;
            y = 0.72;
            w = 0.13;
            h = 0.04;
            action = "[] call fnc_confirmObjectSelect;";
        };
        class BtnCancel : RscButton {
            idc = 2004;
            text = "Отмена";
            x = 0.61;
            y = 0.72;
            w = 0.13;
            h = 0.04;
            action = "closeDialog 0;";
        };
    };
};
