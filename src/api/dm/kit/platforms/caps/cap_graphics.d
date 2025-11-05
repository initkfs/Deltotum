module api.dm.kit.platforms.caps.cap_graphics;

import api.core.components.component_service : ComponentService;

class CapGraphics : ComponentService
{
    bool isAudio;
    //bool isJoystick;
    bool isJoystick;
    bool isIconPack;
    bool isPointer = true;
    
    bool isVectorGraphics;
    bool isImageProcessing;
    
    bool isPhysics;
}
