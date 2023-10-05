module deltotum.core.apps.caps.cap_core;

class CapCore
{
    bool isLuaExtension;
    
    bool isEmbeddedScripting(){
        return isLuaExtension;
    }
}
