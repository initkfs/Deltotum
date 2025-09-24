module api.dm.back.sdl3.gpu.sdl_gpu_pipeline;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import api.dm.back.sdl3.externs.csdl3;

class SdlGPUPipeline : SdlObjectWrapper!SDL_GPUGraphicsPipeline
{
    this(SDL_GPUGraphicsPipeline* newPtr)
    {
        super(newPtr);
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
