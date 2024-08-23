module api.dm.addon.math.curves.curve_maker;
import api.math.vector2 : Vector2;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class CurveMaker
{
    bool isReverse;

    //FIXME default argument expected for `onNextStepIsContinue`
    protected void parametricEqOfT(double dots = 1000, double step = 0.01, scope bool delegate(
            double) onNextStepIsContinue = null)
    {
        if (!onNextStepIsContinue)
        {
            return;
        }
        double dt = 0;
        foreach (dot; 0 .. dots)
        {
            const resultDt = isReverse ? -(dt) : dt;
            if (!onNextStepIsContinue(resultDt))
            {
                break;
            }
            dt += step;
        }
    }
    
    void pointsIteration(double step, double minValueInclusive, double maxValueInclusive, scope bool delegate(
            double) onNextStepIsContinue)
    {
        assert(minValueInclusive < maxValueInclusive);
        assert(step > 0 && step < maxValueInclusive);

        for (double i = minValueInclusive; i <= maxValueInclusive; i += step)
        {
            const resultDt = isReverse ? -(i) : i;
            if (!onNextStepIsContinue(resultDt))
            {
                break;
            }
        }
    }
}
