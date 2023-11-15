module dm.core.apps.caps.cap_core;

class CapCore
{
    bool isLuaExtension;
    
    bool isEmbeddedScripting(){
        return isLuaExtension;
    }
}
