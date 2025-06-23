module api.dm.addon.sprites.textures.vectors.tessellations.penrose_tiling;

import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;

import Math = api.dm.math;
import std : Tuple, tuple;
import api.dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class PenroseTiling : VShape
{
    /**
    * The algorithm has been ported from https://habr.com/ru/articles/359244/, by Юрий (@yurixi)
    * TODO Improved refactoring
    */
    this(double width = 100, double height = 100)
    {
        super(width, height, GraphicStyle.simple);
    }

    private enum double sqrt5Value = Math.sqrt(5.0);
    enum double fi = (sqrt5Value - 1) / 2;
    enum double fb = (sqrt5Value + 1) / 2;
    enum double f3 = Math.sqrt(3 + fi);
    enum double f2 = Math.sqrt(2 - fi);

    immutable double[][] baseVectorsCoords = [
        [2, 0, 0, 0], [1, 1, 0, 1], [0, 1, 1, 0], [0, -1, 1, 0],
        [-1, -1, 0, 1], [-2, 0, 0, 0], [-1, -1, 0, -1], [0, -1, -1, 0],
        [0, 1, -1, 0],
        [1, 1, 0, -1]
    ];
    immutable double[] constants = [1.0 / 2, fi / 2, f3 / 2, f2 / 2];

    RGBA[6] colors = [
        RGBA.web("#f1c40f"), RGBA.web("#f39c12"), RGBA.web("#95a5a6"),
        RGBA.web("#7f8c8d"), RGBA.web("#ecf0f1"),
        RGBA.web("#bdc3c7")
    ];
    RGBA lineColor = RGBA.red;

    double centerX = 0;
    double centerY = 0;

    size_t mode = 2;
    size_t levels = 4;
    double levelPower = 0.1 * 10;
    double lineWidth = 8 * 6 * fi * fi;

    override void createTextureContent()
    {
        centerX = width / 2;
        centerY = height / 2;

        Tuple!(double, double[], double)[] tf;
        tf ~= tuple(0.0, [0.0, 0, 0, 0], 0.0);
        tf ~= tuple(1.0, [0.0, 0, 0, 0], 0.0);
        tf ~= tuple(2.0, [0.0, 0, 0, 0], 3.0);
        tf ~= tuple(3.0, [0.0, 0, 0, 0], 3.0);
        tf ~= tuple(2.0, [0.0, 0, 0, 0], 7.0);
        tf ~= tuple(3.0, [0.0, 0, 0, 0], 7.0);
        Tuple!(double, double[], double)[][] f = [tf];

        auto cr = cairoContext.getObject;
        cairo_set_source_rgb(cr, style.fillColor.rNorm, style
                .fillColor.gNorm, style
                .fillColor.bNorm);

        // plane partition
        size_t n = 0, m = 0;
        for (; n < levels; n++)
        {
            m = n + 1;
            //f[m] = [];
            f ~= [tuple(0.0, [0.0, 0.0, 0.0, 0.0], 0.0)];
            for (auto k = 0; k < f[n].length; k++)
            {
                f[m] = zd(f[n][k], f[m]);
            }

        }

        // drawing
        n = m - 1; // previous level
        if (levelPower != 1)
            for (auto i = 0; i < f[n].length; i++)
            {
                paint(f[n][i], mode, 1);
            }

        // last level
        for (auto i = 0; i < f[m].length; i++)
        {
            paint(f[m][i], mode, 0);
        }

        // For mode 11, lines are emphasized
        if (mode == 11)
        {
            size_t d = 3;
            for (auto i = 0; i < f[m - d].length; i++)
            {
                paint(f[m - d][i], mode, d);
            }
        }
    }

    Tuple!(double, double[], double)[] zd(Tuple!(double, double[], double) a, Tuple!(double, double[], double)[] f)
    {
        size_t t = cast(size_t) a[0]; // shape type

        if (t > 3)
            t = t - 4; // shape types 4 and 5 are treated as 0 and 1

        //direction of the first step depending on the type of figure, in the form of a direction shift
        immutable double[] sht = [1, -1, 2, -2];
        double shift = sht[t];

        double t1 = 0, t2 = 0, t3 = 0;

        if (t == 0)
        {
            t1 = 0;
            t2 = 3;
            t3 = 5;
        } //types of resulting figures
        else if (t == 1)
        {
            t1 = 1;
            t2 = 2;
            t3 = 4;
        }
        else if (t == 2)
        {
            t1 = 4;
            t2 = 2;
        }
        else if (t == 3)
        {
            t1 = 5;
            t2 = 3;
        }

        if (t < 2)
        {
            auto pos = a[1];
            auto v1 = a[2]; // general direction
            auto v2 = (v1 + shift + 10) % 10; // first step direction
            auto v3 = (v1 - shift + 10) % 10; // second step direction
            auto v4 = (v2 + 5) % 10; // reverse direction to first
            auto v5 = (v1 + 5) % 10; // the opposite direction to the general one (not the second one)

            auto p1 = add(pos, baseVectorsCoords[cast(ulong) v2]); // position after first step
            auto p2 = add(p1, baseVectorsCoords[cast(ulong) v3]); //position after second step
            auto p3 = mul(p1, [2, 2, 0, 0]); // scaling
            auto p4 = mul(p2, [2, 2, 0, 0]); // scaling

            f ~= tuple(t1, p3, v4);
            f ~= tuple(t2, p3, v3);
            f ~= tuple(t3, p4, v5);
        }
        else
        {
            auto pos = a[1];
            auto v1 = a[2];
            auto v2 = (v1 + shift + 10) % 10;
            auto v3 = (v1 - shift + 10) % 10;
            auto v4 = (v2 + 5) % 10;
            auto v5 = (v3 + 5) % 10;

            auto p1 = add(pos, baseVectorsCoords[cast(ulong) v2]);
            auto p2 = add(p1, baseVectorsCoords[cast(ulong) v3]);
            auto p3 = mul(p1, [2, 2, 0, 0]);
            auto p4 = mul(p2, [2, 2, 0, 0]);

            f ~= tuple(t1, p3, v4);
            f ~= tuple(t2, p4, v5);
        }

        return f;
    }

    int[][][] mt = [
        [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
        [[0, 1, 0, 0], [1, -1, 0, 0], [0, 0, 0, 1], [0, 0, 1, -1]],
        [[0, 0, 1, 0], [0, 0, 0, 1], [-3, 1, 0, 0], [-1, -2, 0, 0]],
        [[0, 0, 0, 1], [0, 0, 1, -1], [-1, -2, 0, 0], [-2, 1, 0, 0]]
    ];

    double[] mul(const double[] v1, const double[] v2) pure
    {
        auto v3 = [0.0, 0, 0, 0];
        for (auto i = 0; i < 4; i++)
            for (auto j = 0; j < 4; j++)
                for (auto k = 0; k < 4; k++)
                    v3[k] = v3[k] + v1[i] * v2[j] * mt[i][j][k];

        for (auto i = 0; i < 4; i++)
            v3[i] = v3[i] / 2;

        return v3;
    }

    double[] add(const double[] v1, const double[] v2)
    {
        auto v3 = [0.0, 0, 0, 0];
        for (auto i = 0; i < 4; i++)
            v3[i] = v3[i] + v1[i];
        for (auto i = 0; i < 4; i++)
            v3[i] = v3[i] + v2[i];
        return v3;
    }

    double[] mean(double[] p1, double[] p2, double d)
    {
        auto p3 = [(p2[0] - p1[0]) * d + p1[0], (p2[1] - p1[1]) * d + p1[1]];
        return p3;
    }

    void paint(Tuple!(double, double[], double) a, double mode, double level = 0)
    {
        auto pr = levelPower;
        auto st = lineWidth;

        auto type = cast(size_t) a[0];
        size_t tn = type; // type rolled up to 4
        if (tn > 3)
        {
            tn = tn - 4;
        }

        RGBA color = colors[type];

        // direction of the first step, in the form of a direction shift
        auto sht = [1.0, -1, 2, -2];
        auto shift = sht[tn];

        auto p = a[1]; // anchor point

        auto v0 = a[2]; // direction
        v0 = (10 + v0 % 10) % 10; // direction is aligned within 0-10
        auto v1 = (10 + (v0 + shift) % 10) % 10; // first step direction
        auto v2 = (10 + (v0 - shift) % 10) % 10; // second step direction

        //scaling factors for position and for sides.
        auto kop = 0.0;
        auto koe = 0.0;
        auto pr1 = 1 - pr; // strength of the previous level.
        if (level == 0)
        {
            kop = st;
            koe = pr;
        }
        if (level == 1)
        {
            kop = st / fi;
            koe = pr1 / fi;
        } // bleed through of adjacent level

        if (level == 3)
        {
            kop = st / fi / fi / fi;
            koe = pr / fi / fi / fi;
        } // lines are three levels less

        st = st * koe; // shapes scaling

        // coordinates of the beginning of the line
        auto p0 = [
            kop * (p[0] * constants[0] + p[1] * constants[1]),
            kop * (p[2] * constants[2] + p[3] * constants[3])
        ];
        // coordinates of the end of the first line
        auto s1 = baseVectorsCoords[cast(ulong) v1];
        auto p1 = [
            p0[0] + st * (s1[0] * constants[0] + s1[1] * constants[1]),
            p0[1] + st * (s1[2] * constants[2] + s1[3] * constants[3])
        ];
        //coordinates of the end of the second line
        auto s2 = baseVectorsCoords[cast(ulong) v2];
        auto p2 = [
            p1[0] + st * (s2[0] * constants[0] + s2[1] * constants[1]),
            p1[1] + st * (s2[2] * constants[2] + s2[3] * constants[3])
        ];

        //whether to draw the table or the background
        auto modes = [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1];
        auto y = modes[cast(ulong) mode];

        // filling, you can immediately draw edges
        if (level < 3) // if shifted by three levels, then the background is not drawn, only the lines of mode 11.
            if (y || mode == 0)
            {
                begin();
                from(p0);
                to(p1);
                to(p2);
                close();
                if (y)
                {
                    fill(color);
                }
                if (mode == 0)
                    line();
                if (mode == 12)
                    line_white();
            }

        // quadrilaterals
        if (mode == 1)
        {
            auto p3 = mean(p0, p2, 0.5);
            begin();
            from(p0);
            to(p2);
            from(p1);
            to(p3);
            line_black();
        }

        // far side, HBS figures
        if (mode == 2)
        {
            begin();
            from(p1);
            to(p2);
            line();
        }

        if (mode == 6) // rhombus
        {
            begin();
            if (tn == 0 || tn == 2)
            {
                color = colors[cast(ulong)(tn * 2)];
                // fourth corner of a rhombus
                auto p3 = mean(p0, p2, 0.5);
                auto p4 = mean(p1, p3, 2);
                from(p0);
                to(p1);
                to(p2);
                to(p4);
                close();
                fill(color);
            }
            line();
        }

        if (mode == 7) // deltoids
        {
            if (type == 0)
            { // calculation of additional corner angle
                auto p3 = mean(p0, p1, 1 + fi);
                auto p4 = mean(p2, p3, 1 + fi);
                begin();
                from(p0);
                to(p1);
                to(p4);
                to(p2);
                close();
                fill(colors[0]);
                line();
            }
            if (type == 2)
            { // calculating the angles of a kite figure
                auto p3 = mean(p0, p2, 2 + fi);
                auto p4 = [p0[0] + (p2[0] - p1[0]), p0[1] + (p2[1] - p1[1])];
                begin();
                from(p0);
                to(p1);
                to(p3);
                to(p4);
                close();
                fill(colors[4]);
                line();
            }
        }

        if (mode == 8) // different triangles
        {
            if (type < 2)
            {
                begin();
                from(p0);
                to(p1);
                to(p2);
                close();
                fill(colors[0]);
                line();
            }
            if (type == 4 || type == 5)
            {
                auto p3 = mean(p0, p1, 1 + fi);
                begin();
                from(p0);
                to(p3);
                to(p2);
                close();
                fill(colors[4]);
                line();
            }
        }

        if (mode == 9) // diamond and corners
        {
            if (type == 0)
            {
                auto p3 = mean(p0, p1, 1 + fi);
                auto p4 = mean(p2, p3, 1 + fi);
                begin();
                from(p0);
                to(p1);
                to(p4);
                to(p2);
                close();
                fill(colors[0]);
                line();
            }
            if (type == 2)
            {
                auto p3 = [p0[0] - p1[0] + p2[0], p0[1] - p1[1] + p2[1]];
                begin();
                from(p0);
                to(p1);
                to(p2);
                to(p3);
                close();
                fill(colors[4]);
                line();
            }

            if (type == 4)
            {
                auto p3 = mean(p2, p1, 1 + fi);
                auto p4 = mean(p0, p3, 1 + fi);
                begin();
                from(p0);
                to(p4);
                to(p1);
                to(p2);
                close();
                fill(colors[0]);
                line();
            }
        }

        if (mode == 10)
        {
            auto p4 = mean(p1, p0, fi);
            auto p5 = mean(p0, p2, fi);
            auto p6 = mean(p2, p0, 1 / 2 + fi / 2);
            auto p7 = mean(p1, p2, 0.5);
            begin();
            if (tn < 2)
            {
                from(p4);
                to(p5);
            }
            else
            {
                from(p6);
                to(p4);
            }
            to(p7);
            line();
        }

        if (mode == 11)
        {
            auto k1 = 1 / 2;
            auto k2 = (fi + 1) / 2;
            auto k3 = (4 - fi) / 4;
            auto k4 = (fi + 1) / 4;
            auto k5 = (3 - 2 * fi) / 2;
            auto k6 = 1 / 4;
            if (tn < 2)
            {
                auto p3 = mean(p0, p2, k4);
                auto p4 = mean(p0, p1, k2);
                auto p5 = mean(p1, p2, k1);
                auto p6 = mean(p0, p2, k5);
                auto p7 = mean(p1, p2, k3);
                begin();
                from(p3);
                to(p4);
                to(p5);
                to(p6);
                to(p7);
            }
            else
            {
                auto p3 = mean(p2, p1, k3);
                auto p4 = mean(p0, p1, k2);
                auto p5 = mean(p1, p2, k1);
                auto p6 = mean(p2, p0, k6);
                begin();
                from(p3);
                to(p4);
                to(p5);
                to(p6);
            }

            line();
        }
    }

    void begin()
    {
        _gContext.beginPath();
    }

    void from(double[] p)
    {
        _gContext.moveTo(centerX - p[0], centerY - p[1]);
    }

    void to(double[] p)
    {
        _gContext.lineTo(centerX - p[0], centerY - p[1]);
    }

    void close()
    {
        _gContext.closePath();
    }

    void fill(RGBA color)
    {
        _gContext.color(color);
        _gContext.fill();
    }

    void line()
    {
        _gContext.color(RGBA.red);
        _gContext.lineWidth(2);
        _gContext.stroke();
    }

    void line_white()
    {
        _gContext.color(RGBA.white);
        _gContext.lineWidth(2);
        _gContext.stroke();
    }

    void line_black()
    {
        _gContext.color(RGBA.black);
        _gContext.lineWidth(2);
        _gContext.stroke();
    }
}
