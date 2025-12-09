module api.dm.kit.graphics.colors.processings.transforms;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.numericals.interp : blerp;

import api.math.geom2.rect2 : Rect2f;

import Math = api.math;

/**
 * Authors: initkfs
 */

//TODO slow version
RGBA[][] bilinear(RGBA[][] colors, size_t newWidth, size_t newHeight)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    RGBA[][] buffer = new RGBA[][](newHeight, newWidth);

    import api.math.numericals.interp;

    foreach (x; 0 .. newWidth)
    {
        foreach (y; 0 .. newHeight)
        {
            const float gx = (cast(float) x) / newWidth * (colorWidth - 1);
            const float gy = (cast(float) y) / newHeight * (colorHeight - 1);

            const int gxi = cast(int) gx;
            const int gyi = cast(int) gy;

            RGBA c00 = colors[gyi][gxi];
            RGBA c10 = colors[gyi][gxi + 1];
            RGBA c01 = colors[gyi + 1][gxi];
            RGBA c11 = colors[gyi + 1][gxi + 1];

            const ubyte red = cast(ubyte) blerp(c00.r, c10.r, c01.r, c11.r, gx - gxi, gy - gyi, false);
            const ubyte green = cast(ubyte) blerp(c00.g, c10.g, c01.g, c11.g, gx - gxi, gy - gyi, false);
            const ubyte blue = cast(ubyte) blerp(c00.b, c10.b, c01.b, c11.b, gx - gxi, gy - gyi, false);
            const float alpha = blerp(c00.a, c10.a, c01.a, c11.a, gx - gxi, gy - gyi, false);

            RGBA color = RGBA(red, green, blue, alpha);

            buffer[y][x] = color;
        }
    }

    return buffer;
}

RGBA[][] crop(RGBA[][] colors, Rect2f area)
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

RGBA[][] rotate(RGBA[][] colors, float angleDegClockwise)
{
    assert(colors.length > 0);
    assert(colors[0].length > 0);

    size_t colorHeight = colors.length;
    size_t colorWidth = colors[0].length;

    import Math = api.dm.math;
    import api.math.matrices.dense_matrix : DenseMatrix;

    //clockwise
    const angleRad = -Math.degToRad(angleDegClockwise);

    //use float
    const float centerX = colorWidth / 2;
    const float centerY = colorHeight / 2;

    RGBA[][] buffer = new RGBA[][](colorHeight, colorWidth);

    //https://math.stackexchange.com/questions/2093314
    const moveMatrix = DenseMatrix!(float, 3, 3)([
        [1.0f, 0, centerX],
        [0.0f, 1, centerY],
        [0.0f, 0, 1]
    ]);

    const rotateMatrix = DenseMatrix!(float, 3, 3)([
        [Math.cos(angleRad), -Math.sin(angleRad), 0],
        [Math.sin(angleRad), Math.cos(angleRad), 0],
        [0.0f, 0, 1]
    ]);

    const backMatrix = DenseMatrix!(float, 3, 3)([
        [1.0f, 0, -centerX],
        [0.0f, 1, -centerY],
        [0.0f, 0, 1]
    ]);

    const resultMatrix = moveMatrix.mul(rotateMatrix).mul(backMatrix);

    //TODO it's all copied
    import api.math.matrices.dense_matrix : DenseMatrix;

    foreach (y, colorRow; colors)
    {
        foreach (x, ref color; colorRow)
        {
            const pixelMatrix = DenseMatrix!(float, 3, 1)([
                [cast(float) x],
                [cast(float) y],
                [1.0f]
            ]);

            auto pixelPosMatrix = resultMatrix.mul(pixelMatrix);
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
