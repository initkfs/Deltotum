module api.dm.addon.procedural.fractals.lfractals;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.addon.procedural.lsystems.lsystem : LSystemData;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
LSystemData heighwayDragon(float step = 2, size_t generations = 10, float angleDeg = 90)
{
    dstring startAxiom = "FX";
    dstring[dchar] rule = ['X': "X+YF+", 'Y': "-FX-Y"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData levyCurve(float step = 4, size_t generations = 7, float angleDeg = 45)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "+F--F+"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData minkowski(float step = 5, size_t generations = 5, float angleDeg = 90)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "F-F+F+FF-F-F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData rings(float step = 5, size_t generations = 5, float angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F+F+F+F+F-F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData kochSnowflake(float step = 3, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "F+F-F-F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData kochIsland(float step = 2, size_t generations = 3, float angleDeg = 45)
{
    dstring startAxiom = "X+X+X+X+X+X+X+X";
    dstring[dchar] rule = [
        'X': "X+YF++YF-FX--FXFX-YF+X", 'Y': "-FX+YFYF++YF+FX--FX-YF"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData sierpińskiTriangle(float step = 10, size_t generations = 3, float angleDeg = 120)
{
    dstring startAxiom = "F-G-G";
    dstring[dchar] rule = ['F': "F-G+F+G-F", 'G': "GG"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData simplePlant(float step = 2, size_t generations = 4, float angleDeg = 25)
{
    dstring startAxiom = "X";
    dstring[dchar] rule = ['X': "F-[[X]+X]+F[+FX]-X", 'F': "FF"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData plant2(float step = 2, size_t generations = 3, float angleDeg = 35)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "F[+FF][-FF]F[-F][+F]F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData plant3(float step = 4, size_t generations = 3, float angleDeg = 22.5)
{
    dstring startAxiom = "F";
    dstring[dchar] rule = ['F': "FF+[+F-F-F]-[-F+F+F]"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData plantBushes(float step = 3, size_t generations = 4, float angleDeg = 25.7)
{
    dstring startAxiom = "Y";
    dstring[dchar] rule = ['X': "X[-FFF][+FFF]FX", 'Y': "YFX[+Y][-Y]"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData squareSierpinski(float step = 3, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "F+XF+F+XF";
    dstring[dchar] rule = ['X': "XF-F+F-XF+F+XF-F+F-X"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData triangle(float step = 4, size_t generations = 5, float angleDeg = 120)
{
    dstring startAxiom = "F+F+F";
    dstring[dchar] rule = ['F': "F-F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData quadraticGosper(float step = 5, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "-YF";
    dstring[dchar] rule = [
        'X': "XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-",
        'Y': "+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData peano(float step = 5, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "X";
    dstring[dchar] rule = [
        'X': "XFYFX+F+YFXFY-F-XFYFX",
        'Y': "YFXFY-F-XFYFX+F+YFXFY"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData hexagonalGosper(float step = 5, size_t generations = 3, float angleDeg = 60)
{
    dstring startAxiom = "XF";
    dstring[dchar] rule = [
        'X': "X+YF++YF-FX--FXFX-YF+",
        'Y': "-FX+YFYF++YF+FX--FX-Y"
    ];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData crystal(float step = 5, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F++F+F"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData board(float step = 5, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F+F+F+FF"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData hilbert(float step = 5, size_t generations = 5, float angleDeg = 90)
{
    dstring startAxiom = "X";
    dstring[dchar] rule = ['X': "-YF+XFX+FY-", 'Y': "+XF-YFY-FX+"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}

LSystemData tiles(float step = 5, size_t generations = 3, float angleDeg = 90)
{
    dstring startAxiom = "F+F+F+F";
    dstring[dchar] rule = ['F': "FF+F-F+F+FF"];
    return LSystemData(startAxiom, rule, step, angleDeg, generations);
}
