module api.dm.addon.procedural.fractals.hopalongs.hopalong;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;

enum HopalongType
{
    martinPositiveSign,
    martinNegativeSign,
    martinAdditive,
    sinusoidal,
    gingerbread,
    attractorHenon,
    attractorDuffing,
    attractorTinkerbell,
    attractorDeJong,
    attractorGhost,
    attractorTartan,
}

/**
 * Authors: initkfs
 * See J.O.Linton, Hopalong Fractals
 */
class Hopalong
{

    double posX = 0;
    double posY = 0;

    double a = 0.5;
    double b = 1;
    double c = 0;
    double d = 0;

    size_t iterations = 10000;

    public double scale = 1;
    public double offsetX = 0;
    public double offsetY = 0;

    bool delegate(size_t, double, double) onIterXYIsContinue;
    void delegate() onPreIterate;
    void delegate() onPostIterate;

    HopalongType type = HopalongType.martinNegativeSign;

    void generate()
    {
        if (onPreIterate)
        {
            onPreIterate();
        }

        foreach (i; 0 .. iterations)
        {
            auto res = calc;

            auto pX = scale * (posX + offsetX);
            auto pY = scale * (posY + offsetY);

            posX = res.x;
            posY = res.y;

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

    void reset(){
        posX = 0;
        posY = 0;
    }

    Vec2d calc()
    {
        double newX, newY;

        final switch (type) with (HopalongType)
        {
            case martinNegativeSign:
                newX = posY - Math.sign(posX) * Math.sqrt(Math.abs(b * posX - c));
                newY = a - posX;
                break;
            case martinPositiveSign:
                newX = posY + Math.sign(posX) * Math.sqrt(Math.abs(b * posX - c));
                newY = a - posX;
                break;
            case martinAdditive:
                newX = posY + Math.sqrt(Math.abs(b * posX - c));
                newY = a - posX;
                break;
            case sinusoidal:
                newX = posY + Math.sin(b * posX - c);
                newY = a - posX;
                break;
            case gingerbread:
                newX = posY + Math.abs(b * posX);
                newY = a - posX;
                break;
            case attractorHenon:
                newX = 1 + b * posY + c * (posX ^^ 2);
                newY = a * posX;
                break;
            case attractorDuffing:
                newX = a * posX - b * posY - (posX ^^ 3);
                newY = posX;
                break;
            case attractorDeJong:
                newX = Math.sin(a * posY) - Math.cos(b * posX);
                newY = Math.sin(c * posX) - Math.cos(d * posY);
                break;
            case attractorTinkerbell:
                newX = ((posX ^^ 2) - (posY ^^ 2)) + a * posX + b * posY;
                newY = (2 * posX * posY) + c * posX + d * posY;
                break;
            case attractorTartan:
                newX = a * posY - b;
                newY = c - (posX ^^ 2);
                break;
            case attractorGhost:
                newX = Math.sin(a * posY) - b * posX;
                newY = c * posX - Math.cos(d * posY);
                break;
        }

        return Vec2d(newX, newY);
    }
}
