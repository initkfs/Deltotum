module deltotum.tweens.tween;

import deltotum.display.display_object : DisplayObject;
import deltotum.tweens.interp.interpolator : Interpolator;
import deltotum.tweens.interp.linear : Linear;

private
{
    enum TweenState
    {
        none,
        direct,
        back,
        end
    }
}

/**
 * Authors: initkfs
 */
class Tween : DisplayObject
{
    @property void delegate(double) onValue;
    @property bool isInverse;
    @property bool isCycle = true;
    @property Interpolator interpolator;

    private
    {
        double timeMs = 0;
        double frameCount = 0;
        long currentFrame;
        double minValue = 0;
        double maxValue = 0;

        TweenState state = TweenState.none;
    }

    this(double minValue, double maxValue, int timeMs, double frameRateHz, Interpolator interpolator = null)
    {
        super();
        this.minValue = minValue;
        this.maxValue = maxValue;
        this.timeMs = timeMs;
        frameCount = (timeMs * frameRateHz) / 1000;
        if (interpolator is null)
        {
            this.interpolator = new Linear;
        }
    }

    void run() @nogc nothrow @safe
    {
        state = TweenState.direct;
    }

    void stop() @nogc nothrow @safe
    {
        state = TweenState.end;
    }

    override void update(double delta)
    {
        if (state == TweenState.none || state == TweenState.end || onValue is null)
        {
            return;
        }

        super.update(delta);

        if (currentFrame > frameCount)
        {
            if (!isCycle)
            {
                state = TweenState.end;
                return;
            }

            if (state == TweenState.direct)
            {
                state = TweenState.back;
            }
            else if (state == TweenState.back)
            {
                state = TweenState.direct;
            }
            currentFrame = 0;
        }

        double start;
        double end;
        switch (state)
        {
        case TweenState.direct:
            start = minValue;
            end = maxValue;
            break;
        case TweenState.back:
            start = maxValue;
            end = minValue;
            break;
        default:
            break;
        }

        double deltaT = currentFrame / frameCount;
        //TODO check is finite
        double value = interpolator.interpolate(start, end, deltaT);

        onValue(value);

        currentFrame++;
    }
}
