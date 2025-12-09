module api.dm.gui.controls.indicators.loaders.radial_loader;

import api.dm.gui.controls.indicators.loaders.base_loader : BaseLoader;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsla : HSLA;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

/**
 * Authors: initkfs
 */
class RadialLoader : BaseLoader
{
    protected
    {
        Sprite2d[] segments;
        size_t segmentsCount;
        size_t segmentDistance = 40;
        size_t segmentDiameter = 15;

        float progress = 0;
    }

    float speed = 2;

    this(size_t segmentsCount = 6)
    {
        this.segmentsCount = segmentsCount;
    }

    override void loadTheme()
    {
        super.loadTheme;

        auto size = segmentDiameter * 2 + segmentDistance;

        if (_width == 0)
        {
            _width = size;
        }

        if (_height == 0)
        {
            _height = size;
        }
    }

    Sprite2d createSegment()
    {
        auto style = createFillStyle;
        style.fillColor = RGBA.white;
        style.lineColor = RGBA.white;
        auto segment = theme.regularPolyShape(segmentDiameter, 6, 0, style);
        return segment;
    }

    override void create()
    {
        super.create;

        import api.math.random : rands;

        auto rnd = rands;

        foreach (i; 0 .. segmentsCount)
        {
            auto segment = createSegment;
            segment.isLayoutManaged = false;
            addCreate(segment);

            if (auto texture = cast(Texture2d) segment)
            {
                auto randomColor = HSLA.random(rnd);
                randomColor.l = 0.5;
                randomColor.s = 0.9;
                randomColor.a = 1;
                texture.color = randomColor.toRGBA;
            }
            segments ~= segment;
        }

        drawSegments;
    }

    override void drawContent()
    {
        super.drawContent;

        if (!isRunning)
        {
            return;
        }

        drawSegments;
    }

    void drawSegments()
    {
        const bounds = boundsRect;
        const center = bounds.center;

        const float fullAngleDeg = 360;

        auto angleDiff = fullAngleDeg / segmentsCount;
        float currAngle = progress;

        auto newSegmentCenter = width / 2 - segmentDiameter / 2;

        foreach (Sprite2d s; segments)
        {
            auto pos = Vec2d.fromPolarDeg(currAngle, newSegmentCenter)
                .add(center).sub(Vec2d(s.halfWidth, s.halfHeight));
            s.pos = pos;
            currAngle = (currAngle + angleDiff) % fullAngleDeg;

            if (auto segmentTexture = cast(Texture2d) s)
            {
                RGBA color = segmentTexture.color;

                import api.dm.kit.graphics.colors.hsla : HSLA;

                HSLA hsl = color.toHSLA;
                hsl.h = (hsl.h + 1) % HSLA.maxHue;
                if (hsl.h == 0)
                {
                    hsl.h += 5;
                }
                segmentTexture.color = hsl.toRGBA;
            }

            //sin to -1 and 1.
            //+1, shift to range [0, 2].
            //x/2, normalize to [0, 1].
            const minSpriteOpacity = 0.1;
            float opacity = minSpriteOpacity + (1 - minSpriteOpacity) * (
                Math.sinDeg(currAngle) + 1.0) / 2.0;
            s.opacity = opacity;
        }

        progress += speed;
        if (progress > fullAngleDeg)
        {
            progress = 0;
        }

    }

}
