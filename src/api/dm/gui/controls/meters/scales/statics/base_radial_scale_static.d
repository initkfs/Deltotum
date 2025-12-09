module api.dm.gui.controls.meters.scales.statics.base_radial_scale_static;

import api.dm.gui.controls.meters.scales.statics.base_scale_static : BaseScaleStatic;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;
import api.math.geom2.vec2 : Vec2f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.line2 : Line2f;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
class BaseRadialScaleStatic : BaseScaleStatic
{
    float minAngleDeg = 0;
    float maxAngleDeg = 0;

    float _diameter = 0;

    Texture2d scaleShape;

    bool isUseTickProtos;

    bool isOuterLabel = true;

    dstring delegate(size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick) labelTextProvider;
    float delegate(float angledDeg, float radius) labelPosRadiusProvider;

    bool delegate(GraphicCanvas ctx, Rect2f tickBounds, bool isMajorTick) onVTickIsContinue;

    protected
    {
        float radius = 0;
    }

    this(float diameter, float minAngleDeg = 0, float maxAngleDeg = 360)
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

        if (width == 0)
        {
            auto newWidth = _diameter;
            //TODO label size
            if (isOuterLabel)
            {
                newWidth += asset.rem.x * 5;
            }

            initWidth(newWidth);
        }

        if (height == 0)
        {
            auto newHeight = _diameter;
            if (isOuterLabel)
            {
                newHeight += asset.rem.y * 2;
            }

            initHeight(newHeight);
        }

        radius = _diameter / 2;
    }

    override void create()
    {
        if (isUseTickProtos || !platform.cap.isVectorGraphics)
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

            graphic.clearTransparent;

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

                    float angleDegDiff = tickOffset;

                    drawScale(
                onDrawAxis : null,
                        (size_t i, Vec2f pos, bool isMajorTick, float offsetTick) {

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

                        if (onVTickIsContinue && !onVTickIsContinue(canvas, Rect2f(leftTopX, leftTopY, tickW, tickH), isMajorTick))
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

            graphic.clearTransparent;

            scaleShape.copyFrom(tickShape);
            drawScale(
        onDrawAxis : null,
        onDrawTick:
                null,
                (size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick) {
                return drawLabel(labelIndex, tickIndex, pos, isMajorTick, offsetTick);
            },
                (size_t i, Vec2f pos, float offsetTick) {
                return tickStep(i, pos, offsetTick);
            });
        }

        addCreate(scaleShape);
    }

    override Line2f axisPos()
    {
        const bounds = boundsRect;
        const start = Vec2f(bounds.middleX, bounds.y);
        const end = Vec2f(bounds.middleX, bounds.bottom);
        return Line2f(start, end);
    }

    override Vec2f tickStartPos()
    {
        const bounds = boundsRect;
        return Vec2f.fromPolarDeg(minAngleDeg, radius).add(bounds.center);
    }

    override float tickOffset()
    {
        const angleRange = Math.abs(maxAngleDeg - minAngleDeg);
        const angleDegDiff = angleRange == 360 ? (angleRange / tickCount) : angleRange / (
            tickCount - 1);
        return angleDegDiff;
    }

    override Vec2f tickStep(size_t i, Vec2f pos, float offsetTick)
    {
        return scaleShape.boundsRect.center.add(Vec2f.fromPolarDeg((i + 1) * (tickOffset), radius));
    }

    override bool drawTick(size_t i, Vec2f pos, bool isMajorTick, float offsetTick)
    {
        auto proto = isMajorTick ? majorTickProto : minorTickProto;

        if (!proto)
        {
            return false;
        }

        auto tickX = pos.x - proto.boundsRect.halfWidth;
        auto tickY = pos.y - proto.boundsRect.halfHeight;

        proto.xy = Vec2f(tickX, tickY);

        proto.angle = i * tickOffset;
        proto.angle = (proto.angle + 90) % 360;

        proto.draw;
        return true;
    }

    override bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick)
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

        float angleDeg = tickIndex * offsetTick;

        float textPosRadius = isOuterLabel ? radius + Math.max(tickMinorHeight, tickMajorHeight) / 2 : radius - Math.max(
            tickMinorHeight, tickMajorHeight) * 1.5;

        auto textPos = Vec2f.fromPolarDeg(angleDeg, textPosRadius);

        float textX = 0;
        float textY = 0;

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

        float nextX = textX;

        labelProto.onFontTexture((fontTexture, const glyphPtr) {

            Rect2f textDest =
            {nextX, textY, glyphPtr.geometry.width, glyphPtr.geometry.height};

            scaleShape.copyFrom(fontTexture, glyphPtr.geometry, textDest);
            nextX += glyphPtr.geometry.width;
            return true;
        });
        return true;
    }

    float angleRange() => minAngleDeg < maxAngleDeg ? (maxAngleDeg - minAngleDeg) : (
        minAngleDeg - maxAngleDeg);
}
