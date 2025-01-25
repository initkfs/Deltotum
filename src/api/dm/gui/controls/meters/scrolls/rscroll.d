module api.dm.gui.controls.meters.scrolls.rscroll;

import api.dm.gui.controls.meters.scrolls.base_radial_mono_scroll : BaseRadialMonoScroll;
import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.controls.meters.scales.statics.rscale_static : RScaleStatic;

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

    RScaleStatic scale;

    bool isCreateScale = true;
    RScaleStatic delegate(RScaleStatic) onNewScale;
    void delegate(RScaleStatic) onConfiguredScale;
    void delegate(RScaleStatic) onCreatedScale;

    double thumbPadding = 10;

    this(double minValue = 0, double maxValue = 1.0, double width = 0, double height = 0)
    {
        super(minValue, maxValue);
        this._width = width;
        this._height = height;

        isBorder = false;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;
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

        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        if (auto shapeTexture = cast(Texture2d) thumb)
        {
            shapeTexture.bestScaleMode;
        }

        if (!scale && isCreateScale)
        {
            auto ns = newScale;
            scale = !onNewScale ? ns : onNewScale(ns);

            if (onConfiguredScale)
            {
                onConfiguredScale(scale);
            }

            addCreate(scale);

            if (onCreatedScale)
            {
                onCreatedScale(scale);
            }
        }
    }

    RScaleStatic newScale()
    {
        auto rscaleDiameter = thumbDiameter * 1.2 + Math.max(theme.meterTickMajorHeight, theme
                .meterTickMinorHeight);
        return new RScaleStatic(rscaleDiameter, fromAngleDeg, toAngleDeg);
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

        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
        import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto thumb = new Texture2d(thumbDiameter, thumbDiameter);
        build(thumb);

        thumb.isResizedByParent = false;

        thumb.createTargetRGBA32;
        thumb.blendModeBlend;
        thumb.bestScaleMode;

        if (auto shapeTexture = cast(Texture2d) thumbShape)
        {
            shapeTexture.blendModeBlend;
        }

        thumb.setRendererTarget;

        graphics.clear(RGBA.transparent);

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

        thumb.restoreRendererTarget;

        thumb.initialize;
        assert(thumb.isInitialized);
        thumb.create;
        assert(thumb.isCreated);

        thumb.onPointerPress ~= (ref e) {
            lastDragAngle = thumb.boundsRect.center.angleDeg360To(input.pointerPos);
        };

        return thumb;
    }

    override bool delegate(double, double) newOnThumbDragXY()
    {
        return (ddx, ddy) {

            immutable thumbBounds = thumb.boundsRect;
            immutable center = thumbBounds.center;

            immutable angleDeg = center.angleDeg360To(input.pointerPos);
            double da = angleDeg - lastDragAngle;

            lastDragAngle = angleDeg;

            auto newAngle = (thumb.angle + da) % 360;

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
