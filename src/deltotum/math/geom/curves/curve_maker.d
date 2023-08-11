module deltotum.math.geom.curves.curve_maker;
import deltotum.math.vector2d : Vector2d;

import Math = deltotum.math;

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
