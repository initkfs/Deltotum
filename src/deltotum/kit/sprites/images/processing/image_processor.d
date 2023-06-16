module deltotum.kit.sprites.images.processing.image_processor;

import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.shapes.rect2d : Rect2d;
import Math = deltotum.math;

import std.stdio;

//TODO other modes
enum BlendMode
{
    normal,
    multiply,
    divide,
    screen,
    overlay,
}

/**
 * Authors: initkfs
 */
class ImageProcessor
{
    RGBA grayscale(RGBA color, double threshold = -1)
    {
        import std.conv : to;

        const coeffLinear = color.rNorm * 0.2126 + color.gNorm * 0.7152 + color.bNorm * 0.0722;
        double coeffSrgb = 0;
        if (coeffLinear <= 0.0031308)
        {
            coeffSrgb = 12.92 * coeffLinear;
        }
        else
        {
            import Math = deltotum.math;

            coeffSrgb = 1.055 * (coeffLinear ^^ (1.0 / 2.4)) - 0.055;
        }

        ubyte colorValue = (coeffSrgb * RGBA.RGBAData.maxColor).to!ubyte;
        if (threshold > 0)
        {
            colorValue = colorValue > threshold ? RGBA.RGBAData.maxColor : RGBA.RGBAData.minColor;
        }

        RGBA newColor = RGBA(colorValue, colorValue, colorValue, color.a);
        return newColor;
    }

    RGBA negative(RGBA color)
    {
        import std.conv : to;

        ubyte maxColor = RGBA.RGBAData.maxColor;
        ubyte newR = (maxColor - color.r).to!ubyte;
        ubyte newG = (maxColor - color.g).to!ubyte;
        ubyte newB = (maxColor - color.b).to!ubyte;

        RGBA newColor = RGBA(newR, newG, newB, color.a);
        return newColor;
    }

    RGBA solarization(RGBA color, double threshold = 10)
    {
        import Math = deltotum.math;

        import std.conv : to;

        const checkTreshold = (ubyte colorValue) {
            return colorValue < threshold ? (RGBA.RGBAData.maxColor - colorValue)
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
        import Math = deltotum.math;
        import std.conv : to;

        const maxColorValue = RGBA.RGBAData.maxColor;

        const newR = 0.393 * color.r + 0.769 * color.g + 0.189 * color.b;
        const newG = 0.349 * color.r + 0.686 * color.g + 0.168 * color.b;
        const newB = 0.272 * color.r + 0.534 * color.g + 0.131 * color.b;

        const r = Math.min(newR, maxColorValue).to!ubyte;
        const g = Math.min(newG, maxColorValue).to!ubyte;
        const b = Math.min(newB, maxColorValue).to!ubyte;

        RGBA newColor = RGBA(r, g, b, color.a);
        return newColor;
    }

    RGBA posterize(RGBA color, RGBA[] palette, double minDistance = 10)
    {
        foreach (ref RGBA paletterColor; palette)
        {
            double distance = color.distance(paletterColor);
            if (distance <= minDistance)
            {
                return paletterColor;
            }
        }

        return color;
    }

    RGBA[][] convolution(RGBA[][] colors, double[][] kernel, double offset = 0)
    {
        assert(kernel.length > 0);
        assert(kernel[0].length > 0);

        size_t kernelWidth = kernel[0].length;
        size_t kernelHeight = kernel.length;

        size_t colorHeight = colors.length;
        size_t colorWidth = colors[0].length;

        //TODO remove allocation
        RGBA[][] colorsResult = new RGBA[][](colorHeight, colorWidth);

        foreach (x, ref RGBA[] colorRow; colors)
        {
            foreach (y, ref RGBA c; colorRow)
            {
                double rSum = 0, gSum = 0, bSum = 0, kSum = 0;

                foreach (kernelY, kernelRow; kernel)
                {
                    foreach (kernelX, kernelValue; kernelRow)
                    {
                        auto pixelPosX = x + (kernelX - (kernelWidth / 2));
                        auto pixelPosY = y + (kernelY - (kernelHeight / 2));
                        if ((pixelPosX < 0) ||
                            (pixelPosX >= colorWidth) ||
                            (pixelPosY < 0) ||
                            (pixelPosY >= colorHeight))
                        {
                            continue;
                        }

                        auto color = colors[pixelPosY][pixelPosX];

                        rSum += color.r * kernelValue;
                        gSum += color.g * kernelValue;
                        bSum += color.b * kernelValue;

                        kSum += kernelValue;
                    }
                }

                if (kSum <= 0)
                {
                    kSum = 1.0;
                }

                //TODO remove duplication
                rSum /= kSum;
                rSum += offset;
                rSum = Math.clamp(rSum, RGBA.RGBAData.minColor, RGBA.RGBAData.maxColor);

                gSum /= kSum;
                gSum += offset;
                gSum = Math.clamp(gSum, RGBA.RGBAData.minColor, RGBA.RGBAData.maxColor);

                bSum /= kSum;
                bSum += offset;
                bSum = Math.clamp(bSum, RGBA.RGBAData.minColor, RGBA.RGBAData.maxColor);

                colorsResult[y][x] = RGBA(cast(ubyte) rSum, cast(ubyte) gSum, cast(ubyte) bSum);
            }
        }

        return colorsResult;
    }

    RGBA[][] highpass(RGBA[][] colors, double offset = 0)
    {
        const div = 4.0;
        return convolution(colors, [
                [0, -1 / div, 0],
                [-1 / div, +2, -1 / div],
                [0, -1 / div, 0]
            ], offset);
    }

    RGBA[][] lowpass(RGBA[][] colors, double offset = 0)
    {
        const div = 8.0;
        return convolution(colors, [
                [0, 1 / div, 0],
                [1 / div, 1 / (div / 2), 1 / div],
                [0, 1 / div, 0]
            ], offset);
    }

    RGBA[][] sobel(RGBA[][] colors, double offset = 0)
    {
        assert(colors.length > 0);
        assert(colors[0].length > 0);

        size_t colorHeight = colors.length;
        size_t colorWidth = colors[0].length;

        RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);

        double[][] sobelX = [
            [1, 2, 1],
            [0, 0, 0],
            [-1, -2, -1]
        ];

        double[][] sobelY = [
            [1, 0, -1],
            [2, 0, -2],
            [1, 0, -1]
        ];

        RGBA[][] bufferX = convolution(colors, sobelX);
        RGBA[][] bufferY = convolution(colors, sobelY);

        import Math = deltotum.math;

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

    RGBA[][] laplacian(RGBA[][] colors, double offset = 0)
    {
        return convolution(colors, [
                [0.0, -1, 0],
                [-1.0, 4, -1],
                [0.0, -1, 0]
            ], offset);
    }

    RGBA[][] emboss(RGBA[][] colors, double offset = 0)
    {
        return convolution(colors, [
                [-2.0, -1, 0],
                [-1.0, 1, 1],
                [0.0, 1, 2]
            ], offset);
    }

    RGBA[][] gaussian3x3(RGBA[][] colors, double offset = 0)
    {
        enum div = 16.0;
        return convolution(colors, [
                [1.0 / div, 2 / div, 1 / div],
                [2.0 / div, 4 / div, 2 / div],
                [1.0 / div, 2 / div, 1 / div]
            ], offset);
    }

    RGBA[][] flop(RGBA[][] colors)
    {
        return mirror(colors, true, false);
    }

    RGBA[][] flip(RGBA[][] colors)
    {
        return mirror(colors, false, true);
    }

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

    RGBA[][] rotate(RGBA[][] colors, double angleDegClockwise)
    {
        assert(colors.length > 0);
        assert(colors[0].length > 0);

        size_t colorHeight = colors.length;
        size_t colorWidth = colors[0].length;

        import Math = deltotum.math;
        import deltotum.math.matrices.dense_matrix : DenseMatrix;

        //clockwise
        const angleRad = -Math.degToRad(angleDegClockwise);

        //use double
        const double centerX = colorWidth / 2;
        const double centerY = colorHeight / 2;

        RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);

        //https://math.stackexchange.com/questions/2093314
        const moveMatrix = DenseMatrix!(double, 3, 3)([
            [1.0, 0, centerX],
            [0.0, 1, centerY],
            [0.0, 0, 1]
        ]);

        const rotateMatrix = DenseMatrix!(double, 3, 3)([
            [Math.cos(angleRad), -Math.sin(angleRad), 0],
            [Math.sin(angleRad), Math.cos(angleRad), 0],
            [0.0, 0, 1]
        ]);

        const backMatrix = DenseMatrix!(double, 3, 3)([
            [1.0, 0, -centerX],
            [0.0, 1, -centerY],
            [0.0, 0, 1]
        ]);

        const resultMatrix = moveMatrix.multiply(rotateMatrix).multiply(backMatrix);

        //TODO it's all copied
        import deltotum.math.matrices.dense_matrix : DenseMatrix;

        foreach (y, colorRow; colors)
        {
            foreach (x, ref color; colorRow)
            {
                const pixelMatrix = DenseMatrix!(double, 3, 1)([
                    [cast(double) x],
                    [cast(double) y],
                    [1.0]
                ]);

                auto pixelPosMatrix = resultMatrix.multiply(pixelMatrix);
                const size_t newX = cast(size_t) pixelPosMatrix.value(0, 0);
                const size_t newY = cast(size_t) pixelPosMatrix.value(1, 0);
                if (newX > colorWidth - 1 || newY > colorHeight - 1)
                {
                    continue;
                }

                buffer[y][x] = colors[newY][newX];
            }
        }

        return buffer;

    }

    RGBA[][] resizeBilinear(RGBA[][] colors, size_t newWidth, size_t newHeight)
    {
        assert(colors.length > 0);
        assert(colors[0].length > 0);

        size_t colorHeight = colors.length;
        size_t colorWidth = colors[0].length;

        RGBA[][] buffer = new RGBA[][](newHeight, newWidth);

        import deltotum.math.numericals.interp;

        foreach (x; 0 .. newWidth)
        {
            foreach (y; 0 .. newHeight)
            {
                const double gx = (cast(double) x) / newWidth * (colorWidth - 1);
                const double gy = (cast(double) y) / newHeight * (colorHeight - 1);

                const int gxi = cast(int) gx;
                const int gyi = cast(int) gy;

                RGBA c00 = colors[gyi][gxi];
                RGBA c10 = colors[gyi][gxi + 1];
                RGBA c01 = colors[gyi + 1][gxi];
                RGBA c11 = colors[gyi + 1][gxi + 1];

                const ubyte red = cast(ubyte) blerp(c00.r, c10.r, c01.r, c11.r, gx - gxi, gy - gyi, false);
                const ubyte green = cast(ubyte) blerp(c00.g, c10.g, c01.g, c11.g, gx - gxi, gy - gyi, false);
                const ubyte blue = cast(ubyte) blerp(c00.b, c10.b, c01.b, c11.b, gx - gxi, gy - gyi, false);
                const double alpha = blerp(c00.a, c10.a, c01.a, c11.a, gx - gxi, gy - gyi, false);

                RGBA color = RGBA(red, green, blue, alpha);

                buffer[y][x] = color;
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
        double max = 0;

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
            double scaleX = colorWidth / 255.0;
            double scaleY = colorHeight / max;

            size_t x = cast(size_t)(histIndex * scaleX);
            size_t maxY = cast(size_t)(histValue * scaleY);

            foreach (y; 0 .. maxY)
            {
                buffer[colorHeight - 1 - y][x] = RGBA.white;
            }
        }

        return buffer;
    }

    RGBA[][] crop(RGBA[][] colors, Rect2d area)
    {
        //TODO check area
        assert(colors.length > 0);
        assert(colors[0].length > 0);

        size_t colorHeight = colors.length;
        size_t colorWidth = colors[0].length;

        RGBA[][] buffer = new RGBA[][](cast(size_t) area.height, cast(size_t) area.width);

        foreach (y, row; buffer)
        {
            foreach (x, ref RGBA color; row)
            {
                const sourceX = cast(size_t)(area.x + x);
                const sourceY = cast(size_t)(area.y + y);
                if (sourceX >= colorWidth || sourceY >= colorHeight)
                {
                    continue;
                }
                RGBA needColor = colors[sourceY][sourceX];
                color = needColor;
            }
        }

        return buffer;
    }

    RGBA[][] blend(RGBA[][] colors, RGBA maskColor, BlendMode mode = BlendMode.normal)
    {
        assert(colors.length > 0);
        assert(colors[0].length > 0);

        size_t colorHeight = colors.length;
        size_t colorWidth = colors[0].length;

        //TODO mask from RGBA[][]
        //RGBA[][] mask = new RGBA[][](colorHeight, colorWidth);
        RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);

        scope ubyte delegate(double) colorCalc = (value) {
            const result = cast(ubyte) Math.clamp(Math.round(value), RGBA.RGBAData.minColor, RGBA
                    .RGBAData.maxColor);
            return result;
        };

        foreach (y, colorRow; colors)
        {
            foreach (x, ref color; colorRow)
            {
                double r = 0, g = 0, b = 0, a = 0;

                //TODO remove duplication
                final switch (mode) with (BlendMode)
                {
                case normal:
                    r = maskColor.r;
                    g = maskColor.g;
                    b = maskColor.b;
                    a = maskColor.a;
                    break;
                case multiply:
                    r = blendMultiply(color.r, maskColor.r);
                    g = blendMultiply(color.g, maskColor.g);
                    b = blendMultiply(color.b, maskColor.b);
                    a = blendMultiply(color.a, maskColor.a);
                    break;
                case divide:
                    r = blendDivide(color.r, maskColor.r);
                    g = blendDivide(color.g, maskColor.g);
                    b = blendDivide(color.b, maskColor.b);
                    a = blendDivide(color.a, maskColor.a);
                    break;
                case screen:
                    r = blendScreen(color.r, maskColor.r);
                    g = blendScreen(color.g, maskColor.g);
                    b = blendScreen(color.b, maskColor.b);
                    a = blendScreen(color.a, maskColor.a);
                    break;
                case overlay:
                    r = blendOverlay(color.r, maskColor.r);
                    g = blendOverlay(color.g, maskColor.g);
                    b = blendOverlay(color.b, maskColor.b);
                    a = blendOverlay(color.a, maskColor.a);
                    break;
                }

                auto colorPtr = &buffer[y][x];

                colorPtr.r = colorCalc(r);
                colorPtr.g = colorCalc(g);
                colorPtr.b = colorCalc(b);
                colorPtr.a = Math.clamp(a, RGBA.RGBAData.minAlpha, RGBA.RGBAData.maxAlpha);

            }

        }

        return buffer;

    }

    double blendMultiply(double color, double colorMask)
    {
        double factor = 1 / 255.0;
        return color * colorMask * factor;
    }

    double blendDivide(double color, double colorMask)
    {
        return (color * (RGBA.RGBAData.maxColor + 1)) / (colorMask + 1);
    }

    double blendScreen(double color, double colorMask)
    {
        const max = RGBA.RGBAData.maxColor;
        return max - (((max - colorMask) * (max - color)) / max);
    }

    double blendOverlay(double color, double colorMask)
    {
        const max = RGBA.RGBAData.maxColor;
        const coeff1 = (color / max);
        const coeff2 = (2 * colorMask) / max;
        return coeff1 * (color + coeff2 * (max - 1));
    }

}
