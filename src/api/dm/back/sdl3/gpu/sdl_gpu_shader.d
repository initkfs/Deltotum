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
    this(SDL_GPUShader* shaderPtr)
    {
        super(shaderPtr);
    }

    bool disposeWithGpu(SDL_GPUDevice* gpuPtr){
        if(!ptr){
            return false;
        }
        
        SDL_ReleaseGPUShader(gpuPtr, ptr);
        ptr = null;
        return true;
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            assert(false, "Unable disposing without GPUDevice");
        }
        return false;
    }

}
