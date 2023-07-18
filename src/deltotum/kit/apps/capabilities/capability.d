module deltotum.kit.apps.capabilities.capability;

class Capability
{
    bool isVectorGraphics;
    bool isImageProcessing;

    bool isLuaExtension;
    bool isJuliaExtension;
    
    bool isPhysics;

    bool isEmbeddedScripting(){
        return isLuaExtension || isJuliaExtension;
    }
}
