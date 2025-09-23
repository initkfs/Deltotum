module api.dm.back.sdl3.gpu.gpu_device;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

alias ComShaderFormat = SDL_GPUShaderFormat;

enum ComGPUDriver : string
{
    any = null,
    vulkan = "vulkan",
    direct3d12 = "direct3d12",
    metal = "metal"
}

class SdlGPUDevice : SdlObjectWrapper!SDL_GPUDevice
{
    protected
    {
        string driverName;
    }

    this()
    {

    }

    this(SDL_GPUDevice* newPtr)
    {
        super(newPtr);
    }

    ComResult create(ComShaderFormat foramtFlags = SDL_GPU_SHADERFORMAT_SPIRV, bool isDebugMode = false, string driverName = ComGPUDriver
            .any)
    {
        this.driverName = driverName;

        ptr = SDL_CreateGPUDevice(
            foramtFlags,
            isDebugMode,
            driverName.length > 0 ? driverName.toStringz : null);
        if (!ptr)
        {
            return getErrorRes("GPU device not created");
        }
        return ComResult.success;
    }

    string getLastErrorStr() => getError;

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_DestroyGPUDevice(ptr);
            return true;
        }
        return false;
    }

    ComResult getDriverNameNew(out string name)
    {
        assert(ptr);
        const char* namePtr = SDL_GetGPUDeviceDriver(ptr);
        if (!namePtr)
        {
            return getErrorRes("GPU driver name is null");
        }
        name = namePtr.fromStringz.idup;
        return ComResult.success;
    }

    //This must be called before SDL_AcquireGPUSwapchainTexture is called using the window. 
    ComResult attachToWindow(ComWindow window)
    {
        assert(window);
        assert(ptr);

        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr natWinPtr;
        if (const err = window.nativePtr(natWinPtr))
        {
            return err;
        }

        SDL_Window* sdlWinPtr = natWinPtr.castSafe!(SDL_Window*);

        return attachToWindow(sdlWinPtr);
    }

    ComResult attachToWindow(SDL_Window* sdlWinPtr)
    {
        assert(sdlWinPtr);
        assert(ptr);

        if (!SDL_ClaimWindowForGPUDevice(ptr, sdlWinPtr))
        {
            return getErrorRes("Error window for GPU");
        }

        return ComResult.success;
    }

    ComResult releaseFromWindow(ComWindow window)
    {
        assert(window);
        assert(ptr);

        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr natWinPtr;
        if (const err = window.nativePtr(natWinPtr))
        {
            return err;
        }

        SDL_Window* sdlWinPtr = natWinPtr.castSafe!(SDL_Window*);

        return releaseFromWindow(sdlWinPtr);
    }

    ComResult releaseFromWindow(SDL_Window* sdlWinPtr)
    {
        assert(sdlWinPtr);
        assert(ptr);

        SDL_ReleaseWindowFromGPUDevice(ptr, sdlWinPtr);

        return ComResult.success;
    }

}
