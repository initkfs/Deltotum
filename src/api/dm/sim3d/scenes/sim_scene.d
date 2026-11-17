module api.dm.sim3d.scenes.sim_scene;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites3d.textures.tex3d : Tex3d;
import api.dm.sim3d.diffusions.diffusion_pass : DiffusionPass;
import api.math.matrices.matrix;

import std.datetime.date : DateTime;

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
        Tex3d _diffusionPlaceholder;
    }

    long clockUnixSec;
    int clockUpdateFrames;
    int clockUpdateAccum;

    long clockUpdateSec = 1;
    long clockUpdateAddSec = 5;

    bool isNeedDiffusionTexture = true;

    protected
    {
        DateTime _startDate;
    }

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor : false);
        initProcessUDA!ThisType(isInitUDAProcessor);
        isAutoSizeToWindow = true;
    }

    override void create()
    {
        super.create;

        assert(window.frameRate > 0);
        clockUpdateFrames = cast(typeof(clockUpdateFrames))(clockUpdateSec * window.frameRate);

        if (!platform.cap.isGPU)
        {
            return;
        }

        _diffusionPass = new DiffusionPass;
        buildInitCreate(_diffusionPass);

        if (!_diffusionPass)
        {
            import api.dm.kit.graphics.colors.rgba : RGBA;

            _diffusionPlaceholder = new Tex3d;
            _diffusionPlaceholder.isNeedCamera = false;
            _diffusionPlaceholder.isNeedDispose = false;
            buildInit(_diffusionPlaceholder);
            _diffusionPlaceholder.create(1, 1, RGBA.white);
        }
    }

    void updateClock(float dt)
    {
        
    }

    override void update(float dt)
    {
        super.update(dt);

        if (clockUpdateAccum >= clockUpdateFrames)
        {
            import api.core.utils.time : nowTime;

            clockUnixSec += clockUpdateAddSec;
            clockUpdateAccum = 0;
            updateClock(dt);
        }
        else
        {
            clockUpdateAccum++;
        }

    }

    override void onStartCmdBuffer(float alpha)
    {
        super.onStartCmdBuffer(alpha);

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

    void startDateUTC(DateTime dt)
    {
        import std.datetime : DateTime, SysTime, UTC;

        _startDate = dt;
        SysTime sysTime = SysTime(dt, UTC());
        clockUnixSec = sysTime.toUnixTime();
    }

    DateTime startDateUTC()
    {
        import core.stdc.time : time_t, tm, gmtime;

        tm* t = gmtime(&clockUnixSec);
        if (!t)
        {
            return DateTime(1970, 1, 1, 0, 0, 0);
        }

        return DateTime(
            t.tm_year + 1900,
            t.tm_mon + 1,
            t.tm_mday,
            t.tm_hour,
            t.tm_min,
            t.tm_sec
        );
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
