module deltotum.kit.apps.caps.cap;

class Cap
{
    bool isVideo;
    bool isAudio;
    bool isTimer;
    bool isJoystick;
    bool isIconPack;
    
    bool isVectorGraphics;
    bool isImageProcessing;

    bool isLuaExtension;
    bool isJuliaExtension;
    
    bool isPhysics;

    bool isEmbeddedScripting(){
        return isLuaExtension || isJuliaExtension;
    }
}
