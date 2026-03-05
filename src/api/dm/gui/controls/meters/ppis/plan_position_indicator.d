module api.dm.gui.controls.meters.ppis.plan_position_indicator;

import api.dm.gui.controls.meters.min_max_meter : MinMaxMeter;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.math;

/**
 * Authors: initkfs
 */
class PlanPositionIndicator : MinMaxMeter!float
{
    VectorTexture scale;

    float maxDist = 1.0;

    GraphicStyle ringStyle;
    double fontSize = 10;

    bool isShowLabelDist = true;
    bool isShowLabelDeg = true;

    this(float diameter = 200, float minAngleDeg = 0, float maxAngleDeg = 360)
    {
        super(minAngleDeg, maxAngleDeg);
        const radius = diameter / 2;
        initSize(radius, radius);
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (ringStyle == GraphicStyle.init)
        {
            ringStyle = GraphicStyle(1, RGBA.hex("#00ff00"), true, RGBA.hex("#00ff00"));
        }
    }

    override void create()
    {
        super.create;

        const wv = width, hv = height;
        scale = new class VectorTexture
        {
            this()
            {
                super(wv, hv);
            }

            override void createContent()
            {
                auto ctx = canvas;

                const centerX = width / 2;
                const centerY = height / 2;
                const maxRadius = Math.min(width, height) / 2 - 15;

                ctx.color = ringStyle.lineColor;
                ctx.lineWidth = ringStyle.lineWidth;
                ctx.fontSize = fontSize;

                const numRings = 4;
                foreach (i; 0 .. numRings)
                {
                    const rangeValue = (i + 1) * (maxDist / numRings);
                    const radius = (rangeValue / maxDist) * maxRadius;

                    ctx.beginPath;
                    ctx.arc(centerX, centerY, radius, 0, Math.PI2);
                    ctx.stroke;

                    if (isShowLabelDist)
                    {
                        import std : format;

                        string label = format("%.1f", rangeValue);
                        const textBounds = ctx.textExtents(label);
                        ctx.fillText(label, centerX - textBounds.halfWidth, centerY - radius - textBounds
                                .halfHeight);
                    }

                }

                ctx.lineWidth = Math.max(ringStyle.lineWidth / 2, 1.0);

                auto innerRingColor = ringStyle.lineColor;
                innerRingColor.a *= 0.7;
                color = innerRingColor;
                const numRadials = 12; // Every 30 degs)
                foreach (i; 0 .. numRadials)
                {
                    const angle = (2 * Math.PI / numRadials) * i;
                    const x = centerX + Math.cos(angle) * maxRadius;
                    const y = centerY + Math.sin(angle) * maxRadius;

                    ctx.beginPath;
                    ctx.moveTo(centerX, centerY);
                    ctx.lineTo(x, y);
                    ctx.stroke;

                    if (isShowLabelDeg)
                    {
                        const labelRadius = maxRadius * 0.85;
                        const labelX = centerX + Math.cos(angle) * labelRadius;
                        const labelY = centerY + Math.sin(angle) * labelRadius;

                        int degrees = (i * 30) % 360;

                        import std.format : format;

                        string label;
                        if (degrees == 0)
                            label = "0"; //"360°" / "N"
                        else if (degrees == 90)
                            label = "90"; //  "E"
                        else if (degrees == 180)
                            label = "180"; //  "S"
                        else if (degrees == 270)
                            label = "270"; //  "W"
                        else
                            label = format("%d", degrees);

                        const extents = ctx.textExtents(label);

                        ctx.save;

                        color = ringStyle.lineColor;

                        if (degrees == 90 || degrees == 180)
                        {
                            ctx.fillText(label,
                                labelX - extents.width / 2,
                                labelY + extents.height / 2
                            );
                        }
                        else if (degrees == 270)
                        {
                            //TODO check overlap with distance label
                        }
                        else
                        {
                            ctx.translate(labelX, labelY);
                            float rotationAngle = angle;
                            if (degrees > 90 && degrees < 270)
                            {
                                rotationAngle = angle + Math.PI;
                            }

                            ctx.rotateRad(rotationAngle);

                            ctx.fillText(
                                label,
                                -extents.width / 2,
                                -extents.height / 2
                            );

                            ctx.restore;
                        }

                        color = innerRingColor;
                    }
                }

                color = ringStyle.lineColor;

                // ctx.fillText("N", centerX, centerY - maxRadius - 5);
                // ctx.fillText("S", centerX, centerY + maxRadius + 5);
                // ctx.fillText("E", centerX + maxRadius + 5, centerY);
                // ctx.fillText("W", centerX - maxRadius - 5, centerY);

                //Center point
                ctx.beginPath;
                ctx.arc(centerX, centerY, 3, 0, 2 * Math.PI);
                ctx.color = ringStyle.fillColor;
                ctx.fill;

                auto thinRingsColor = ringStyle.lineColor;
                thinRingsColor.a *= 0.5;
                ctx.color = thinRingsColor;

                //inner rings
                const thinRings = 8;
                foreach (i; 0 .. thinRings)
                {
                    const radius = (maxRadius / thinRings) * (i + 1);
                    ctx.beginPath;
                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                    ctx.stroke;
                }
            }
        };

        addCreate(scale);
    }

}
