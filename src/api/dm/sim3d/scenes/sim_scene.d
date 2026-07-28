module api.dm.sim3d.scenes.sim_scene;

import api.dm.gui.scenes.gui_scene: GuiScene;
import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;
import api.dm.sim3d.diffusions.diffusion_pass : DiffusionPass;
import api.math.matrices.matrix;

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class SimScene : GuiScene
{

    protected
    {
        DiffusionPass _diffusionPass;
        TextureGPU _diffusionPlaceholder;
    }

    bool isNeedDiffusionTexture = true;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor: false);
        initProcessUDA!ThisType(isInitUDAProcessor);
        isAutoSizeToWindow = true;
    }

    override void create()
    {
        super.create;

        if (!platform.cap.isGPU)
        {
            return;
        }

        _diffusionPass = new DiffusionPass;
        buildInitCreate(_diffusionPass);

        if (!_diffusionPass)
        {
            import api.dm.kit.graphics.colors.rgba : RGBA;

            _diffusionPlaceholder = new TextureGPU;
            _diffusionPlaceholder.isNeedCamera = false;
            _diffusionPlaceholder.isNeedDispose = false;
            buildInit(_diffusionPlaceholder);
            _diffusionPlaceholder.create(1, 1, RGBA.white);
        }
    }

    override void onStartCmdBuffer(float alpha)
    {
        if (_diffusionPass)
        {
            _diffusionPass.draw(alpha);
        }
    }

    override void onStartRenderPass(float alpha)
    {
        auto diffusionTexture = _diffusionPass ? _diffusionPass.outputTexture
            : _diffusionPlaceholder;
        gpu.dev.bindFragmentSamplers(diffusionTexture, 6);
    }

    bool hasDiffusionPass() => _diffusionPass !is null;

    DiffusionPass diffusionPass()
    {
        if (!_diffusionPass)
        {
            throw new Exception("Diffusion pass is null");
        }
        return _diffusionPass;
    }

    override void dispose()
    {
        super.dispose;

        if (_diffusionPlaceholder)
        {
            _diffusionPlaceholder.dispose;
        }

        if (_diffusionPass)
        {
            _diffusionPass.dispose;
        }
    }
}
