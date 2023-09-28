module deltotum.kit.apps.caps.cap;

class Cap
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
