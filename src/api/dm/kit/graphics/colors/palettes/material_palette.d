module api.dm.kit.graphics.colors.palettes.material_palette;

/**
 * Authors: initkfs
 */

enum size_t colorCount = 19;
enum size_t maxToneCount = 14;

immutable:

//Start colors
string red50 = "#ffebee";
string red100 = "#ffcdd2";
string red200 = "#ef9a9a";
string red300 = "#e57373";
string red400 = "#ef5350";
string red500 = "#f44336";
string red600 = "#e53935";
string red700 = "#d32f2f";
string red800 = "#c62828";
string red900 = "#b71c1c";
string redA100 = "#ff8a80";
string redA200 = "#ff5252";
string redA400 = "#ff1744";
string redA700 = "#d50000";

string pink50 = "#fce4ec";
string pink100 = "#f8bbd0";
string pink200 = "#f48fb1";
string pink300 = "#f06292";
string pink400 = "#ec407a";
string pink500 = "#e91e63";
string pink600 = "#d81b60";
string pink700 = "#c2185b";
string pink800 = "#ad1457";
string pink900 = "#880e4f";
string pinkA100 = "#ff80ab";
string pinkA200 = "#ff4081";
string pinkA400 = "#f50057";
string pinkA700 = "#c51162";

string purple50 = "#f3e5f5";
string purple100 = "#e1bee7";
string purple200 = "#ce93d8";
string purple300 = "#ba68c8";
string purple400 = "#ab47bc";
string purple500 = "#9c27b0";
string purple600 = "#8e24aa";
string purple700 = "#7b1fa2";
string purple800 = "#6a1b9a";
string purple900 = "#4a148c";
string purpleA100 = "#ea80fc";
string purpleA200 = "#e040fb";
string purpleA400 = "#d500f9";
string purpleA700 = "#aa00ff";

string deeppurple50 = "#ede7f6";
string deeppurple100 = "#d1c4e9";
string deeppurple200 = "#b39ddb";
string deeppurple300 = "#9575cd";
string deeppurple400 = "#7e57c2";
string deeppurple500 = "#673ab7";
string deeppurple600 = "#5e35b1";
string deeppurple700 = "#512da8";
string deeppurple800 = "#4527a0";
string deeppurple900 = "#311b92";
string deeppurpleA100 = "#b388ff";
string deeppurpleA200 = "#7c4dff";
string deeppurpleA400 = "#651fff";
string deeppurpleA700 = "#6200ea";

string indigo50 = "#e8eaf6";
string indigo100 = "#c5cae9";
string indigo200 = "#9fa8da";
string indigo300 = "#7986cb";
string indigo400 = "#5c6bc0";
string indigo500 = "#3f51b5";
string indigo600 = "#3949ab";
string indigo700 = "#303f9f";
string indigo800 = "#283593";
string indigo900 = "#1a237e";
string indigoA100 = "#8c9eff";
string indigoA200 = "#536dfe";
string indigoA400 = "#3d5afe";
string indigoA700 = "#304ffe";

string blue50 = "#e3f2fd";
string blue100 = "#bbdefb";
string blue200 = "#90caf9";
string blue300 = "#64b5f6";
string blue400 = "#42a5f5";
string blue500 = "#2196f3";
string blue600 = "#1e88e5";
string blue700 = "#1976d2";
string blue800 = "#1565c0";
string blue900 = "#0d47a1";
string blueA100 = "#82b1ff";
string blueA200 = "#448aff";
string blueA400 = "#2979ff";
string blueA700 = "#2962ff";

string lightblue50 = "#e1f5fe";
string lightblue100 = "#b3e5fc";
string lightblue200 = "#81d4fa";
string lightblue300 = "#4fc3f7";
string lightblue400 = "#29b6f6";
string lightblue500 = "#03a9f4";
string lightblue600 = "#039be5";
string lightblue700 = "#0288d1";
string lightblue800 = "#0277bd";
string lightblue900 = "#01579b";
string lightblueA100 = "#80d8ff";
string lightblueA200 = "#40c4ff";
string lightblueA400 = "#00b0ff";
string lightblueA700 = "#0091ea";

string cyan50 = "#e0f7fa";
string cyan100 = "#b2ebf2";
string cyan200 = "#80deea";
string cyan300 = "#4dd0e1";
string cyan400 = "#26c6da";
string cyan500 = "#00bcd4";
string cyan600 = "#00acc1";
string cyan700 = "#0097a7";
string cyan800 = "#00838f";
string cyan900 = "#006064";
string cyanA100 = "#84ffff";
string cyanA200 = "#18ffff";
string cyanA400 = "#00e5ff";
string cyanA700 = "#00b8d4";

string teal50 = "#e0f2f1";
string teal100 = "#b2dfdb";
string teal200 = "#80cbc4";
string teal300 = "#4db6ac";
string teal400 = "#26a69a";
string teal500 = "#009688";
string teal600 = "#00897b";
string teal700 = "#00796b";
string teal800 = "#00695c";
string teal900 = "#004d40";
string tealA100 = "#a7ffeb";
string tealA200 = "#64ffda";
string tealA400 = "#1de9b6";
string tealA700 = "#00bfa5";

string green50 = "#e8f5e9";
string green100 = "#c8e6c9";
string green200 = "#a5d6a7";
string green300 = "#81c784";
string green400 = "#66bb6a";
string green500 = "#4caf50";
string green600 = "#43a047";
string green700 = "#388e3c";
string green800 = "#2e7d32";
string green900 = "#1b5e20";
string greenA100 = "#b9f6ca";
string greenA200 = "#69f0ae";
string greenA400 = "#00e676";
string greenA700 = "#00c853";

string lightgreen50 = "#f1f8e9";
string lightgreen100 = "#dcedc8";
string lightgreen200 = "#c5e1a5";
string lightgreen300 = "#aed581";
string lightgreen400 = "#9ccc65";
string lightgreen500 = "#8bc34a";
string lightgreen600 = "#7cb342";
string lightgreen700 = "#689f38";
string lightgreen800 = "#558b2f";
string lightgreen900 = "#33691e";
string lightgreenA100 = "#ccff90";
string lightgreenA200 = "#b2ff59";
string lightgreenA400 = "#76ff03";
string lightgreenA700 = "#64dd17";

string lime50 = "#f9fbe7";
string lime100 = "#f0f4c3";
string lime200 = "#e6ee9c";
string lime300 = "#dce775";
string lime400 = "#d4e157";
string lime500 = "#cddc39";
string lime600 = "#c0ca33";
string lime700 = "#afb42b";
string lime800 = "#9e9d24";
string lime900 = "#827717";
string limeA100 = "#f4ff81";
string limeA200 = "#eeff41";
string limeA400 = "#c6ff00";
string limeA700 = "#aeea00";

string yellow50 = "#fffde7";
string yellow100 = "#fff9c4";
string yellow200 = "#fff59d";
string yellow300 = "#fff176";
string yellow400 = "#ffee58";
string yellow500 = "#ffeb3b";
string yellow600 = "#fdd835";
string yellow700 = "#fbc02d";
string yellow800 = "#f9a825";
string yellow900 = "#f57f17";
string yellowA100 = "#ffff8d";
string yellowA200 = "#ffff00";
string yellowA400 = "#ffea00";
string yellowA700 = "#ffd600";

string amber50 = "#fff8e1";
string amber100 = "#ffecb3";
string amber200 = "#ffe082";
string amber300 = "#ffd54f";
string amber400 = "#ffca28";
string amber500 = "#ffc107";
string amber600 = "#ffb300";
string amber700 = "#ffa000";
string amber800 = "#ff8f00";
string amber900 = "#ff6f00";
string amberA100 = "#ffe57f";
string amberA200 = "#ffd740";
string amberA400 = "#ffc400";
string amberA700 = "#ffab00";

string orange50 = "#fff3e0";
string orange100 = "#ffe0b2";
string orange200 = "#ffcc80";
string orange300 = "#ffb74d";
string orange400 = "#ffa726";
string orange500 = "#ff9800";
string orange600 = "#fb8c00";
string orange700 = "#f57c00";
string orange800 = "#ef6c00";
string orange900 = "#e65100";
string orangeA100 = "#ffd180";
string orangeA200 = "#ffab40";
string orangeA400 = "#ff9100";
string orangeA700 = "#ff6d00";

string deeporange50 = "#fbe9e7";
string deeporange100 = "#ffccbc";
string deeporange200 = "#ffab91";
string deeporange300 = "#ff8a65";
string deeporange400 = "#ff7043";
string deeporange500 = "#ff5722";
string deeporange600 = "#f4511e";
string deeporange700 = "#e64a19";
string deeporange800 = "#d84315";
string deeporange900 = "#bf360c";
string deeporangeA100 = "#ff9e80";
string deeporangeA200 = "#ff6e40";
string deeporangeA400 = "#ff3d00";
string deeporangeA700 = "#dd2c00";

string brown50 = "#efebe9";
string brown100 = "#d7ccc8";
string brown200 = "#bcaaa4";
string brown300 = "#a1887f";
string brown400 = "#8d6e63";
string brown500 = "#795548";
string brown600 = "#6d4c41";
string brown700 = "#5d4037";
string brown800 = "#4e342e";
string brown900 = "#3e2723";

string grey50 = "#fafafa";
string grey100 = "#f5f5f5";
string grey200 = "#eeeeee";
string grey300 = "#e0e0e0";
string grey400 = "#bdbdbd";
string grey500 = "#9e9e9e";
string grey600 = "#757575";
string grey700 = "#616161";
string grey800 = "#424242";
string grey900 = "#212121";

string bluegrey50 = "#eceff1";
string bluegrey100 = "#cfd8dc";
string bluegrey200 = "#b0bec5";
string bluegrey300 = "#90a4ae";
string bluegrey400 = "#78909c";
string bluegrey500 = "#607d8b";
string bluegrey600 = "#546e7a";
string bluegrey700 = "#455a64";
string bluegrey800 = "#37474f";
string bluegrey900 = "#263238";

void onColor(scope bool delegate(string color, size_t colorIndex) onColorIsContinue)
{
    size_t colorIndex;
    if (!onColorIsContinue(red50, colorIndex++))
        return;
    if (!onColorIsContinue(red100, colorIndex++))
        return;
    if (!onColorIsContinue(red200, colorIndex++))
        return;
    if (!onColorIsContinue(red300, colorIndex++))
        return;
    if (!onColorIsContinue(red400, colorIndex++))
        return;
    if (!onColorIsContinue(red500, colorIndex++))
        return;
    if (!onColorIsContinue(red600, colorIndex++))
        return;
    if (!onColorIsContinue(red700, colorIndex++))
        return;
    if (!onColorIsContinue(red800, colorIndex++))
        return;
    if (!onColorIsContinue(red900, colorIndex++))
        return;
    if (!onColorIsContinue(redA100, colorIndex++))
        return;
    if (!onColorIsContinue(redA200, colorIndex++))
        return;
    if (!onColorIsContinue(redA400, colorIndex++))
        return;
    if (!onColorIsContinue(redA700, colorIndex++))
        return;
    if (!onColorIsContinue(pink50, colorIndex++))
        return;
    if (!onColorIsContinue(pink100, colorIndex++))
        return;
    if (!onColorIsContinue(pink200, colorIndex++))
        return;
    if (!onColorIsContinue(pink300, colorIndex++))
        return;
    if (!onColorIsContinue(pink400, colorIndex++))
        return;
    if (!onColorIsContinue(pink500, colorIndex++))
        return;
    if (!onColorIsContinue(pink600, colorIndex++))
        return;
    if (!onColorIsContinue(pink700, colorIndex++))
        return;
    if (!onColorIsContinue(pink800, colorIndex++))
        return;
    if (!onColorIsContinue(pink900, colorIndex++))
        return;
    if (!onColorIsContinue(pinkA100, colorIndex++))
        return;
    if (!onColorIsContinue(pinkA200, colorIndex++))
        return;
    if (!onColorIsContinue(pinkA400, colorIndex++))
        return;
    if (!onColorIsContinue(pinkA700, colorIndex++))
        return;
    if (!onColorIsContinue(purple50, colorIndex++))
        return;
    if (!onColorIsContinue(purple100, colorIndex++))
        return;
    if (!onColorIsContinue(purple200, colorIndex++))
        return;
    if (!onColorIsContinue(purple300, colorIndex++))
        return;
    if (!onColorIsContinue(purple400, colorIndex++))
        return;
    if (!onColorIsContinue(purple500, colorIndex++))
        return;
    if (!onColorIsContinue(purple600, colorIndex++))
        return;
    if (!onColorIsContinue(purple700, colorIndex++))
        return;
    if (!onColorIsContinue(purple800, colorIndex++))
        return;
    if (!onColorIsContinue(purple900, colorIndex++))
        return;
    if (!onColorIsContinue(purpleA100, colorIndex++))
        return;
    if (!onColorIsContinue(purpleA200, colorIndex++))
        return;
    if (!onColorIsContinue(purpleA400, colorIndex++))
        return;
    if (!onColorIsContinue(purpleA700, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple50, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple100, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple200, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple300, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple400, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple500, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple600, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple700, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple800, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurple900, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurpleA100, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurpleA200, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurpleA400, colorIndex++))
        return;
    if (!onColorIsContinue(deeppurpleA700, colorIndex++))
        return;
    if (!onColorIsContinue(indigo50, colorIndex++))
        return;
    if (!onColorIsContinue(indigo100, colorIndex++))
        return;
    if (!onColorIsContinue(indigo200, colorIndex++))
        return;
    if (!onColorIsContinue(indigo300, colorIndex++))
        return;
    if (!onColorIsContinue(indigo400, colorIndex++))
        return;
    if (!onColorIsContinue(indigo500, colorIndex++))
        return;
    if (!onColorIsContinue(indigo600, colorIndex++))
        return;
    if (!onColorIsContinue(indigo700, colorIndex++))
        return;
    if (!onColorIsContinue(indigo800, colorIndex++))
        return;
    if (!onColorIsContinue(indigo900, colorIndex++))
        return;
    if (!onColorIsContinue(indigoA100, colorIndex++))
        return;
    if (!onColorIsContinue(indigoA200, colorIndex++))
        return;
    if (!onColorIsContinue(indigoA400, colorIndex++))
        return;
    if (!onColorIsContinue(indigoA700, colorIndex++))
        return;
    if (!onColorIsContinue(blue50, colorIndex++))
        return;
    if (!onColorIsContinue(blue100, colorIndex++))
        return;
    if (!onColorIsContinue(blue200, colorIndex++))
        return;
    if (!onColorIsContinue(blue300, colorIndex++))
        return;
    if (!onColorIsContinue(blue400, colorIndex++))
        return;
    if (!onColorIsContinue(blue500, colorIndex++))
        return;
    if (!onColorIsContinue(blue600, colorIndex++))
        return;
    if (!onColorIsContinue(blue700, colorIndex++))
        return;
    if (!onColorIsContinue(blue800, colorIndex++))
        return;
    if (!onColorIsContinue(blue900, colorIndex++))
        return;
    if (!onColorIsContinue(blueA100, colorIndex++))
        return;
    if (!onColorIsContinue(blueA200, colorIndex++))
        return;
    if (!onColorIsContinue(blueA400, colorIndex++))
        return;
    if (!onColorIsContinue(blueA700, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue50, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue100, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue200, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue300, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue400, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue500, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue600, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue700, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue800, colorIndex++))
        return;
    if (!onColorIsContinue(lightblue900, colorIndex++))
        return;
    if (!onColorIsContinue(lightblueA100, colorIndex++))
        return;
    if (!onColorIsContinue(lightblueA200, colorIndex++))
        return;
    if (!onColorIsContinue(lightblueA400, colorIndex++))
        return;
    if (!onColorIsContinue(lightblueA700, colorIndex++))
        return;
    if (!onColorIsContinue(cyan50, colorIndex++))
        return;
    if (!onColorIsContinue(cyan100, colorIndex++))
        return;
    if (!onColorIsContinue(cyan200, colorIndex++))
        return;
    if (!onColorIsContinue(cyan300, colorIndex++))
        return;
    if (!onColorIsContinue(cyan400, colorIndex++))
        return;
    if (!onColorIsContinue(cyan500, colorIndex++))
        return;
    if (!onColorIsContinue(cyan600, colorIndex++))
        return;
    if (!onColorIsContinue(cyan700, colorIndex++))
        return;
    if (!onColorIsContinue(cyan800, colorIndex++))
        return;
    if (!onColorIsContinue(cyan900, colorIndex++))
        return;
    if (!onColorIsContinue(cyanA100, colorIndex++))
        return;
    if (!onColorIsContinue(cyanA200, colorIndex++))
        return;
    if (!onColorIsContinue(cyanA400, colorIndex++))
        return;
    if (!onColorIsContinue(cyanA700, colorIndex++))
        return;
    if (!onColorIsContinue(teal50, colorIndex++))
        return;
    if (!onColorIsContinue(teal100, colorIndex++))
        return;
    if (!onColorIsContinue(teal200, colorIndex++))
        return;
    if (!onColorIsContinue(teal300, colorIndex++))
        return;
    if (!onColorIsContinue(teal400, colorIndex++))
        return;
    if (!onColorIsContinue(teal500, colorIndex++))
        return;
    if (!onColorIsContinue(teal600, colorIndex++))
        return;
    if (!onColorIsContinue(teal700, colorIndex++))
        return;
    if (!onColorIsContinue(teal800, colorIndex++))
        return;
    if (!onColorIsContinue(teal900, colorIndex++))
        return;
    if (!onColorIsContinue(tealA100, colorIndex++))
        return;
    if (!onColorIsContinue(tealA200, colorIndex++))
        return;
    if (!onColorIsContinue(tealA400, colorIndex++))
        return;
    if (!onColorIsContinue(tealA700, colorIndex++))
        return;
    if (!onColorIsContinue(green50, colorIndex++))
        return;
    if (!onColorIsContinue(green100, colorIndex++))
        return;
    if (!onColorIsContinue(green200, colorIndex++))
        return;
    if (!onColorIsContinue(green300, colorIndex++))
        return;
    if (!onColorIsContinue(green400, colorIndex++))
        return;
    if (!onColorIsContinue(green500, colorIndex++))
        return;
    if (!onColorIsContinue(green600, colorIndex++))
        return;
    if (!onColorIsContinue(green700, colorIndex++))
        return;
    if (!onColorIsContinue(green800, colorIndex++))
        return;
    if (!onColorIsContinue(green900, colorIndex++))
        return;
    if (!onColorIsContinue(greenA100, colorIndex++))
        return;
    if (!onColorIsContinue(greenA200, colorIndex++))
        return;
    if (!onColorIsContinue(greenA400, colorIndex++))
        return;
    if (!onColorIsContinue(greenA700, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen50, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen100, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen200, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen300, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen400, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen500, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen600, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen700, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen800, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreen900, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreenA100, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreenA200, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreenA400, colorIndex++))
        return;
    if (!onColorIsContinue(lightgreenA700, colorIndex++))
        return;
    if (!onColorIsContinue(lime50, colorIndex++))
        return;
    if (!onColorIsContinue(lime100, colorIndex++))
        return;
    if (!onColorIsContinue(lime200, colorIndex++))
        return;
    if (!onColorIsContinue(lime300, colorIndex++))
        return;
    if (!onColorIsContinue(lime400, colorIndex++))
        return;
    if (!onColorIsContinue(lime500, colorIndex++))
        return;
    if (!onColorIsContinue(lime600, colorIndex++))
        return;
    if (!onColorIsContinue(lime700, colorIndex++))
        return;
    if (!onColorIsContinue(lime800, colorIndex++))
        return;
    if (!onColorIsContinue(lime900, colorIndex++))
        return;
    if (!onColorIsContinue(limeA100, colorIndex++))
        return;
    if (!onColorIsContinue(limeA200, colorIndex++))
        return;
    if (!onColorIsContinue(limeA400, colorIndex++))
        return;
    if (!onColorIsContinue(limeA700, colorIndex++))
        return;
    if (!onColorIsContinue(yellow50, colorIndex++))
        return;
    if (!onColorIsContinue(yellow100, colorIndex++))
        return;
    if (!onColorIsContinue(yellow200, colorIndex++))
        return;
    if (!onColorIsContinue(yellow300, colorIndex++))
        return;
    if (!onColorIsContinue(yellow400, colorIndex++))
        return;
    if (!onColorIsContinue(yellow500, colorIndex++))
        return;
    if (!onColorIsContinue(yellow600, colorIndex++))
        return;
    if (!onColorIsContinue(yellow700, colorIndex++))
        return;
    if (!onColorIsContinue(yellow800, colorIndex++))
        return;
    if (!onColorIsContinue(yellow900, colorIndex++))
        return;
    if (!onColorIsContinue(yellowA100, colorIndex++))
        return;
    if (!onColorIsContinue(yellowA200, colorIndex++))
        return;
    if (!onColorIsContinue(yellowA400, colorIndex++))
        return;
    if (!onColorIsContinue(yellowA700, colorIndex++))
        return;
    if (!onColorIsContinue(amber50, colorIndex++))
        return;
    if (!onColorIsContinue(amber100, colorIndex++))
        return;
    if (!onColorIsContinue(amber200, colorIndex++))
        return;
    if (!onColorIsContinue(amber300, colorIndex++))
        return;
    if (!onColorIsContinue(amber400, colorIndex++))
        return;
    if (!onColorIsContinue(amber500, colorIndex++))
        return;
    if (!onColorIsContinue(amber600, colorIndex++))
        return;
    if (!onColorIsContinue(amber700, colorIndex++))
        return;
    if (!onColorIsContinue(amber800, colorIndex++))
        return;
    if (!onColorIsContinue(amber900, colorIndex++))
        return;
    if (!onColorIsContinue(amberA100, colorIndex++))
        return;
    if (!onColorIsContinue(amberA200, colorIndex++))
        return;
    if (!onColorIsContinue(amberA400, colorIndex++))
        return;
    if (!onColorIsContinue(amberA700, colorIndex++))
        return;
    if (!onColorIsContinue(orange50, colorIndex++))
        return;
    if (!onColorIsContinue(orange100, colorIndex++))
        return;
    if (!onColorIsContinue(orange200, colorIndex++))
        return;
    if (!onColorIsContinue(orange300, colorIndex++))
        return;
    if (!onColorIsContinue(orange400, colorIndex++))
        return;
    if (!onColorIsContinue(orange500, colorIndex++))
        return;
    if (!onColorIsContinue(orange600, colorIndex++))
        return;
    if (!onColorIsContinue(orange700, colorIndex++))
        return;
    if (!onColorIsContinue(orange800, colorIndex++))
        return;
    if (!onColorIsContinue(orange900, colorIndex++))
        return;
    if (!onColorIsContinue(orangeA100, colorIndex++))
        return;
    if (!onColorIsContinue(orangeA200, colorIndex++))
        return;
    if (!onColorIsContinue(orangeA400, colorIndex++))
        return;
    if (!onColorIsContinue(orangeA700, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange50, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange100, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange200, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange300, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange400, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange500, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange600, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange700, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange800, colorIndex++))
        return;
    if (!onColorIsContinue(deeporange900, colorIndex++))
        return;
    if (!onColorIsContinue(deeporangeA100, colorIndex++))
        return;
    if (!onColorIsContinue(deeporangeA200, colorIndex++))
        return;
    if (!onColorIsContinue(deeporangeA400, colorIndex++))
        return;
    if (!onColorIsContinue(deeporangeA700, colorIndex++))
        return;
    if (!onColorIsContinue(brown50, colorIndex++))
        return;
    if (!onColorIsContinue(brown100, colorIndex++))
        return;
    if (!onColorIsContinue(brown200, colorIndex++))
        return;
    if (!onColorIsContinue(brown300, colorIndex++))
        return;
    if (!onColorIsContinue(brown400, colorIndex++))
        return;
    if (!onColorIsContinue(brown500, colorIndex++))
        return;
    if (!onColorIsContinue(brown600, colorIndex++))
        return;
    if (!onColorIsContinue(brown700, colorIndex++))
        return;
    if (!onColorIsContinue(brown800, colorIndex++))
        return;
    if (!onColorIsContinue(brown900, colorIndex++))
        return;
    if (!onColorIsContinue(grey50, colorIndex++))
        return;
    if (!onColorIsContinue(grey100, colorIndex++))
        return;
    if (!onColorIsContinue(grey200, colorIndex++))
        return;
    if (!onColorIsContinue(grey300, colorIndex++))
        return;
    if (!onColorIsContinue(grey400, colorIndex++))
        return;
    if (!onColorIsContinue(grey500, colorIndex++))
        return;
    if (!onColorIsContinue(grey600, colorIndex++))
        return;
    if (!onColorIsContinue(grey700, colorIndex++))
        return;
    if (!onColorIsContinue(grey800, colorIndex++))
        return;
    if (!onColorIsContinue(grey900, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey50, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey100, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey200, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey300, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey400, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey500, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey600, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey700, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey800, colorIndex++))
        return;
    if (!onColorIsContinue(bluegrey900, colorIndex++))
        return;
}
