module api.dm.addon.sprites.textures.vectors.tessellations.voderberg;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;

import Math = api.dm.math;
import std : Tuple, tuple;
import api.dm.lib.cairo;
import api.math.random : Random;
import std.complex;

import std;

enum ShapeType
{
    triangle,
    voderberg,
    bentwedge,
    tent
}

/**
 * Authors: initkfs
 * Ported from Voderberg Deconstructed & Triangle Substitution Tiling, 2014. Cye H. Waldman, cye@att.net
 */
class Voderberg : VShape
{
    Random rnd;

    ShapeType shapeType;

    GraphicStyle delegate() styleSegmentProvider;
    double scaleX = 1.0;
    double scaleY = 1.0;

    private
    {
        immutable size_t[7] mod360 = [12, 15, 18, 30, 36, 45, 60];
    }

    this(double width = 100, double height = 100)
    {
        super(width, height, GraphicStyle.simple);
        rnd = new Random;
    }

    override void createTextureContent()
    {
        double params = 0;
        final switch (shapeType) with (ShapeType)
        {
            case triangle:
                params = mod360[cast(size_t)(Math.floor(mod360.length * rand))];
                break;
            case voderberg:
                params = 111.0 + (153 - 111) * rand;
                break;
            case bentwedge, tent:
                params = 1;
                break;
                // case random:
                //     params = mod360[cast(size_t)(Math.floor(3 * rand))];
                break;
        }

        auto coronas = Math.floor(1 + 6 * rand);
        auto shift = -3.0 + Math.floor(6 * rand);

        voderberg(shapeType, params, coronas, shift);
    }

    double rand()
    {
        // return rnd.between0to1;
        return 0.3;
    }

    void voderberg(ShapeType type, double param, double coronas, double shift)
    {
        import std : complex, cexp = exp, cabs = abs;
        import std.math.remainder : fmod;
        import std.math.operations : isClose;

        Complex!real[][] complexCoords;

        switch (type) with (ShapeType)
        {
            case triangle:
                immutable double alef = param * Math.PI / 180;
                immutable double x = 1;
                immutable double h = 1.0 / (2 * Math.sin(alef / 2));

                double[3] S = [x, h, h];
                double[3] phi = [
                    0, Math.PI / 2 + alef / 2, 3 * Math.PI / 2 - alef / 2
                ];
                auto phiComplexRange = phi[].map!expi;

                Complex!real[] z1 = zip(S[], phiComplexRange).map!"a[0] * a[1]".array;
                Complex!real[] z = [complex!real(0)] ~ cumsum(z1);
                Complex!real maxImagZ = complex(0, z.map!(v => v.im.abs).maxElement);

                Complex!real[] V = z.map!(v => conj(v) - 0.5 + maxImagZ).array;
                Complex!real[] A = z;

                immutable double sectors = 2 * Math.PI / alef;
                immutable double modSectors = fmod(sectors, 2);

                if (!isClose(modSectors, 0.0, 0.0, 1e-9))
                {
                    throw new Exception("Need an even integer number of sectors for spirals");
                }

                immutable int antisym = 1;
                complexCoords = radialSpiralTiling(V, A, sectors, coronas, shift, antisym);
                break;
            case voderberg:
                immutable double alef = 12 * Math.PI / 180;
                immutable double b = param;
                immutable double beth = b * Math.PI / 180;
                immutable double L = 2 * Math.sin((Math.PI - alef) / 2) / Math.cos(
                    beth - Math.PI / 2);
                immutable double x = (Math.csc(alef / 2) / 2 - L * Math.cos(Math.PI - beth)) / 2 - Math.sin(
                    alef / 2);
                double[] S = [1, x, L, x, 1, x, L, x, 1];
                double[] theta = [
                    alef, (3 * Math.PI - alef) / 2, (2 * Math.PI - beth), beth,
                    (Math.PI + alef) / 2, (Math.PI - 3 * alef) / 2,
                    (2 * Math.PI - beth), beth, (Math.PI + alef) / 2
                ];
                real[] phi = cumsum(theta.map!(v => Math.PI - v));

                auto phiComplexRange = phi[].map!expi;
                Complex!real[] z1 = cumsum(zip(S[], phiComplexRange).map!"a[0] * a[1]");
                z1 = [complex!real(0)] ~ z1;

                Complex!real maxImagZ = complex(0, z1.map!(v => v.im).maxElement);

                Complex!real[] z3 = z1.map!(v => -v + 0.5 + maxImagZ).array;
                Complex!real[] V = z1;
                Complex!real[] A = z3;
                auto sectors = 2 * Math.PI / alef;
                auto antisym = 1;
                complexCoords = radialSpiralTiling(V, A, sectors, coronas, shift, antisym);
                break;
            case bentwedge:
                immutable double alef = Math.PI / 12;
                double[] theta = [
                    7 * alef, 11 * alef, 11 * alef, 11 * alef, 1 * alef, 13 * alef,
                    13 * alef, 13 * alef, 4 * alef
                ];
                real[] phi = cumsum(theta.map!(v => Math.PI - v));
                auto phiComplexRange = phi[].map!expi;
                Complex!real[] z1 = cumsum(phiComplexRange).array;
                z1 = [complex!real(0)] ~ z1;
                auto z0 = z1[4];
                z1 = z1.map!(v => v - z0).array;
                auto V = z1.map!(v => conj(v)).array;

                Complex!real maxImagZ = complex(0, z1.map!(v => v.im.abs).maxElement);

                auto A = z1.map!(v => v + 0.5 + maxImagZ).array;
                double sectors = 24;
                int antisym = 0;
                complexCoords = radialSpiralTiling(V, A, sectors, coronas, shift, antisym);
                break;
            case tent:
                immutable double d = 14;
                immutable double alef = 2 * Math.PI / d;
                immutable double[] theta = [
                    7 * alef, 5 * alef, 5 * alef, 5 * alef, alef, 9 * alef,
                    9 * alef
                ];
                real[] phi = cumsum(theta.map!(v => Math.PI - v));
                auto phiComplexRange = phi[].map!expi;
                Complex!real[] z = cumsum(phiComplexRange).array;
                z = [complex!real(0)] ~ z;

                Complex!real maxImagZ = complex(0, z.map!(v => v.im.abs).maxElement);
                Complex!real[] V = z.map!(v => conj(v) - 0.5 + maxImagZ).array;
                Complex!real[] A = z;
                double sectors = 14;
                int antisym = 0;
                complexCoords = radialSpiralTiling(V, A, sectors, coronas, shift, antisym);
                break;
            default:
                break;
        }

        if (!styleSegmentProvider)
        {
            _gContext.color(style.lineColor);
        }

        _gContext.translate(width / 2, height / 2);

        if (shapeType == ShapeType.tent || shapeType == ShapeType.bentwedge)
        {
            assert(complexCoords.length > 0);
            assert(complexCoords[0].length > 0);
            auto complexValue = complexCoords[0][0];
            auto newX = complexValue.re * scaleX;
            auto newY = complexValue.im * scaleY;
            canvas.moveTo(newX, newY);
        }
        else
        {
            _gContext.moveTo(0, 0);
        }

        for (auto c = 0; c < complexCoords[0].length; c++)
        {
            for (auto r = 0; r < complexCoords.length; r++)
            {
                auto complexValue = complexCoords[r][c];
                auto newX = complexValue.re * scaleX;
                auto newY = complexValue.im * scaleY;
                _gContext.lineTo(newX, newY);

                if (!styleSegmentProvider)
                {
                    if (style.isFill)
                    {
                        _gContext.color(style.fillColor);
                        _gContext.fillPreserve;
                        _gContext.color(style.lineColor);
                    }
                }
                else
                {
                    auto style = styleSegmentProvider();
                    _gContext.color(style.fillColor);
                    _gContext.fillPreserve;
                    _gContext.color(style.lineColor);
                }

            }
            _gContext.stroke;
        }
    }

    Complex!real[][] radialSpiralTiling(Complex!real[] V, Complex!real[] A, double sectors, double coronas, double shift, int antisym)
    {
        auto alef = 2 * Math.PI / sectors;
        auto fin = V;
        auto duo = zip(V, A).map!"[a[0],a[1]]".array;
        auto dely = 1.0 / (2 * Math.tan(alef / 2));
        Complex!real[][] z = V.chunks(1).array;

        foreach (r; 1 .. coronas + 1)
        {
            Complex!real[][] row = [];
            foreach (k; 1 .. r + 1)
            {
                Complex!real[][] drow;
                foreach (d; duo)
                {
                    drow ~= d.map!(v => v - r / 2.0 + k - 1.0 + complex(0, r * dely)).array;
                }

                if (row.length > 0)
                {
                    row = zip(row, drow).map!"a[0] ~ a[1]".array;
                }
                else
                {
                    row = drow;
                }
            }

            auto last = fin.map!(v => v + r / 2.0 + complex(0, r * dely)).array;
            auto next = zip(row, last).map!"a[0] ~ a[1]".array;
            // // if (~antisym && (r % 2) == 1)
            // // {
            // //     next = next.map!(v => -conj(v)).array;
            // // }
            z = zip(z, next).map!"a[0] ~ a[1]".array;
        }

        foreach (ref row; z)
        {
            foreach (ref v; row)
            {
                v = v * expi(Math.PI / 2) * expi(-Math.PI / sectors);
            }
        }

        Complex!real[][] result = z;

        foreach (k; 1 .. sectors)
        {
            Complex!real[][] zExp;
            foreach (zRow; z)
            {
                zExp ~= zRow.map!(v => v * expi(-k * alef)).array;
            }
            result = zip(result, zExp).map!"a[0] ~ a[1]".array;
        }

        return result;
    }

    auto cumsum(Range)(Range range) if (isInputRange!Range)
    {
        alias RangeType = Unqual!(ElementType!Range);

        static if (__traits(isFloating, RangeType))
            RangeType sum = 0;
        else static if (__traits(isSame, TemplateOf!RangeType, Complex))
            RangeType sum = complex(0);
        else
            RangeType sum = RangeType.init;

        RangeType[] result = [];

        import std.array : appender;

        auto app = appender(&result);

        foreach (v; range)
        {
            static if (__traits(isFloating, typeof(sum)))
            {
                import std.math.traits : isFinite;

                if (!isFinite(v))
                {
                    continue;
                }
            }
            sum += v;
            app ~= sum;
        }

        return result;
    }

    void scale(double x, double y)
    {
        scaleX = x;
        scaleY = y;
    }
}
