module api.dm.kit.genart.hopalongs.hopalong;

import Math = api.math;

/**
 * Authors: initkfs
 */
class Hopalong
{

    double posX = 0.1;
    double posY = 0.2;

    double a = 0.5;
    double b = 1;
    double c = 0;

    size_t iterations = 10000;

    public double scale = 1;
    public double offsetX = 0;
    public double offsetY = 0;

    bool delegate(size_t, double, double) onIterXYIsContinue;
    void delegate() onPreIterate;
    void delegate() onPostIterate;

    void generate()
    {
        if (onPreIterate)
        {
            onPreIterate();
        }

        foreach (i; 0 .. iterations)
        {

            double tempX = posY - Math.sign(posX) * Math.sqrt(Math.abs(b * posX - c));
            double tempY = a - posX;

            auto pX = scale * (posX + offsetX);
            auto pY = scale * (posY + offsetY);

            posX = tempX;
            posY = tempY;

            if (!onIterXYIsContinue(i, pX, pY))
            {
                break;
            }
        }

        if (onPostIterate)
        {
            onPostIterate();
        }
    }
}
