module api.dm.back.sdl3.gpu.sdl_gpu_pipeline;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import api.dm.back.sdl3.externs.csdl3;

class SdlGPUPipeline : SdlObjectWrapper!SDL_GPUGraphicsPipeline
{
    protected
    {
        SDL_GPUDevice* _dev;
    }

    this(SDL_GPUGraphicsPipeline* newPtr, SDL_GPUDevice* dev)
    {
        super(newPtr);
        this._dev = dev;
        assert(dev);
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_ReleaseGPUGraphicsPipeline(_dev, ptr);
            return true;
        }
        return false;
    }

}
