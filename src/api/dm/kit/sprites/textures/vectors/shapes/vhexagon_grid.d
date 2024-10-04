module api.dm.kit.sprites.textures.vectors.shapes.vhexagon_grid;

import api.dm.kit.sprites.textures.vectors.shapes.vshape : VShape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.textures.vectors.shapes.vhexagon : VHexagon;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

struct HexagonGeometry
{
    Vec2d pos;
    VHexagon hexagon;
}

/**
 * Authors: initkfs
 */
class VHexagonGrid : Sprite
{
    protected
    {
        size_t sideCount;
        double hexagonSize = 0;
        GraphicStyle style;
    }

    HexagonGeometry[] hexagons;

    this(double width, double height, double hexagonSize, GraphicStyle style, size_t sideCount = 6)
    {
        this.width = width;
        this.height = height;
        this.sideCount = sideCount;
        this.hexagonSize = hexagonSize;
        this.style = style;
    }

    override void applyLayout()
    {
        super.applyLayout;

        const radius = hexagonSize / 2;

        foreach (hexInfo; hexagons)
        {
            auto pos = hexInfo.pos;
            auto hex = hexInfo.hexagon;
            hex.xy(x + pos.x - radius, y + pos.y - radius);
        }
    }

    void drawHexagon(double x, double y)
    {
        auto hex = new VHexagon(hexagonSize, style);
        addCreate(hex);
        hexagons ~= HexagonGeometry(Vec2d(x, y), hex);
    }

    override void create()
    {
        super.create;

        //algorithm ported from https://github.com/eperezcosano/hexagonal-grid/tree/master
        //under MIT license
        //may also be useful https://stackoverflow.com/questions/71942765/honeycomb-hexagonal-grid
        double radius = hexagonSize / 2;
        const angle = Math.PI2 / sideCount;
        const angleCos = Math.cos(angle);
        const angleSin = Math.sin(angle);

        const polarX1 = radius * (1 + angleCos);
        const polarY = radius * angleSin;

        double y = radius, j = 0, offsetX = 0, offsetY = 0;

        while (offsetY < height)
        {
            double x = radius;
            while (offsetX < width)
            {
                drawHexagon(x, y);
                offsetX = x + polarX1;
                x += polarX1;
                y += (-1) ^^ j++ * polarY;
            }

            y += 2 ^^ ((j + 1) % 2) * polarY;
            j = 0;
            offsetY = y + polarY;
            offsetX = 0;
        }

    }

}
