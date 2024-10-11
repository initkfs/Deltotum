module api.math.geom2.diamond_square;
/**
 * Authors: initkfs
 */
import api.dm.kit.graphics.colors.hsv : HSV;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;
import api.math.random : Random;

/*
 * Ported from Yonatan Kra, How to Create Terrain and Heightmaps using the Diamond-Square Algorithm in JavaScript. 
 * https://yonatankra.com/how-to-create-terrain-and-heightmaps-using-the-diamond-square-algorithm-in-javascript/
*/
struct DiamondSquare
{
    enum matrixDefaultSize = 8;
    size_t matrixInitSize = matrixDefaultSize;

    Random rnd;

    bool isNormalizeMatrix = true;
    bool isSquareNormalized = true;

    protected
    {
        size_t _matrixLength;
        double[][] matrix;

        double randomRangeMin = 0;
        double randomRangeMax = 0;
    }

    // invariant
    // {
    //     assert(matrix.length == _matrixLength);
    // }

    static DiamondSquare newNormalized() => DiamondSquare(0, 1, matrixDefaultSize);

    this(double randomRangeMin, double randomRangeMax, size_t matrixInitSize = matrixDefaultSize, Random rnd = null)
    {
        assert(matrixInitSize > 0);

        this.matrixInitSize = matrixInitSize;

        this.randomRangeMin = randomRangeMin;
        this.randomRangeMax = randomRangeMax;

        this.rnd = rnd ? rnd : new Random;
    }

    void calcMatrixLength()
    {
        _matrixLength = calcMatrixLength(matrixInitSize);
    }

    size_t calcMatrixLength(size_t matrixInitSize)
    {
        assert(matrixInitSize > 0);

        import std.conv : to;

        return (Math.pow(2, matrixInitSize) + 1).to!size_t;
    }

    double randomInRange(double min, double max)
    {
        assert(min <= max);

        return Math.floor(rnd.randomBetween0to1 * (max - min + 1) + min);
    }

    void createMatrix()
    {
        if (_matrixLength != 0 || matrix.length != 0)
        {
            clearMatrix;
            setInitPoints;
            return;
        }

        calcMatrixLength;

        matrix = new double[][](_matrixLength, _matrixLength);
        clearMatrix;

        setInitPoints;
    }

    void setInitPoints()
    {
        assert(matrix.length > 0);

        immutable size_t lastIndex = _matrixLength - 1;

        matrix[0][lastIndex] = randomInRange(randomRangeMin, randomRangeMax);
        matrix[lastIndex][0] = randomInRange(randomRangeMin, randomRangeMax);
        matrix[0][0] = randomInRange(randomRangeMin, randomRangeMax);
        matrix[lastIndex][lastIndex] = randomInRange(randomRangeMin, randomRangeMax);
    }

    void clearMatrix()
    {
        foreach (ref row; matrix)
        {
            foreach (ref col; row)
            {
                col = 0;
            }
        }
    }

    void calculateSquare(size_t chunkSize, double randomFactor)
    {
        assert(matrix.length > 0);

        immutable size_t lastIndex = matrix.length - 1;

        for (int i = 0; i < lastIndex; i += chunkSize)
        {
            for (int j = 0; j < lastIndex; j += chunkSize)
            {
                double[4] sides = double.infinity;
                size_t sideIndex;

                //TODO extract variables
                if ((j + chunkSize) < _matrixLength)
                {
                    if ((i + chunkSize) < _matrixLength)
                    {
                        auto bottomRight = matrix[j + chunkSize][i + chunkSize];
                        sides[sideIndex] = bottomRight;
                        sideIndex++;
                    }

                    auto bottomLeft = matrix[j + chunkSize][i];
                    sides[sideIndex] = bottomLeft;
                    sideIndex++;
                }

                auto topLeft = matrix[j][i];
                sides[sideIndex] = topLeft;
                sideIndex++;

                if (i + chunkSize < _matrixLength)
                {
                    auto topRight = matrix[j][i + chunkSize];
                    sides[sideIndex] = topRight;
                    sideIndex++;
                }

                double sum = 0;
                size_t count;

                import std.math.traits : isFinite;

                foreach (side; sides)
                {
                    if (!side.isFinite)
                    {
                        continue;
                    }
                    sum += side;
                    count++;
                }

                matrix[j + chunkSize / 2][i + chunkSize / 2] =
                    sum / count + randomInRange(-randomFactor, randomFactor);
            }
        }
    }

    void calculateDiamond(size_t chunkSize, double randomFactor)
    {
        auto half = chunkSize / 2;

        for (auto y = 0; y < matrix.length; y += half)
        {
            for (auto x = (y + half) % chunkSize; x < matrix.length; x += chunkSize)
            {

                double[4] sides = double.infinity;
                size_t sideIndex;

                auto yAddHalf = y + half;

                if (yAddHalf < _matrixLength)
                {
                    auto bottom = matrix[yAddHalf][x];
                    sides[sideIndex] = bottom;
                    sideIndex++;
                }

                if (half <= x)
                {
                    auto xSubHalf = x - half;

                    auto left = matrix[y][xSubHalf];
                    sides[sideIndex] = left;
                    sideIndex++;
                }

                if (half <= y)
                {
                    auto ySubHalf = y - half;
                    if (ySubHalf < _matrixLength)
                    {
                        auto top = matrix[ySubHalf][x];
                        sides[sideIndex] = top;
                        sideIndex++;
                    }

                }

                auto xAddHalf = x + half;

                if (xAddHalf < matrix.length)
                {
                    auto right = matrix[y][xAddHalf];
                    sides[sideIndex] = right;
                    sideIndex++;
                }

                double sum = 0;
                size_t count;

                import std.math.traits : isFinite;

                //TODO duplication with calcSquare
                foreach (side; sides)
                {
                    if (!side.isFinite)
                    {
                        continue;
                    }
                    sum += side;
                    count++;
                }

                matrix[y][x] = sum / count + randomInRange(-randomFactor, randomFactor);
            }
        }
    }

    void diamondSquare()
    {
        clearMatrix;
        assert(matrix.length > 0);

        size_t chunkSize = _matrixLength - 1;

        double randomFactor = randomRangeMax;

        while (chunkSize > 1)
        {
            calculateSquare(chunkSize, randomFactor);
            calculateDiamond(chunkSize, randomFactor);
            chunkSize /= 2;
            randomFactor /= 2;
        }

        if (isNormalizeMatrix)
        {
            normalizeMatrix(matrix);
            if (isSquareNormalized)
            {
                foreach (ref row; matrix)
                {
                    foreach (ref col; row)
                    {
                        col = Math.pow(col, 2);
                    }
                }
            }
        }
    }

    void normalizeMatrix(double[][] matrix)
    {
        double maxValue = -double.infinity;

        foreach (ref row; matrix)
        {
            foreach (ref col; row)
            {
                if (col > maxValue)
                {
                    maxValue = col;
                }
            }
        }

        foreach (ref row; matrix)
        {
            foreach (ref col; row)
            {
                col = col / maxValue;
            }
        }
    }

    size_t matrixLength() => _matrixLength;
}

struct TerrainType
{
    string name;
    HSV color;
    double variance = 0;
}

struct TerrainInfo
{
    TerrainType type;
    HSV color;
}

struct TerrainPixel
{
    TerrainInfo terrain;
    double x = 0;
    double y = 0;
    double pixelWidth = 0;
    double pixelHeight = 0;
}

struct DiamondSquareTerrain
{
    protected
    {
        double _canvasHeight = 0;
        double _canvasWidth = 0;
        double _pixelHeight = 0;
        double _pixelWidth = 0;

        DiamondSquare generator;
    }

    Random rnd;

    TerrainType unknownTerrain =
    {name: "unknown",
    color: HSV(0, 1, 1),
    variance: 1};

    TerrainType[] terrains = [
        {name: "mountain",
    color: HSV(30, 0.5, 0.5),
    variance: 20},
        {name: "plain",
    color: HSV(100, 0.5, 0.7),
    variance: 20},
        {name: "water",
    color: HSV(200, 0.9, 0.67),
    variance: 10}
    ];

    this(double randomRangeMin, double randomRangeMax, size_t matrixInitSize = DiamondSquare
            .matrixDefaultSize, Random rnd = null)
    {
        this.rnd = rnd ? rnd : new Random;
        generator = DiamondSquare(randomRangeMin, randomRangeMax, matrixInitSize, rnd);

        generator.createMatrix;

        assert(generator.matrixLength > 0);

        _canvasHeight = generator.matrixLength * 2;
        _canvasWidth = generator.matrixLength * 2;
        _pixelHeight = _canvasHeight / generator.matrixLength;
        _pixelWidth = _canvasWidth / generator.matrixLength;
    }

    double canvasWidth() => _canvasWidth;
    double canvasHeight() => _canvasHeight;
    double pixelWidth() => _pixelWidth;
    double pixelHeight() => _pixelHeight;

    TerrainInfo terrainInfo(double percentage) => landscapeInfo(percentage);

    TerrainInfo landscapeInfo(double percentage)
    {
        if (percentage < 0.01 || terrains.length == 0)
        {
            return TerrainInfo(unknownTerrain, HSV(0, 1, 1));
        }

        auto colorVariety = terrains.length;
        size_t terrainIndex = cast(size_t) Math.floor(percentage * colorVariety);

        auto terrain = terrainIndex < terrains.length ? terrains[terrainIndex]
            : terrains[terrains.length - 1];

        auto finalVariance = Math.floor(rnd.randomBetween0to1 * terrain.variance);
        auto finalHue = (terrain.color.hue % 360) + finalVariance;

        return TerrainInfo(terrain, HSV(finalHue, terrain.color.saturation, terrain.color.value));
    }

    void generate()
    {
        generator.diamondSquare;
    }

    size_t terrainSize()
    {
        return generator.matrixLength * generator.matrixLength;
    }

    void iterateTerrain(scope bool delegate(TerrainPixel, size_t index) onTerrainIndexIsContinue)
    {
        assert(onTerrainIndexIsContinue);
        size_t index;
        foreach (rowIndex, ref pixelsRow; generator.matrix)
        {
            foreach (pixelIndex, ref pixel; pixelsRow)
            {
                auto y = rowIndex * _pixelHeight;
                auto x = pixelIndex * _pixelWidth;

                TerrainPixel terrPixel = TerrainPixel(terrainInfo(pixel), x, y, _pixelWidth, _pixelHeight);
                if (!onTerrainIndexIsContinue(terrPixel, index))
                {
                    return;
                }
                index++;
            }
        }
    }
}
