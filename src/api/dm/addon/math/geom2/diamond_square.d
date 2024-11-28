module api.dm.addon.math.geom2.diamond_square;
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

    double randomRangeMin = 20;
    double randomRangeMax = 50;

    protected
    {
        size_t _matrixLength;
        double[][] matrix;
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

        return Math.floor(rnd.between0to1 * (max - min + 1) + min);
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
            return TerrainInfo(unknownTerrain, unknownTerrain.color);
        }

        auto colorVariety = terrains.length;
        size_t terrainIndex = cast(size_t) Math.floor(percentage * colorVariety);

        auto terrain = terrainIndex < terrains.length ? terrains[terrainIndex]
            : terrains[terrains.length - 1];

        auto finalVariance = Math.floor(rnd.between0to1 * terrain.variance);
        auto finalHue = (terrain.color.hue + finalVariance) % HSV.maxHue;

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

import api.dm.gui.controls.control : Control;

class DiamondSquareGenerator : Control
{
    import api.dm.gui.controls.forms.fields.regulate_text_field : RegulateTextField;
    import api.dm.gui.controls.forms.fields.regulate_text_panel : RegulateTextPanel;

    import api.dm.gui.containers.container : Container;
    import api.dm.gui.containers.stack_box : StackBox;

    import api.dm.kit.graphics.colors.rgba : RGBA;
    import api.math.geom2.rect2 : Rect2d;
    import api.dm.kit.sprites.sprite : Sprite;
    import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
    import api.dm.gui.controls.popups.pointer_popup : PointerPopup;

    StackBox contentContainer;
    double canvasWidth = 0;
    double canvasHeight = 0;

    Random rnd;

    DiamondSquareTerrain generator;

    TerrainPixel[] terrain;
    Rect2d[][RGBA] terrainPoints;

    double randomRangeMin = 0;
    double randomRangeMax = 0;

    RegulateTextField randomRangeMinField;
    RegulateTextField randomRangeMaxField;

    this(double canvasSize, double randomRangeMin, double randomRangeMax, Random rnd = null)
    {
        this.rnd = !rnd ? new Random : rnd;
        this.randomRangeMin = randomRangeMin;
        this.randomRangeMax = randomRangeMax;

        canvasWidth = canvasSize;
        canvasHeight = canvasSize;

        import std.math.exponential : log2;
        import std.conv : to;

        assert(canvasWidth > 1);

        const size_t matrixInitSize = Math.trunc(log2(canvasWidth - 1)).to!size_t;

        generator = DiamondSquareTerrain(randomRangeMin, randomRangeMax, matrixInitSize, rnd);

        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

         contentContainer = new StackBox;
        contentContainer.width = generator.canvasWidth;
        contentContainer.height = generator.canvasHeight;
        addCreate(contentContainer);

        auto popup = new PointerPopup();
        contentContainer.addCreate(popup);

        contentContainer.onPointerMove ~= (ref e) {
            auto ex = e.x;
            auto ey = e.y;
            auto dx = 1;
            auto dy = 1;
            foreach (TerrainPixel px; terrain)
            {
                if (Math.abs(ex - px.x) <= dx && Math.abs(ey - px.y) <= dy)
                {
                    auto text = px.terrain.type.name;
                    popup.text = text;
                    popup.show;
                    break;
                }
            }
        };

        auto fieldRoot = new RegulateTextPanel(5);
        addCreate(fieldRoot);

        randomRangeMinField = createRegField(fieldRoot, "Range min:", 1, 100, (v) {
            randomRangeMin = v;
            generator.generator.randomRangeMin = randomRangeMin;
            generate;
        });

        randomRangeMaxField = createRegField(fieldRoot, "Range max:", 1, 100, (v) {
            randomRangeMax = v;
            generator.generator.randomRangeMax = randomRangeMax;
            generate;
        });

        randomRangeMinField.value = randomRangeMin;
        randomRangeMaxField.value = randomRangeMax;

        import api.dm.gui.controls.switches.buttons.button : Button;

        auto genBtn = new Button("Generate");
        fieldRoot.addCreate(genBtn);
        genBtn.onAction ~= (ref e) { generate; };
    }

    void generate()
    {

        terrainPoints.clear;

        generator.generate;
        if (terrain.length != generator.terrainSize)
        {
            //TODO reuse
            terrain = new TerrainPixel[](generator.terrainSize);
        }

        generator.iterateTerrain((terrainInfo, i) {
            auto color = terrainInfo.terrain.color.toRGBA;

            (terrainPoints[color]) ~= Rect2d(terrainInfo.x, terrainInfo.y, terrainInfo.pixelWidth, terrainInfo
                .pixelHeight);

            terrain[i] = terrainInfo;
            return true;
        });
    }

    protected RegulateTextField createRegField(Sprite root, dstring label = "Label", double minValue = 0, double maxValue = 1, void delegate(
            double) onScrollValue = null)
    {

        auto field = new RegulateTextField;
        root.addCreate(field);
        field.labelField.text = label;
        field.scrollField.minValue = minValue;
        field.scrollField.maxValue = maxValue;
        field.scrollField.onValue ~= onScrollValue;
        return field;
    }

    override void drawContent()
    {
        super.drawContent;
        foreach (color, rects; terrainPoints)
        {
            graphics.fillRects(rects, color);
        }
    }

}
