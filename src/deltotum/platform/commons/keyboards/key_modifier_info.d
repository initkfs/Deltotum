module deltotum.platform.commons.keyboards.key_modifier_info;

/**
 * Authors: initkfs
 */
struct KeyModifierInfo
{
    bool isLeftShift;
    bool isRightShift;
    
    bool isLeftCtrl;
    bool isRightCtrl;
    
    bool isLeftAlt;
    bool isRightAlt;
    
    bool isLeftGui;
    bool isRightGui;
    
    bool isNum;
    bool isCaps;
    bool isAltGr;
    bool isScrollLock;

    bool isCtrl()
    {
        return isLeftCtrl || isRightCtrl;
    }

    bool isAlt()
    {
        return isLeftAlt || isRightAlt;
    }

    bool isShift()
    {
        return isLeftShift || isRightShift;
    }
}
