module api.dm.gui.controls.scrolls.radial_scroll;

import api.dm.gui.controls.scrolls.base_scroll : BaseScroll;
import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

import Math = api.math;
import api.math.vector2 : Vector2;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class RadialScroll : BaseScroll
{
    double fromAngle = 0;
    double toAngle = 90;

    this(double minValue = 0, double maxValue = 1.0, double width = 80, double height = 80)
    {
        super(minValue, maxValue);
        this.width = width;
        this.height = height;
        isDrawBounds = true;
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

        import api.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

        double radiusBase = Math.min(width, height);
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
                auto ppointerPos = Vector2.fromPolarDeg(fromAngle, pointRadius);
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
            if (newAngle > fromAngle && newAngle < toAngle)
            {
                thumb.angle = newAngle;
            }

            return false;
        };

    }
}
