module api.dm.gui.controls.scrolls.radial_scroll;

import api.dm.gui.controls.scrolls.base_scroll : BaseScroll;
import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

import api.dm.gui.controls.scales.radial_scale : RadialScale;

import Math = api.math;
import api.math.vector2 : Vector2;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class RadialScroll : BaseScroll
{
    double fromAngleDeg = 0;
    double toAngleDeg = 90;

    RadialScale scale;

    this(double minValue = 0, double maxValue = 1.0, double width = 100, double height = 100)
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
        scale.tickOuterPadding *= 2;
        scale.labelOuterPadding *= 2;
        scale.tickWidth = 1;
        scale.tickMajorWidth = 1;
        scale.labelStep = 0;
        addCreate(scale);

        import api.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

        double radiusBase = Math.min(width, height);
        //TODO correct offset
        radiusBase -= 40;
        auto pointerRadius = radiusBase / 2 - 10;
        auto thumbStyle = createDefaultStyle;
        auto newThumb = new class VCircle
        {
            this()
            {
                super(pointerRadius, thumbStyle);
            }

            override void createTextureContent()
            {
                super.createTextureContent;

                gContext.setColor(graphics.theme.colorAccent);

                auto pointRadius = pointerRadius - 10;
                gContext.translate(0, 0);
                auto ppointerPos = Vector2.fromPolarDeg(fromAngleDeg, pointRadius);
                gContext.arc(ppointerPos.x, ppointerPos.y, 4, 0, Math.PI2);
                gContext.fill;
                gContext.stroke;
            }
        };

        thumb = newThumb;

        addCreate(newThumb);

        newThumb.bestScaleMode;

        newThumb.isDraggable = true;
        newThumb.onDragXY = (ddx, ddy) {

            immutable thumbBounds = thumb.bounds;
            immutable center = thumbBounds.center;

            immutable angleDeg = center.angleDeg360To(input.mousePos);
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
                if(onValue){
                    onValue(newValue);
                }
            }

            return false;
        };
    }

    override void value(double v){
        assert(thumb);

        super.value(v);

        auto range = valueRange;
        auto angleRange = Math.abs(toAngleDeg - fromAngleDeg);
        auto angleOffset = v * (angleRange / range);
        auto newAngle = fromAngleDeg + angleOffset;
        thumb.angle = newAngle;
    }
}
