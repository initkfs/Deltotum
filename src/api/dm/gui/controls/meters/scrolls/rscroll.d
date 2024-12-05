module api.dm.gui.controls.meters.scrolls.rscroll;

import api.dm.gui.controls.meters.scrolls.base_radial_mono_scroll : BaseRadialMonoScroll;
import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.controls.scales.radial_scale : RadialScale;

import Math = api.math;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class RScroll : BaseRadialMonoScroll
{
    double fromAngleDeg = 0;
    double toAngleDeg = 90;

    RadialScale scale;

    double thumbPadding = 10;

    this(double minValue = 0, double maxValue = 1.0, double width = 200, double height = 200)
    {
        super(minValue, maxValue);
        this.width = width;
        this.height = height;
        isBorder = false;
        layout = new CenterLayout;
    }

    protected
    {
        bool isDragAngle;
        double lastDragAngle = 0;
    }

    override void create()
    {
        super.create;

        assert(thumb);

        import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;

        if (auto shapeTexture = cast(Texture2d) thumb)
        {
            shapeTexture.bestScaleMode;
        }

        scale = new RadialScale(width - 10, fromAngleDeg, toAngleDeg);
        //scale.tickOuterPadding *= 2;
        scale.labelOuterPadding *= 2;
        //scale.tickWidth = 2;
        //scale.tickMajorWidth = 2;
        scale.labelStep = 5;
        addCreate(scale);
    }

    Sprite2d newThumbRadialShape(double diameter, double angle, GraphicStyle style)
    {
        auto shape = theme.regularPolyShape(diameter, thumbSides, angle, style);
        return shape;
    }

    override Sprite2d newThumb()
    {
        assert(thumbDiameter > 0);

        auto style = createStyle;
        auto thumbShape = newThumbRadialShape(thumbDiameter, angle, style);
        if (!thumbShape.isBuilt || !thumbShape.isCreated)
        {
            buildInitCreate(thumbShape);
        }

        scope (exit)
        {
            thumbShape.dispose;
        }

        import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto thumb = new Texture2d(thumbDiameter, thumbDiameter);
        build(thumb);

        thumb.createTargetRGBA32;
        thumb.bestScaleMode;

        thumb.setRendererTarget;

        graphics.fillRect(0, 0, thumbDiameter, thumbDiameter, RGBA.black);

        thumbShape.draw;

        import api.math.geom2.vec2 : Vec2d;

        auto pointerSize = thumbDiameter / 5;
        auto pointerRadius = thumbDiameter / 2;
        
        auto pointerPos = Vec2d.fromPolarDeg(fromAngleDeg, pointerRadius);

        auto thumbPx = thumb.halfWidth - thumbPadding;
        auto thumbPy = thumb.halfHeight;

        auto rightVert = Vec2d(thumbPx + pointerPos.x, thumbPy + pointerPos.y);
        auto leftTopVert = Vec2d(thumbPx + pointerPos.x - pointerSize, thumbPy + pointerPos.y - pointerSize / 2);
        auto leftBottomVert = Vec2d(thumbPx + pointerPos.x - pointerSize, thumbPy + pointerPos.y + pointerSize / 2);

        graphics.fillTriangle(rightVert, leftTopVert, leftBottomVert, theme.colorAccent);

        thumb.resetRendererTarget;

        thumb.initialize;
        assert(thumb.isInitialized);
        thumb.create;
        assert(thumb.isCreated);

        return thumb;
    }

    override bool delegate(double, double) newOnThumbDragXY()
    {
        return (ddx, ddy) {
            immutable thumbBounds = thumb.boundsRect;
            immutable center = thumbBounds.center;

            immutable angleDeg = center.angleDeg360To(input.pointerPos);
            double da = 0;
            if (!isDragAngle)
            {
                isDragAngle = true;
                lastDragAngle = angleDeg;
                return false;
            }
            else
            {
                da = angleDeg - lastDragAngle;
                if (da == 0)
                {
                    return false;
                }
                lastDragAngle = angleDeg;
            }

            auto newAngle = thumb.angle + da;
            if (newAngle > fromAngleDeg && newAngle < toAngleDeg)
            {
                thumb.angle = newAngle;

                auto range = valueRange;
                auto angleRange = Math.abs(toAngleDeg - fromAngleDeg);
                //auto angleOffset = value * (angleRange / range);
                //auto newAngle = minAngleDeg + angleOffset;

                auto newValue = (range / angleRange) * newAngle;
                newValue = Math.clamp(newValue, minValue, maxValue);

                valueDelta = newValue - _value;
                _value = newValue;
                //TODO value = newValue
                triggerListeners(newValue);
            }

            return false;
        };
    }

    override protected double wheelValue(double wheelDt)
    {
        auto newValue = _value;
        if (wheelDt > 0)
        {
            newValue += valueStep;
        }
        else
        {
            newValue -= valueStep;
        }
        return newValue;
    }

    override bool value(double v, bool isTriggerListeners = true)
    {
        assert(thumb);

        if (!super.value(v, isTriggerListeners))
        {
            return false;
        }

        auto range = valueRange;
        auto angleRange = Math.abs(toAngleDeg - fromAngleDeg);
        auto angleOffset = v * (angleRange / range);
        auto newAngle = fromAngleDeg + angleOffset;
        //TODO <= fromAngle >= toAngle
        thumb.angle = newAngle;
        return true;
    }
}
