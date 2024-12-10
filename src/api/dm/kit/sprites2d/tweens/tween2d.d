module api.dm.kit.sprites2d.tweens.tween2d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.tweens.tween : Tween, TweenState;
import api.dm.kit.tweens.curves.interpolator : Interpolator;

/**
 * Authors: initkfs
 */
abstract class Tween2d : Sprite2d
{
    protected
    {
        Tween tween;
    }

    bool isReverse() => tween.isReverse;
    bool isReverse(bool v) => tween.isReverse = v;

    bool isInfinite() => tween.isInfinite;
    bool isInfinite(bool v) => tween.isInfinite = v;

    bool isOneShort() => tween.isOneShort;
    bool isOneShort(bool v) => tween.isOneShort = v;

    size_t cycleCount() => tween.cycleCount;
    void cycleCount(size_t v){
        tween.cycleCount = v;
    };

    alias onResume = Sprite2d.onResume;

    ref void delegate()[] onRun() => tween.onRun;
    ref void delegate()[] onStop() => tween.onStop;
    ref void delegate()[] onPause() => tween.onPause;
    ref void delegate()[] onResume() => tween.onResume;
    ref void delegate()[] onEnd() => tween.onEnd;

    double frameRateHz() => tween.frameRateHz;
    void frameRateHz(double v)
    {
        tween.frameRateHz = v;
    }

    double timeMs() => tween.timeMs;
    void timeMs(double v)
    {
        tween.timeMs = v;
    }

    bool isThrowInvalidTime() => tween.isThrowInvalidTime;
    bool isThrowInvalidTime(bool v) => tween.isThrowInvalidTime = v;

    this(Tween tween)
    {
        super();

        assert(tween);
        this.tween = tween;

        tween.onStop ~= (){
            if(isRunning){
                stop;
            }
        };

        isManaged = true;
        //isVisible = false;
        isLayoutManaged = false;
        isManagedByScene = true;
    }

    double frameRate() => tween.frameRate;
    double frameCount(double frameRateHz) => tween.frameCount(frameRateHz);
    double frameCount() => tween.frameCount;

    override void initialize(){
        super.initialize;

        buildInit(tween);
    }

    override void create(){
        super.create;
        tween.create;
    }

    override void run()
    {
        super.run;
        tween.run;
    }

    override void pause()
    {
        super.pause;
        tween.pause;
    }

    override void stop()
    {
        super.stop;
        if(tween.isRunning){
            tween.stop;
        }
    }

    override void update(double delta)
    {
        if (!isRunning)
        {
            return;
        }

        super.update(delta);

        tween.update(delta);
    }

    void reverse()
    {
        tween.reverse;
    }

    void prev(Tween2d newPrev)
    {
        tween.prev = newPrev.tween;
    }

    void prev(Tween2d[] newPrevs...)
    {
        foreach (t; newPrevs)
        {
            prev(t);
        }
    }

    void next(Tween2d newNext)
    {
        tween.next = newNext.tween;
    }

    void next(Tween2d[] newNexts...)
    {
        foreach (t; newNexts)
        {
            next(t);
        }
    }

    bool removeOnRun(void delegate() dg) => tween.removeOnRun(dg);
    bool removeOnStop(void delegate() dg) => tween.removeOnStop(dg);
    bool removeOnResume(void delegate() dg) => tween.removeOnResume(dg);
    bool removeOnEnd(void delegate() dg) =>tween.removeOnEnd(dg);

    override void dispose()
    {
        if (isRunning)
        {
            stop;
        }

        tween.dispose;

        super.dispose;

    }

}
