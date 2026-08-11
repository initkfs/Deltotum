module api.dm.kit.platforms.caps.cap_graphics;

import api.core.components.component_service : ComponentService;

class CapGraphics : ComponentService
{
    bool isPointer = true;
    
    bool isImage = true;
    bool isIconPack = true;
    bool isVector = true;
    bool isFont = true;
    bool isWeb = true;
   
    bool isAudio = true;
    bool isVideo = true;
    bool isJoystick;
    bool isGPU;
}
