module api.dm.gui.controls.meters.hands.meter_hand_factory;

import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

private
{
    import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
    import api.math.geom2.vec2 : Vec2d;
    import Math = api.math;

    class VHand : VShape
    {
        double handWidth = 0;
        double handHeight = 0;
        double coneHeight = 0;

        Vec2d startPoint;

        this(double textureWidth, double textureHeight, double handWidth, double handHeight, double coneHeight = 0, GraphicStyle style)
        {
            super(textureWidth, textureHeight, style);

            assert(handWidth <= width);
            assert(handHeight <= height);
            
            this.handWidth = handWidth;
            this.handHeight = handHeight;

            startPoint = Vec2d(width / 2, height / 2);
            this.coneHeight = coneHeight;
        }

        override void create()
        {
            super.create;
            import api.dm.com.graphics.com_texture : ComTextureScaleMode;

            textureScaleMode = ComTextureScaleMode.quality;
        }

        override void createTextureContent()
        {
            super.createTextureContent;
            auto ctx = canvas;

            ctx.lineWidth(style.lineWidth);

            const halfWidth = handWidth / 2;

            const centerX = startPoint.x;
            const centerY = startPoint.y;

            ctx.moveTo(centerX - halfWidth, centerY - handHeight + coneHeight);
            ctx.lineTo(centerX, centerY - handHeight + style.lineWidth);
            ctx.lineTo(centerX + halfWidth, centerY - handHeight + coneHeight);
            ctx.lineTo(centerX + halfWidth, centerY);
            ctx.lineTo(centerX - halfWidth, centerY);
            ctx.lineTo(centerX - halfWidth, centerY - handHeight + coneHeight);

            if (style.isFill)
            {
                ctx.color = style.fillColor;
                ctx.fillPreserve;
            }

            ctx.color(style.lineColor);
            ctx.stroke;
        }
    }
}

/**
 * Authors: initkfs
 */
class MeterHandFactory : Control
{
    double coneHeight = 0;

    Sprite2d createHand(double width, double height, double handWidth = 0, GraphicStyle handStyle = GraphicStyle
            .simpleFill)
    {
        double handW = handWidth;

        if (handW == 0)
        {
            handW = theme.meterHandWidth;
            assert(handW > 0);
        }

        double handH = height / 2;

        Sprite2d hand;

        if (capGraphics.isVectorGraphics)
        {
            double newConeHeight = coneHeight == 0 ? handW * 2 : coneHeight;
            
            auto newHand = new VHand(width, height, handW, handH, newConeHeight, handStyle);
            hand = newHand;
            buildInitCreate(hand);
            newHand.bestScaleMode;
        }
        else
        {
            auto newHand = new Texture2d(width, height);
            buildInitCreate(newHand);

            hand = newHand;

            newHand.createTargetRGBA32;
            newHand.blendModeBlend;
            newHand.bestScaleMode;

            newHand.setRendererTarget;
            scope (exit)
            {
                newHand.restoreRendererTarget;
            }

            const center = newHand.boundsRect.center;

            graphics.clearTransparent;
            graphics.fillRect(center.x - handW / 2, center.y - handH, handW, handH, handStyle
                    .fillColor);
        }
        
        return hand;
    }

}
