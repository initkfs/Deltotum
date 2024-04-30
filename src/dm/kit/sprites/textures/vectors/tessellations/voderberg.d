module dm.kit.sprites.textures.vectors.tessellations.voderberg;

import dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.contexts.graphics_context : GraphicsContext;

import Math = dm.math;
import std : Tuple, tuple;
import dm.sys.cairo.libs;
import dm.math.random : Random;
import std.complex;

import std;

enum ShapeType
{
    triangle,
    voderberg,
    lightning,
    sigma,
    bentwedge,
    tent,
    random
}

/**
 * Authors: initkfs
 * Ported from Voderberg Deconstructed & Triangle Substitution Tiling, 2014. Cye H. Waldman, cye@att.net
 */
class Voderberg : VShape
{
    Random rnd;

    ShapeType shapeType;

    private
    {
        immutable size_t[7] mod360 = [12, 15, 18, 30, 36, 45, 60];
    }

    this(double width = 500, double height = 500)
    {
        super(width, height, GraphicStyle.simple);
        rnd = new Random;
        isDrawBounds = true;
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
            case lightning:
                params = 1.75 * rand;
                break;
            case sigma:
                params = 0.72 + (2.65 - 0.72) * rand;
                break;
            case bentwedge, tent:
                params = 1;
                break;
            case random:
                params = mod360[cast(size_t)(Math.floor(3 * rand))];
                break;
        }

        auto coronas = Math.floor(1 + 6 * rand);
        auto shift = -3.0 + Math.floor(6 * rand);

        voderberg(shapeType, params, coronas, shift);

    }

    double rand()
    {
        // return rnd.randomBetween0to1;
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
            default:
                break;
        }

        _gContext.setColor(RGBA.lightcyan);
        _gContext.translate(width / 2, height / 2);
        _gContext.moveTo(0, 0);

        for (auto c = 0; c < complexCoords[0].length; c++)
        {
            for (auto r = 0; r < complexCoords.length; r++)
            {
                auto complexValue = complexCoords[r][c];
                auto newX = complexValue.re * 15;
                auto newY = complexValue.im * 15;
                _gContext.lineTo(newX, newY);
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

    auto cumsum(T)(T[] arr)
    {
        T[] result = [];
        T sum = complex(0);

        for (auto i = 0; i < arr.length; i++)
        {
            sum += arr[i];
            result ~= sum;
        }

        return result;
    }

}
