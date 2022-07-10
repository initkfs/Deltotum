module deltotum.animation.transition;

import deltotum.display.display_object : DisplayObject;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.animation.interp.uni_interpolator : UniInterpolator;

private
{
    enum TransitionState
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
class Transition : DisplayObject
{
    @property void delegate(double) onValue;
    @property bool isInverse;
    @property bool isCycle = true;
    @property UniInterpolator interpolator;

    private
    {
        double timeMs = 0;
        double frameCount = 0;
        long currentFrame;
        double minValue = 0;
        double maxValue = 0;

        TransitionState state = TransitionState.none;
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
            this.interpolator = new UniInterpolator;
        }
    }

    void run() @nogc nothrow @safe
    {
        state = TransitionState.direct;
    }

    void stop() @nogc nothrow @safe
    {
        state = TransitionState.end;
    }

    override void update(double delta)
    {
        if (state == TransitionState.none || state == TransitionState.end || onValue is null)
        {
            return;
        }

        super.update(delta);

        if (currentFrame > frameCount)
        {
            if (!isCycle)
            {
                state = TransitionState.end;
                return;
            }

            if (state == TransitionState.direct)
            {
                state = TransitionState.back;
            }
            else if (state == TransitionState.back)
            {
                state = TransitionState.direct;
            }
            currentFrame = 0;
        }

        double start;
        double end;
        switch (state)
        {
        case TransitionState.direct:
            start = minValue;
            end = maxValue;
            break;
        case TransitionState.back:
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
