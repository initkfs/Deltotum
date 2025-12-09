module api.dm.kit.graphics.colors.processings.processing;

import api.dm.kit.graphics.colors.processings.convolutions;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.rect2 : Rect2d;
import Math = api.dm.math;

/**
 * Authors: initkfs
 */
RGBA grayscale(RGBA color, float threshold = -1)
{
    import std.conv : to;

    const coeffLinear = color.rNorm * 0.2126 + color.gNorm * 0.7152 + color.bNorm * 0.0722;
    float coeffSrgb = 0;
    if (coeffLinear <= 0.0031308)
    {
        coeffSrgb = 12.92 * coeffLinear;
    }
    else
    {
        import Math = api.dm.math;

        coeffSrgb = 1.055 * (coeffLinear ^^ (1.0 / 2.4)) - 0.055;
    }

    ubyte colorValue = (coeffSrgb * RGBA.maxColor).to!ubyte;
    if (threshold > 0)
    {
        colorValue = colorValue > threshold ? RGBA.maxColor : RGBA.minColor;
    }

    RGBA newColor = RGBA(colorValue, colorValue, colorValue, color.a);
    return newColor;
}

RGBA negative(RGBA color)
{
    import std.conv : to;

    ubyte maxColor = RGBA.maxColor;
    ubyte newR = (maxColor - color.r).to!ubyte;
    ubyte newG = (maxColor - color.g).to!ubyte;
    ubyte newB = (maxColor - color.b).to!ubyte;

    RGBA newColor = RGBA(newR, newG, newB, color.a);
    return newColor;
}

RGBA solarization(RGBA color, float threshold = 10)
{
    import Math = api.dm.math;

    import std.conv : to;

    const checkTreshold = (ubyte colorValue) {
        return colorValue < threshold ? (RGBA.maxColor - colorValue)
            .to!ubyte : colorValue;
    };

    const newR = checkTreshold(color.r);
    const newG = checkTreshold(color.g);
    const newB = checkTreshold(color.b);

    RGBA newColor = RGBA(newR, newG, newB, color.a);
    return newColor;
}

RGBA sepia(RGBA color)
{
    import Math = api.dm.math;
    import std.conv : to;

    const maxColorValue = RGBA.maxColor;

    const newR = 0.393 * color.r + 0.769 * color.g + 0.189 * color.b;
    const newG = 0.349 * color.r + 0.686 * color.g + 0.168 * color.b;
    const newB = 0.272 * color.r + 0.534 * color.g + 0.131 * color.b;

    const r = Math.min(newR, maxColorValue).to!ubyte;
    const g = Math.min(newG, maxColorValue).to!ubyte;
    const b = Math.min(newB, maxColorValue).to!ubyte;

    RGBA newColor = RGBA(r, g, b, color.a);
    return newColor;
}

RGBA posterize(RGBA color, RGBA[] palette, float minDistance = 10)
{
    foreach (ref RGBA paletterColor; palette)
    {
        float distance = color.distance(paletterColor);
        if (distance <= minDistance)
        {
            return paletterColor;
        }
    }

    return color;
}

RGBA[][] highpass(RGBA[][] colors, float offset = 0)
{
    const div = 4.0;
    return convolution(colors, [
            [0, -1 / div, 0],
            [-1 / div, +2, -1 / div],
            [0, -1 / div, 0]
        ], offset);
}

RGBA[][] lowpass(RGBA[][] colors, float offset = 0)
{
    const div = 8.0;
    return convolution(colors, [
            [0, 1 / div, 0],
            [1 / div, 1 / (div / 2), 1 / div],
            [0, 1 / div, 0]
        ], offset);
}

RGBA[][] sobel(RGBA[][] colors, float offset = 0)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);

    float[][] sobelX = [
        [1, 2, 1],
        [0, 0, 0],
        [-1, -2, -1]
    ];

    float[][] sobelY = [
        [1, 0, -1],
        [2, 0, -2],
        [1, 0, -1]
    ];

    RGBA[][] bufferX = convolution(colors, sobelX);
    RGBA[][] bufferY = convolution(colors, sobelY);

    import Math = api.dm.math;

    foreach (y, row; buffer)
    {
        foreach (x, ref RGBA color; row)
        {
            const sobelX1 = bufferX[y][x];
            const sobelY1 = bufferY[y][x];
            const brX = sobelX1.brightness;
            const brY = sobelY1.brightness;
            const greyVal = cast(ubyte)(Math.sqrt((brX * brX) + (brY * brY)));
            color.r = greyVal;
            color.g = greyVal;
            color.b = greyVal;
        }
    }

    return buffer;

}

RGBA[][] laplacian(RGBA[][] colors, float offset = 0)
{
    return convolution(colors, [
            [0.0, -1, 0],
            [-1.0, 4, -1],
            [0.0, -1, 0]
        ], offset);
}

RGBA[][] emboss(RGBA[][] colors, float offset = 0)
{
    return convolution(colors, [
            [-2.0, -1, 0],
            [-1.0, 1, 1],
            [0.0, 1, 2]
        ], offset);
}

RGBA[][] boxblur(RGBA[][] colors, size_t size = 10, float divider = 9.0)
{
    //TODO remove allocations
    const float value = 1 / divider;
    float[][] matrix = new float[][](size, size);
    foreach (ref row; matrix)
    {
        row[] = value;
    }
    return convolution(colors, matrix);
}

RGBA[][] gaussian3x3(RGBA[][] colors, float offset = 0)
{
    enum div = 16.0;
    return convolution(colors, [
            [1.0 / div, 2 / div, 1 / div],
            [2.0 / div, 4 / div, 2 / div],
            [1.0 / div, 2 / div, 1 / div]
        ], offset);
}

RGBA[][] gaussian5x5(RGBA[][] colors, float offset = 0)
{
    enum div = 273.0;
    return convolution(colors, [
            [1.0 / div, 4.0 / div, 7.0 / div, 4.0 / div, 1.0 / div],
            [4.0 / div, 16.0 / div, 26.0 / div, 16.0 / div, 4.0 / div],
            [7.0 / div, 26.0 / div, 41.0 / div, 26.0 / div, 7.0 / div],
            [4.0 / div, 16.0 / div, 26.0 / div, 16.0 / div, 4.0 / div],
            [1.0 / div, 4.0 / div, 7.0 / div, 4.0 / div, 1.0 / div]
        ], offset);
}

RGBA[][] gaussian7x7(RGBA[][] colors, float offset = 0)
{
    enum div = 1003.0;
    return convolution(colors, [
            [0 / div, 0 / div, 1.0 / div, 2.0 / div, 1.0 / div, 0 / div, 0 / div],
            [
                0 / div, 3.0 / div, 13.0 / div, 22.0 / div, 13.0 / div, 3.0 / div,
                0 / div
            ],
            [
                1.0 / div, 13.0 / div, 59.0 / div, 97.0 / div, 59.0 / div,
                13.0 / div, 1.0 / div
            ],
            [
                2.0 / div, 22.0 / div, 97.0 / div, 159.0 / div, 97.0 / div,
                22.0 / div, 2.0 / div
            ],
            [
                1.0 / div, 13.0 / div, 59.0 / div, 97.0 / div, 59.0 / div,
                13.0 / div, 1.0 / div
            ],
            [
                0 / div, 3.0 / div, 13.0 / div, 22.0 / div, 13.0 / div, 3.0 / div,
                0 / div
            ],
            [0 / div, 0 / div, 1.0 / div, 2.0 / div, 1.0 / div, 0 / div, 0 / div]
        ], offset);
}

RGBA[][] flop(RGBA[][] colors) => mirror(colors, true, false);
RGBA[][] flip(RGBA[][] colors) => mirror(colors, false, true);

RGBA[][] mirror(RGBA[][] colors, bool isAxisX = true, bool isAxisY = true)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);

    foreach (y, RGBA[] colorY; colors)
    {
        foreach (x, ref RGBA color; colorY)
        {
            const newX = isAxisX ? (colorWidth - 1) - x : x;
            const newY = isAxisY ? (colorHeight - 1) - y : y;
            buffer[newY][newX] = color;
        }
    }

    return buffer;
}

RGBA[][] histogram(RGBA[][] colors)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    int[] histogram = new int[256];
    float max = 0;

    foreach (y, row; colors)
    {
        foreach (x, ref RGBA color; row)
        {
            int bright = cast(int) color.brightness;
            histogram[bright]++;
            int value = histogram[bright];
            if (value > max)
            {
                max = value;
            }
        }
    }

    RGBA[][] buffer = new RGBA[][](colorHeight, colorHeight);

    foreach (histIndex, histValue; histogram)
    {
        float scaleX = colorWidth / 255.0;
        float scaleY = colorHeight / max;

        size_t x = cast(size_t)(histIndex * scaleX);
        size_t maxY = cast(size_t)(histValue * scaleY);

        foreach (y; 0 .. maxY)
        {
            buffer[colorHeight - 1 - y][x] = RGBA.white;
        }
    }

    return buffer;
}
