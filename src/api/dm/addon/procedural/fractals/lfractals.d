module api.dm.addon.procedural.fractals.lfractals;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.addon.procedural.lsystems.lsystem : LSystemData;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
LSystemData heighwayDragon(double step = 2, size_t generations = 10, double angleDeg = 90)
{
    dstring startAxiom = "FX";
    dstring[dchar] rule = ['X': "X+YF+", 'Y': "-FX-Y"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData levyCurve(double step = 4, size_t generations = 7, double angleDeg = 45)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "+F--F+"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData minkowski(double step = 5, size_t generations = 5, double angleDeg = 90)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "F-F+F+FF-F-F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData rings(double step = 5, size_t generations = 5, double angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F+F+F+F+F-F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData kochSnowflake(double step = 3, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "F+F-F-F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData kochIsland(double step = 2, size_t generations = 3, double angleDeg = 45)
{
    dstring startAxiom = "X+X+X+X+X+X+X+X";
    dstring[dchar] rule = [
        'X': "X+YF++YF-FX--FXFX-YF+X", 'Y': "-FX+YFYF++YF+FX--FX-YF"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData sierpińskiTriangle(double step = 10, size_t generations = 3, double angleDeg = 120)
{
    dstring startAxiom = "F-G-G";
    dstring[dchar] rule = ['F': "F-G+F+G-F", 'G': "GG"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData simplePlant(double step = 2, size_t generations = 4, double angleDeg = 25)
{
    dstring startAxiom = "X";
    dstring[dchar] rule = ['X': "F-[[X]+X]+F[+FX]-X", 'F': "FF"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData plant2(double step = 2, size_t generations = 3, double angleDeg = 35)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "F[+FF][-FF]F[-F][+F]F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData plant3(double step = 4, size_t generations = 3, double angleDeg = 22.5)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "FF+[+F-F-F]-[-F+F+F]"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData plantBushes(double step = 3, size_t generations = 4, double angleDeg = 25.7)
{
    dstring startAxiom = "Y";
    dstring[dchar] rule = ['X': "X[-FFF][+FFF]FX", 'Y': "YFX[+Y][-Y]"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData squareSierpinski(double step = 3, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "F+XF+F+XF";
    dstring[dchar] rule = ['X': "XF-F+F-XF+F+XF-F+F-X"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData triangle(double step = 4, size_t generations = 5, double angleDeg = 120)
{
    dstring startAxiom = "F+F+F";
    dstring[dchar] rule = ['F': "F-F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData quadraticGosper(double step = 5, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "-YF";
    dstring[dchar] rule = [
        'X': "XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-",
        'Y': "+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData peano(double step = 5, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "X";
    dstring[dchar] rule = [
        'X': "XFYFX+F+YFXFY-F-XFYFX",
        'Y': "YFXFY-F-XFYFX+F+YFXFY"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData hexagonalGosper(double step = 5, size_t generations = 3, double angleDeg = 60)
{
    dstring startAxiom = "XF";
    dstring[dchar] rule = [
        'X': "X+YF++YF-FX--FXFX-YF+",
        'Y': "-FX+YFYF++YF+FX--FX-Y"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData crystal(double step = 5, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F++F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData board(double step = 5, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F+F+F+FF"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData hilbert(double step = 5, size_t generations = 5, double angleDeg = 90)
{
    dstring startAxiom = "X";
    dstring[dchar] rule = ['X': "-YF+XFX+FY-", 'Y': "+XF-YFY-FX+"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData tiles(double step = 5, size_t generations = 3, double angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F-F+F+FF"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}
