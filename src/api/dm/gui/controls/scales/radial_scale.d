module api.dm.gui.controls.scales.radial_scale;

import api.dm.gui.controls.control : Control;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import Math = api.math;

import std.conv: to;

/**
 * Authors: initkfs
 */
class RadialScale : Control
{
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    double minValue = 0;
    double maxValue = 1;
    double valueStep = 0.05;
    size_t majorTickStep = 5;
    size_t labelStep = 5;
    
    bool isShowFirstLastLabel = true;

    double _diameter = 0;

    size_t tickWidth = 8;
    size_t tickHeight = 2;
    size_t tickMajorWidth = 10;
    size_t tickMajorHeight = 2;

    size_t tickOuterPadding = 20;
    size_t labelOuterPadding = 5;

    this(double diameter = 50, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        this._diameter = diameter;
        assert(_diameter > 0);

        this._width = diameter;
        this._height = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
    }

    override void create()
    {
        super.create;

        import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
        import api.dm.kit.sprites.textures.rgba_texture : RgbaTexture;
        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        size_t ticksCount = ((Math.abs(maxValue - minValue)) / valueStep).to!size_t;

        const centerShapeW = width;
        const centerShapeH = height;

        import api.dm.kit.sprites.textures.vectors.vector_texture: VectorTexture;

        auto centerShapeProto = new class VectorTexture
        {
            this()
            {
                super(centerShapeW, centerShapeH);
            }

            override void createTextureContent()
            {
                auto radius = _diameter / 2;

                auto valueRange = maxValue - minValue;
                assert(valueRange > 0);

                auto startAngleDeg = minAngleDeg;
                auto endAngleDeg = maxAngleDeg;

                double angleRange = Math.abs(startAngleDeg - endAngleDeg);

                size_t ticksCount = (valueRange / valueStep).to!size_t;
                assert(ticksCount >= 2);

                if (minValue == 0)
                {
                    ticksCount++;
                }

                import api.dm.kit.graphics.colors.rgba: RGBA;

                canvas.color(theme.colorAccent);
                canvas.translate(width / 2 - tickWidth / 2, height / 2 - tickHeight / 2);
                canvas.save;

                double angleDegDiff = angleRange / (ticksCount);
                size_t endIndex = ticksCount - 1;
                assert(endIndex < ticksCount);
                foreach (i; 0 .. ticksCount)
                {
                    auto tickW = tickWidth;
                    auto tickH = tickHeight;

                    bool isMajorTick = (majorTickStep > 0 && ((i % majorTickStep) == 0));

                    if(isMajorTick){
                        canvas.color(theme.colorDanger);
                        tickW = tickMajorWidth;
                        tickH = tickMajorHeight;
                    }else {
                        canvas.color(theme.colorAccent);
                    }

                    canvas.rotateRad(Math.degToRad(startAngleDeg));
                    auto leftTopX = width / 2 - tickW - tickOuterPadding;
                    auto leftTopY = 0;
                    
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

                    // if(i == 0){
                    //     break;
                    // }
                    

                    startAngleDeg = (startAngleDeg + angleDegDiff) % 360;
                }
            }
        };

        scope(exit){
            centerShapeProto.dispose;
        }

        buildInitCreate(centerShapeProto);

        import api.dm.gui.controls.texts.text : Text;
        import api.dm.kit.assets.fonts.font_size : FontSize;
        import api.dm.kit.sprites.textures.texture : Texture;

        import std.conv: to;

        auto labelProto = new Text("!");
        build(labelProto);
        labelProto.fontSize = FontSize.small;
        labelProto.initialize;
        labelProto.create;

        scope(exit){
            labelProto.dispose;
        }

        auto centerShape = new class RgbaTexture
        {
            this()
            {
                super(centerShapeW, centerShapeH);
            }

            override void createTextureContent()
            {
                auto radius = _diameter / 2;

                auto valueRange = maxValue - minValue;
                assert(valueRange > 0);

                auto startAngleDeg = minAngleDeg;
                auto endAngleDeg = maxAngleDeg;

                double angleRange = Math.abs(startAngleDeg - endAngleDeg);

                size_t ticksCount = (valueRange / valueStep).to!size_t;
                assert(ticksCount >= 2);

                if (minValue == 0)
                {
                    ticksCount++;
                }

                double angleDegDiff = angleRange / (ticksCount - 1);
                size_t endIndex = ticksCount - 1;
                assert(endIndex < ticksCount);
                foreach (i; 0 .. ticksCount)
                {
                    auto pos = Vec2d.fromPolarDeg(startAngleDeg, radius - tickOuterPadding);

                    if ((isShowFirstLastLabel && (i == 0 || i == endIndex)) || (labelStep > 0 &&(i % labelStep == 0)))
                    {
                        auto textPos = Vec2d.fromPolarDeg(startAngleDeg, radius - labelOuterPadding);

                        auto labelText = (i * valueStep).to!dstring;
                        labelProto.text = labelText;
                        labelProto.updateRows(isForce : true);

                        auto textX = radius + textPos.x - labelProto.rowGlyphWidth / 2;
                        auto textY = radius + textPos.y - labelProto.rowGlyphHeight / 2;

                        double nextX = textX;

                        labelProto.onFontTexture((fontTexture, const glyphPtr) {

                            Rect2d textDest =
                            {
                                nextX, textY, glyphPtr.geometry.width, glyphPtr.geometry.height
                            };

                            copyFrom(fontTexture, glyphPtr.geometry, textDest);
                            nextX += glyphPtr.geometry.width;
                            return true;
                        });
                    }

                    startAngleDeg = (startAngleDeg + angleDegDiff) % 360;
                }
            }
        };

        addCreate(centerShape);

        centerShape.copyFrom(centerShapeProto);
    }
}
