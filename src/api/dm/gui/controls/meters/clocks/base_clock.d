module api.dm.gui.controls.meters.clocks.base_clock;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;

import std.datetime.systime : Clock, SysTime;

/**
 * Authors: initkfs
 */
class BaseClock(ClockFace) : Control
{
    protected
    {
        SysTime _current;
    }

    bool isAutorun;

    ClockFace clockFace;
    bool isCreateClockFace = true;
    ClockFace delegate(ClockFace) onNewClockFace;
    void delegate(ClockFace) onConfiguredClockFace;
    void delegate(ClockFace) onCreatedClockFace;

    Tween2d clockAnimation;
    bool isCreateClockAnimation = true;
    Tween2d delegate(Tween2d) onNewClockAnimation;
    void delegate(Sprite2d) onConfiguredClockAnimation;
    void delegate(Tween2d) onCreatedClockAnimation;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    abstract
    {
        ClockFace newClockFace();
    }

    override void create()
    {
        super.create;

        if (!clockFace && isCreateClockFace)
        {
            auto face = newClockFace;
            clockFace = !onNewClockFace ? face : onNewClockFace(face);

            if (onConfiguredClockFace)
            {
                onConfiguredClockFace(clockFace);
            }

            addCreate(clockFace);

            if (onCreatedClockFace)
            {
                onCreatedClockFace(clockFace);
            }
        }

        if (!clockAnimation)
        {
            clockAnimation = new PauseTween2d(1000);
            clockAnimation.isInfinite = true;
            clockAnimation.onEnd ~= () { setCurrentTime; };
            addCreate(clockAnimation);
        }

        if (isAutorun)
        {
            run;
            clockAnimation.run;
        }
    }

    override void run()
    {
        super.run;
        if (clockFace && !clockFace.isRunning)
        {
            clockFace.run;
        }
    }

    protected bool updateTime(ubyte hour, ubyte min, ubyte sec)
    {
        if (!clockFace)
        {
            return false;
        }

        return clockFace.setTime(hour, min, sec);
    }

    void setCurrentTime()
    {
        time(Clock.currTime);
    }

    void time(SysTime newTime)
    {
        _current = newTime;
        updateTime(newTime.hour, newTime.minute, newTime.second);
    }

    SysTime time() => _current;

    Tween2d newClockAnimation()
    {
        return new PauseTween2d(1000);
    }
}
