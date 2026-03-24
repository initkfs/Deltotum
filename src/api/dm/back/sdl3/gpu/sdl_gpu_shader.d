module api.dm.back.sdl3.gpu.sdl_gpu_shader;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import api.dm.back.sdl3.externs.csdl3;

/** 
 * 
https://wiki.libsdl.org/SDL3/SDL_CreateGPUShader
For SPIR-V shaders, use the following resource sets:

For vertex shaders:

0: Sampled textures, followed by storage textures, followed by storage buffers
1: Uniform buffers
For fragment shaders:

2: Sampled textures, followed by storage textures, followed by storage buffers
3: Uniform buffers
*/
class SdlGPUShader : SdlObjectWrapper!SDL_GPUShader
{
    protected
    {
        SDL_GPUDevice* gpuDevice;
    }

    this(SDL_GPUShader* shaderPtr, SDL_GPUDevice* gpuDevice)
    {
        super(shaderPtr);
        assert(gpuDevice);
        this.gpuDevice = gpuDevice;
    }

    override protected bool disposePtr() nothrow
    {
        if (!ptr)
        {
            return false;
        }

        SDL_ReleaseGPUShader(gpuDevice, ptr);
        setNullPtr;
        return true;
    }

}
