module api.dm.gui.controls.scrolls.radial_scroll;

import api.dm.gui.controls.scrolls.mono_scroll : MonoScroll;
import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

import api.dm.gui.controls.scales.radial_scale : RadialScale;

import Math = api.math;
import api.math.vector2 : Vector2;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class RadialScroll : MonoScroll
{
    double fromAngleDeg = 0;
    double toAngleDeg = 90;

    RadialScale scale;

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

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        scale = new RadialScale(width - 10, fromAngleDeg, toAngleDeg);
        //scale.tickOuterPadding *= 2;
        scale.labelOuterPadding *= 2;
        //scale.tickWidth = 2;
        //scale.tickMajorWidth = 2;
        scale.labelStep = 5;
        addCreate(scale);

        import api.dm.kit.sprites.textures.vectors.shapes.vhexagon : VHexagon;

        double radiusBase = Math.min(width, height);
        //TODO correct offset
        radiusBase -= 60;
        auto pointerRadius = radiusBase / 2 - 10;
        auto thumbStyle = createDefaultStyle;
        auto newThumb = new class VHexagon
        {
            this()
            {
                super(pointerRadius * 1.95, thumbStyle, 10);
            }

            override void createTextureContent()
            {
                super.createTextureContent;

                canvas.color(graphics.theme.colorAccent);

                auto pointRadius = pointerRadius - 5;
                canvas.moveTo(0, 0);
                canvas.translate(width / 2, height / 2);
                auto pos = Vector2.fromPolarDeg(fromAngleDeg, pointRadius);

                import api.math.vector2 : Vector2;

                auto shapeSize = 10;

                auto rightVert = Vector2(pos.x, pos.y);
                auto leftTopVert = Vector2(pos.x - shapeSize, pos.y - shapeSize / 2);
                auto leftBottomVert = Vector2(pos.x - shapeSize, pos.y + shapeSize / 2);

                canvas.moveTo(rightVert);
                canvas.lineTo(leftTopVert);
                canvas.lineTo(leftBottomVert);
                canvas.lineTo(rightVert);

                canvas.fill;
                canvas.stroke;
            }
        };

        thumb = newThumb;

        addCreate(newThumb);

        newThumb.bestScaleMode;

        newThumb.isDraggable = true;
        newThumb.onDragXY = (ddx, ddy) {

            immutable thumbBounds = thumb.bounds;
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
                if (onValue)
                {
                    onValue(newValue);
                }
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

    override bool value(double v)
    {
        assert(thumb);

        if (!super.value(v))
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
