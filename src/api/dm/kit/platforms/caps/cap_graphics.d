module api.dm.kit.platforms.caps.cap_graphics;

import api.core.components.component_service : ComponentService;

class CapGraphics : ComponentService
{
    bool isPointer = true;
    
    bool isImage;
    bool isIconPack;
    bool isVector;
   
    bool isAudio;
    bool isJoystick;
    bool is3d;
}
