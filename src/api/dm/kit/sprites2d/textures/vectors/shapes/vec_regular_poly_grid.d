module api.dm.kit.sprites2d.textures.vectors.shapes.vec_regular_poly_grid;

import api.dm.kit.sprites2d.textures.vectors.shapes.vec_shape : VecShape;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vec_regular_poly : VecRegularPoly;
import api.math.geom2.vec2 : Vec2f;

import Math = api.dm.math;

struct RPolyGeometry
{
    Vec2f pos;
    VecRegularPoly hexagon;
}

/**
 * Authors: initkfs
 */
class VecRegularPolyGrid : Sprite2d
{
    protected
    {
        size_t sideCount;
        float hexagonSize = 0;
        GStyle style;
    }

    RPolyGeometry[] hexagons;

    this(float width, float height, float hexagonSize, GStyle style, size_t sideCount = 6)
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

    void drawPoly(float x, float y)
    {
        auto hex = new VecRegularPoly(hexagonSize, style);
        addCreate(hex);
        hexagons ~= RPolyGeometry(Vec2f(x, y), hex);
    }

    override void create()
    {
        super.create;

        //algorithm ported from https://github.com/eperezcosano/hexagonal-grid/tree/master
        //under MIT license
        //may also be useful https://stackoverflow.com/questions/71942765/honeycomb-hexagonal-grid
        float radius = hexagonSize / 2;
        const angle = Math.PI2 / sideCount;
        const angleCos = Math.cos(angle);
        const angleSin = Math.sin(angle);

        const polarX1 = radius * (1 + angleCos);
        const polarY = radius * angleSin;

        float y = radius, j = 0, offsetX = 0, offsetY = 0;

        while (offsetY < height)
        {
            float x = radius;
            while (offsetX < width)
            {
                drawPoly(x, y);
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
