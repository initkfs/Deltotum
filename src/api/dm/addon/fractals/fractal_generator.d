module api.dm.addon.fractals.fractal_generator;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.addon.fractals.lshape : LShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

private
{
    struct LSystemData
    {
        dstring startAxiom;
        dstring[dchar] rules;

        double step = 0;
        double angleDeg = 0;
        size_t generations;
    }
}

/**
 * Authors: initkfs
 */
class FractalGenerator : Sprite2d
{
    GraphicStyle style;

    protected LShape createShape(LSystemData data, bool isClosePath = false, bool isDrawFromCenter = true)
    {
        auto shape = new LShape(width, height, style, data.rules, isClosePath, isDrawFromCenter);
        shape.startAxiom = data.startAxiom;
        shape.angleDeg = data.angleDeg;
        shape.step = data.step;
        shape.generations = data.generations;
        return shape;
    }

    LShape heighwayDragon(double step = 2, size_t generations = 10, double angleDeg = 90)
    {
        dstring startAxiom = "FX";
        dstring[dchar] rule = ['X': "X+YF+", 'Y': "-FX-Y"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        return createShape(data);
    }

    LShape levyCurve(double step = 4, size_t generations = 7, double angleDeg = 45)
    {
        dstring startAxiom = "F";
        dstring[dchar] rule = ['F': "+F--F+"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        return createShape(data);
    }

    LShape minkowski(double step = 5, size_t generations = 5, double angleDeg = 90)
    {
        dstring startAxiom = "F";
        dstring[dchar] rule = ['F': "F-F+F+FF-F-F+F"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        return createShape(data);
    }

    LShape rings(double step = 5, size_t generations = 5, double angleDeg = 90)
    {
        dstring startAxiom = "F+F+F+F";
        dstring[dchar] rule = ['F': "FF+F+F+F+F+F-F"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        return createShape(data);
    }

    LShape kochSnowflake(double step = 3, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "F";
        dstring[dchar] rule = ['F': "F+F-F-F+F"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape kochIsland(double step = 2, size_t generations = 3, double angleDeg = 45)
    {
        dstring startAxiom = "X+X+X+X+X+X+X+X";
        dstring[dchar] rule = ['X': "X+YF++YF-FX--FXFX-YF+X", 'Y' : "-FX+YFYF++YF+FX--FX-YF"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape sierpińskiTriangle(double step = 10, size_t generations = 3, double angleDeg = 120)
    {
        dstring startAxiom = "F-G-G";
        dstring[dchar] rule = ['F': "F-G+F+G-F", 'G': "GG"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        return createShape(data);
    }

    LShape simplePlant(double step = 2, size_t generations = 4, double angleDeg = 25)
    {
        dstring startAxiom = "X";
        dstring[dchar] rule = ['X': "F-[[X]+X]+F[+FX]-X", 'F': "FF"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape plant2(double step = 2, size_t generations = 3, double angleDeg = 35)
    {
        dstring startAxiom = "F";
        dstring[dchar] rule = ['F': "F[+FF][-FF]F[-F][+F]F"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape plant3(double step = 4, size_t generations = 3, double angleDeg = 22.5)
    {
        dstring startAxiom = "F";
        dstring[dchar] rule = ['F': "FF+[+F-F-F]-[-F+F+F]"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape plantBushes(double step = 3, size_t generations = 4, double angleDeg = 25.7)
    {
        dstring startAxiom = "Y";
        dstring[dchar] rule = ['X': "X[-FFF][+FFF]FX", 'Y' : "YFX[+Y][-Y]"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape squareSierpinski(double step = 3, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "F+XF+F+XF";
        dstring[dchar] rule = ['X': "XF-F+F-XF+F+XF-F+F-X"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape triangle(double step = 4, size_t generations = 5, double angleDeg = 120)
    {
        dstring startAxiom = "F+F+F";
        dstring[dchar] rule = ['F': "F-F+F"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape quadraticGosper(double step = 5, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "-YF";
        dstring[dchar] rule = [
            'X': "XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-",
            'Y': "+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"
        ];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape peano(double step = 5, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "X";
        dstring[dchar] rule = [
            'X': "XFYFX+F+YFXFY-F-XFYFX",
            'Y': "YFXFY-F-XFYFX+F+YFXFY"
        ];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

     LShape hexagonalGosper(double step = 5, size_t generations = 3, double angleDeg = 60)
    {
        dstring startAxiom = "XF";
        dstring[dchar] rule = [
            'X': "X+YF++YF-FX--FXFX-YF+",
            'Y': "-FX+YFYF++YF+FX--FX-Y"
        ];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape crystal(double step = 5, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "F+F+F+F";
        dstring[dchar] rule = ['F': "FF+F++F+F"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape board(double step = 5, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "F+F+F+F";
        dstring[dchar] rule = ['F': "FF+F+F+F+FF"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape hilbert(double step = 5, size_t generations = 5, double angleDeg = 90)
    {
        dstring startAxiom = "X";
        dstring[dchar] rule = ['X': "-YF+XFX+FY-", 'Y': "+XF-YFY-FX+"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

    LShape tiles(double step = 5, size_t generations = 3, double angleDeg = 90)
    {
        dstring startAxiom = "F+F+F+F";
        dstring[dchar] rule = ['F': "FF+F-F+F+FF"];
        LSystemData data = {startAxiom, rule, step, angleDeg, generations};
        auto shape = createShape(data);
        return shape;
    }

}
