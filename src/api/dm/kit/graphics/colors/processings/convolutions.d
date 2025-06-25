module api.dm.kit.graphics.colors.processings.convolutions;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.numericals.interp : blerp;

import Math = api.math;

/**
 * Authors: initkfs
 */

RGBA[][] convolution(RGBA[][] colors, double[][] kernel, double offset = 0)
{
    assert(colors.length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;
    assert(colorWidth > 0);

    //TODO remove allocation
    RGBA[][] buff = new RGBA[][](colorHeight, colorWidth);
    convolution(colors, kernel, buff, offset);
    return buff;
}

void convolution(RGBA[][] colors, double[][] kernel, RGBA[][] colorsResult, double offset = 0)
{
    assert(kernel.length > 0);
    assert(kernel[0].length > 0);

    size_t kernelWidth = kernel[0].length;
    size_t kernelHeight = kernel.length;

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    foreach (y, ref RGBA[] colorRow; colors)
    {
        foreach (x, ref RGBA c; colorRow)
        {
            double rSum = 0, gSum = 0, bSum = 0, aSum = 0, kSum = 0;

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
                    aSum += color.aByte * kernelValue;

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
            rSum = Math.clamp(rSum, RGBA.minColor, RGBA.maxColor);

            gSum /= kSum;
            gSum += offset;
            gSum = Math.clamp(gSum, RGBA.minColor, RGBA.maxColor);

            bSum /= kSum;
            bSum += offset;
            bSum = Math.clamp(bSum, RGBA.minColor, RGBA.maxColor);

            aSum /= kSum;
            aSum += offset;
            aSum = Math.clamp(aSum, RGBA.minColor, RGBA.maxColor);

            colorsResult[y][x] = RGBA(cast(ubyte) rSum, cast(ubyte) gSum, cast(ubyte) bSum, RGBA.fromAByte(
                    cast(ubyte) aSum));
        }
    }
}
