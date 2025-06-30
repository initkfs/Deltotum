module api.dm.addon.procedural.noises.textures.fractal_cell;

import api.dm.addon.procedural.noises.textures.noise : Noise;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.math.random : Random;

import Math = api.dm.math;
import api.math.geom2.vec2 : Vec2d;
import std.conv : to;

import std;

/**
 * Authors: initkfs
 * Port from https://github.com/lorenSchmidt/fractal_cell_noise
 * Copyright (c) 2022 lorenSchmidt, under MIT license https://github.com/lorenSchmidt/fractal_cell_noise/blob/main/LICENSE
 */
class FractalCell : Noise
{
    size_t stack_octaves = 12;
    size_t seed = 40000;
    double[] noise_table = [];
    //256
    enum size_t ns = 10;
    enum size_t nt_size = ns * ns;
    enum size_t nt_sizem1 = nt_size - 1;

    size_t pc_increment = 101159;
    size_t pc_seed = 0;
    size_t noise_seed = 2304;

    Random rnd;

    this(double width = 100, double height = 100)
    {
        super(width, height);
        rnd = new Random;
    }

    override RGBA drawNoise(int x, int y)
    {
        auto w = cast(int) width;
        auto h = cast(int) height;
        auto value = cell_noise_xy(x, y, w, h, 6, 10, 6, 0.2, 2, 4);
        //ubyte ucolor = cast(ubyte)(ubyte.max * value);
        auto newColor = noiseColor;
        newColor.v = Math.clamp(value, HSVA.minValue, HSVA.maxValue);
        return newColor.toRGBA;
        //RGBA color = HSVA(198, 0.5, Math.clamp01(Math.abs(value))).toRGBA;
    }

    override void create()
    {
        init_random_table;
        super.create;
    }

    void init_random_table()
    {
        import std.array : appender;

        int[] list = [];
        auto listBuilder = appender(&list);
        for (auto a = 0; a < nt_size; a++)
        {
            listBuilder ~= a;
        }

        auto noiseAppender = appender(&noise_table);
        for (auto a = 0; a < nt_size; a++)
        {
            noiseAppender ~= draw_card(list);
        }
    }

    double prime_cycle()
    {
        auto result = noise_table[pc_seed % nt_size];
        pc_seed += pc_increment;
        return result;
    }

    int draw_card(ref int[] array)
    {
        size_t index = cast(size_t) Math.floor(rnd.between0to1 * array.length);
        int result = array[index];
        import std.algorithm.mutation : remove;

        array = array.remove(index);
        return result;
    }

    double cell_noise_xy(
        double x,
        double y,
        size_t xsize = 256,
        size_t ysize = 256,
        double density = 4,
        size_t seed = 0,
        size_t octaves = 2,
        double amplitude_ratio = 1 / 2,
        double softness = 1,
        double samples = 4,
        double bias = 0,
        double range = 1)
    {
        double surface = 0;
        for (auto a = 0; a < octaves; a++)
        {
            auto octave_seed = noise_table[seed % nt_size]; // inline prime cycle
            seed += pc_increment;
            auto layer = curve_stack_2x2_xy(x, y, xsize, ysize, density * 2 ^^ a, octave_seed, softness, samples, bias, range);

            surface += (amplitude_ratio ^^ a) * layer;
        }

        auto c_height = 0.5 * surface;
        return c_height;
    }

    double pos3int(double x, double y, size_t seed)
    {
        assert(noise_table.length > 0);
        size_t linear = cast(size_t)((x % ns) + (y % ns) * ns + seed);
        linear %= noise_table.length;
        return noise_table[linear];
    }

    double curve_stack_2x2_xy(
        double x,
        double y,
        size_t xsize = 256,
        size_t ysize = 256,
        double d = 1,
        double seed = 0,
        double softness = 1,
        double samples = 4,
        double bias = 0,
        double range = 1)
    {

        x /= xsize;
        y /= xsize;
        int ix = Math.floor(x * d).to!int;
        int iy = Math.floor(y * d).to!int;
        size_t ti = 0; // random number table index
        int dm1 = (d - 1).to!int; // for the bitwise & instead of % range trick

        double c_height = 0;

        // this variant uses a trick to reduce samples
        // sample radius is 1/2 square edge instead of 1, which makes overlap from neighboring cells never more than 1/2 square length. this means we can check which quadrant we're in and only check the three nearest neighbors, instead of all 8 neighbors.
        auto left = ix - 1 + (Math.floor(x * 2 * d).to!int & 1);
        auto top = iy - 1 + (Math.floor(y * 2 * d).to!int & 1);
        auto right = left + 1;
        auto bottom = top + 1;

        // this uses every point within the radius. when doing worley noise, we calculate distances for each point, and compare, getting various other parameters per point. instead, we can drop the distance comparisons, and instead get a height per point and run it through a lightweight kernel, and accumulate
        double px = 0, py = 0, distance_squared = 0, amp = 0;
        auto cx = left, cy = top;
        double sum = 0;
        while (cy <= bottom)
        {
            cx = left;
            while (cx <= right)
            {
                // this is a deterministic noise function with two integer inputs
                ti = pos3int((cx + d).to!int & dm1, (cy + d).to!int & dm1, noise_seed).to!size_t;
                // seed our rng with that value

                // this bounded curve runs from -1 to 1. i believe this means that we want to multiply the distance by d. however, this seems to leave seams? maybe i am wrong about the numbers.
                for (auto a = 0; a < samples; a++)
                {
                    px = cx / d + noise_table[(ti++) & nt_sizem1] / nt_size / d;
                    py = cy / d + noise_table[(ti++) & nt_sizem1] / nt_size / d;
                    distance_squared = d * d * ((x - px) ^^ 2 + (y - py) ^^ 2) * 4;

                    auto h = bias + -range + 2 * range * noise_table[(ti++) % nt_size] / nt_size;
                    // this is a bounded -1 to 1 variant of the witch of agnesi. this will prevent seams when points drop out of the set.
                    if (distance_squared < 1.0)
                    {
                        amp = (softness * (1 - distance_squared) / (softness + distance_squared));
                        amp = amp * amp;
                        // note that this worked ^ 2, but the derivative was not 0 at -1 and 1
                        sum += h * amp;
                    }
                }
                cx++;
            }
            cy++;
        }

        return sum;
    }

    double curve_stack_3x3_xy(double x, double y, double xsize = 256, double ysize = 256, double d = 1, double seed = 0, double softness = 1, double samples = 4, double bias = 0, double range = 1)
    {

        x /= xsize;
        y /= xsize;
        auto ix = Math.floor(x * d);
        auto iy = Math.floor(y * d);
        size_t ti = 0; // random number table index

        double c_height = 0;

        // this uses every point within the radius. when doing worley noise, we calculate distances for each point, and compare, getting various other parameters per point. instead, we can drop the distance comparisons, and instead get a height per point and run it through a lightweight kernel, and accumulate
        for (auto oy = -1; oy <= 1; oy++)
        {
            for (auto ox = -1; ox <= 1; ox++)
            {
                auto cx = ix + ox;
                auto cy = iy + oy;
                // this is a deterministic noise function with two integer inputs
                ti = pos3int((cx + d) % d, (cy + d) % d, noise_seed).to!size_t;
                // seed our rng with that value

                // auto count = 1 + prime_cycle() % (samples - 1)
                auto count = samples;
                // this bounded curve runs from -1 to 1. i believe this means that we want to multiply the distance by d. however, this seems to leave seams? maybe i am wrong about the numbers.
                for (auto a = 0; a < count; a++)
                {
                    auto px = cx / d + (noise_table[(ti++) % nt_size] / nt_size) / d;
                    auto py = cy / d + (noise_table[(ti++) % nt_size] / nt_size) / d;
                    auto distance = d * Math.sqrt((x - px) ^^ 2 + (y - py) ^^ 2);
                    auto height = bias + -range + 2 * range * noise_table[(ti++) % nt_size] / nt_size;
                    // this is a bounded -1 to 1 variant of the witch of agnesi. this will prevent seams when points drop out of the set.
                    if (distance < 1.0)
                    {
                        auto b = (softness * (1 - distance * distance)
                                / (softness + distance * distance));
                        b = b * b;
                        // note that this worked ^ 2, but the derivative was not 0 at -1 and 1
                        c_height += height * b;
                    }
                }
            }
        }

        return c_height;
    }

}
