module api.dm.gui.controls.meters.scales.statics.base_radial_scale_static;

import api.dm.gui.controls.meters.scales.statics.base_scale_static : BaseScaleStatic;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.line2 : Line2d;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
class BaseRadialScaleStatic : BaseScaleStatic
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    double _diameter = 0;

    Texture2d scaleShape;

    bool isUseTickProtos;

    bool isOuterLabel = true;

    dstring delegate(size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick) labelTextProvider;
    double delegate(double angledDeg, double radius) labelPosRadiusProvider;

    bool delegate(GraphicsContext ctx, Rect2d tickBounds, bool isMajorTick) onVTickIsContinue;

    protected
    {
        double radius = 0;
    }

    this(double diameter, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        this._diameter = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        isDrawAxis = false;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (_diameter == 0)
        {
            _diameter = theme.meterThumbDiameter * 2;
        }

        assert(_diameter);

        if (_width == 0)
        {
            _width = _diameter;
            //TODO label size
            if (isOuterLabel)
            {
                _width *= 1.2;
            }
        }

        if (_height == 0)
        {
            _height = _diameter;
            if (isOuterLabel)
            {
                _height *= 1.2;
            }
        }

        radius = _diameter / 2;
    }

    override void create()
    {
        if (isUseTickProtos || !capGraphics.isVectorGraphics)
        {

            super.create;

            scaleShape = new Texture2d(width, height);
            buildInitCreate(scaleShape);

            scaleShape.createTargetRGBA32;
            scaleShape.blendModeBlend;

            scaleShape.setRendererTarget;
            scope (exit)
            {
                scaleShape.restoreRendererTarget;
            }

            graphics.clearTransparent;

            drawScale;
        }
        else
        {
            isCreateMinorTickProto = false;
            isCreateMajorTickProto = false;
            isCreateLabelProto = true;

            super.create;

            const centerShapeW = width;
            const centerShapeH = height;

            import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

            auto tickShape = new class VectorTexture
            {
                this()
                {
                    super(centerShapeW, centerShapeH);
                }

                override void createTextureContent()
                {
                    auto currAngleDeg = minAngleDeg;

                    canvas.color(theme.colorAccent);
                    canvas.translate(width / 2, height / 2);
                    canvas.save;

                    double angleDegDiff = tickOffset;

                    drawScale(
                onDrawAxis : null,
                        (size_t i, Vec2d pos, bool isMajorTick, double offsetTick) {

                        auto tickW = tickMinorHeight;
                        auto tickH = tickMinorWidth;

                        if (isMajorTick)
                        {
                            canvas.color(theme.colorDanger);
                            tickW = tickMajorHeight;
                            tickH = tickMajorWidth;
                        }
                        else
                        {
                            canvas.color(theme.colorAccent);
                        }

                        canvas.rotateRad(Math.degToRad(currAngleDeg));
                        auto leftTopX = radius - tickW;
                        if (!isMajorTick)
                        {
                            leftTopX -= tickW / 2;
                        }
                        auto leftTopY = -tickH / 2;

                        if (onVTickIsContinue && !onVTickIsContinue(canvas, Rect2d(leftTopX, leftTopY, tickW, tickH), isMajorTick))
                        {

                            canvas.restore;

                            canvas.stroke;
                            canvas.save;

                            currAngleDeg = (currAngleDeg + angleDegDiff) % 360;

                            return false;
                        }

                        auto rightTopX = leftTopX + tickW;
                        auto rightTopY = leftTopY;

                        auto rightBottomX = rightTopX;
                        auto rightBottomY = rightTopY + tickH;

                        auto leftBottomX = leftTopX;
                        auto leftBottomY = rightBottomY;

                        canvas.beginPath;
                        canvas.moveTo(leftTopX, leftTopY);
                        canvas.lineTo(rightTopX, rightTopY);
                        canvas.lineTo(rightBottomX, rightBottomY);
                        canvas.lineTo(leftBottomX, leftBottomY);
                        canvas.lineTo(leftTopX, leftTopY);
                        canvas.closePath;
                        canvas.fill;

                        canvas.restore;

                        canvas.stroke;
                        canvas.save;

                        currAngleDeg = (currAngleDeg + angleDegDiff) % 360;
                        return true;
                    },
                onDrawLabel:
                        null,
                onTickStep:
                        null);
                }
            };

            scope (exit)
            {
                tickShape.dispose;
            }

            buildInitCreate(tickShape);

            scaleShape = new Texture2d(width, height);
            buildInitCreate(scaleShape);

            scaleShape.createTargetRGBA32;
            scaleShape.blendModeBlend;

            scaleShape.setRendererTarget;
            scope (exit)
            {
                scaleShape.restoreRendererTarget;
            }

            graphics.clearTransparent;

            scaleShape.copyFrom(tickShape);
            drawScale(
        onDrawAxis : null,
        onDrawTick:
                null,
                (size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick) {
                return drawLabel(labelIndex, tickIndex, pos, isMajorTick, offsetTick);
            },
                (size_t i, Vec2d pos, double offsetTick) {
                return tickStep(i, pos, offsetTick);
            });
        }

        addCreate(scaleShape);
    }

    override Line2d axisPos()
    {
        const bounds = boundsRect;
        const start = Vec2d(bounds.middleX, bounds.y);
        const end = Vec2d(bounds.middleX, bounds.bottom);
        return Line2d(start, end);
    }

    override Vec2d tickStartPos()
    {
        const bounds = boundsRect;
        return Vec2d.fromPolarDeg(minAngleDeg, radius).add(bounds.center);
    }

    override double tickOffset()
    {
        const angleRange = Math.abs(maxAngleDeg - minAngleDeg);
        const angleDegDiff = angleRange == 360 ? (angleRange / tickCount) : angleRange / (
            tickCount - 1);
        return angleDegDiff;
    }

    override Vec2d tickStep(size_t i, Vec2d pos, double offsetTick)
    {
        return scaleShape.boundsRect.center.add(Vec2d.fromPolarDeg((i + 1) * (tickOffset), radius));
    }

    override bool drawTick(size_t i, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        auto proto = isMajorTick ? majorTickProto : minorTickProto;

        if (!proto)
        {
            return false;
        }

        auto tickX = pos.x - proto.boundsRect.halfWidth;
        auto tickY = pos.y - proto.boundsRect.halfHeight;

        proto.xy = Vec2d(tickX, tickY);

        proto.angle = i * tickOffset;
        proto.angle = (proto.angle + 90) % 360;

        proto.draw;
        return true;
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2d pos, bool isMajorTick, double offsetTick)
    {
        if (!isMajorTick || !labelProto)
        {
            return false;
        }

        const center = scaleShape.boundsRect.center;

        import std.conv : to;

        auto labelText = labelTextProvider ? labelTextProvider(labelIndex, tickIndex, pos, isMajorTick, offsetTick) : (
            tickIndex * valueStep).to!dstring;

        labelProto.text = labelText;
        labelProto.updateRows(isForce : true);

        const tickBoundsW = majorTickProto ? majorTickProto.boundsRect.height : tickMajorHeight;
        const tickBoundsH = majorTickProto ? majorTickProto.boundsRect.width : tickMajorWidth;

        double angleDeg = tickIndex * offsetTick;

        double textPosRadius = isOuterLabel ? radius + Math.max(tickMinorHeight, tickMajorHeight) : radius - Math.max(tickMinorHeight, tickMajorHeight) * 1.5;

        auto textPos = Vec2d.fromPolarDeg(angleDeg, textPosRadius);

        double textX = 0;
        double textY = 0;

        auto truncAngle = Math.trunc(angleDeg);

        if (Math.nearAngleDeg(truncAngle, 90))
        {
            textX = center.x + textPos.x - labelProto.boundsRect.halfWidth + tickBoundsH / 2;
            if (isOuterLabel)
            {
                textY = center.y + textPos.y - labelProto.boundsRect.halfHeight + tickBoundsH / 2;
            }
            else
            {
                textY = center.y + textPos.y - labelProto.height / 2;
            }
        }
        else if (Math.nearAngleDeg(truncAngle, 270))
        {
            textX = center.x + textPos.x - labelProto.boundsRect.halfWidth + tickBoundsH / 2;
            textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;
        }
        else if ((truncAngle >= 0 && truncAngle < 90) || (truncAngle > 270 && truncAngle <= 360))
        {
            if (isOuterLabel)
            {
                textX = center.x + textPos.x;
                textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;
            }
            else
            {
                textX = center.x + textPos.x - labelProto.boundsRect.width;
                textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;
            }
        }
        else if (truncAngle > 90 && truncAngle <= 270)
        {
            if (isOuterLabel)
            {
                textX = center.x + textPos.x - labelProto.boundsRect.width;
                textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;
            }
            else
            {
                textX = center.x + textPos.x;
                textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;
            }
        }
        else
        {
            textX = center.x + textPos.x - labelProto.boundsRect.halfWidth;
            textY = center.y + textPos.y - labelProto.boundsRect.halfHeight;
        }

        double nextX = textX;

        labelProto.onFontTexture((fontTexture, const glyphPtr) {

            Rect2d textDest =
            {nextX, textY, glyphPtr.geometry.width, glyphPtr.geometry.height};

            scaleShape.copyFrom(fontTexture, glyphPtr.geometry, textDest);
            nextX += glyphPtr.geometry.width;
            return true;
        });
        return true;
    }

    double angleRange() => minAngleDeg < maxAngleDeg ? (maxAngleDeg - minAngleDeg) : (
        minAngleDeg - maxAngleDeg);
}
