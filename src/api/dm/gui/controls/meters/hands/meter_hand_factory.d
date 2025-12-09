module api.dm.gui.controls.meters.hands.meter_hand_factory;

import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import Math = api.math;

private
{
    import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
    import api.math.geom2.vec2 : Vec2d;

    class VHand : VShape
    {
        float handWidth = 0;
        float handHeight = 0;
        float coneHeight = 0;
        float coneWidth = 0;

        Vec2d startPoint;

        this(float textureWidth, float textureHeight, float handWidth, float handHeight, float coneWidth = 0, float coneHeight = 0, GraphicStyle style)
        {
            super(textureWidth, textureHeight, style);

            assert(handWidth <= width);
            assert(handHeight <= height);

            this.handWidth = handWidth;
            this.handHeight = handHeight;

            startPoint = Vec2d(width / 2, height / 2);
            this.coneWidth = coneWidth;
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

            const halfConeWidth = coneWidth > 0 ? coneWidth / 2 : 0;

            ctx.moveTo(centerX - halfWidth, centerY);

            float startConeLeftX = halfConeWidth > 0 ? (centerX - halfConeWidth) : (
                centerX - halfWidth);
            ctx.lineTo(startConeLeftX, centerY - handHeight + coneHeight);
            ctx.lineTo(centerX, centerY - handHeight + style.lineWidth);

            float startConeRightX = halfConeWidth > 0 ? (centerX + halfConeWidth) : (
                centerX + halfWidth);

            ctx.lineTo(startConeRightX, centerY - handHeight + coneHeight);

            ctx.lineTo(centerX + halfWidth, centerY);
            ctx.lineTo(centerX - halfWidth, centerY);

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
    //TODO rename to createHalfHand (from center)
    Sprite2d createHand(float handWidth = 0, float handHeight = 0, GraphicStyle handStyle = GraphicStyle
            .simpleFill, float coneWidth = 0, float coneHeight = 0)
    {
        assert(handWidth > 0);
        assert(handHeight > 0);
        assert(coneWidth >= 0);
        assert(coneHeight >= 0);

        float width = handWidth;
        float height = handHeight;

        auto maxWidth = Math.max(handWidth, coneWidth);
        auto coneWdt = width - maxWidth;
        if (coneWdt < 0)
        {
            width += (-coneWdt);
        }

        //draw from center
        height *= 2;

        import api.math.geom2.rect2 : Rect2d;

        auto handBox = Rect2d(0, 0, width, height).boundingBoxMax;

        auto newWidth = Math.roundEven(handBox.width);
        auto newHeight = Math.roundEven(handBox.height);

        handWidth = Math.roundEven(handWidth);

        Sprite2d hand;

        if (platform.cap.isVectorGraphics)
        {
            auto newHand = new VHand(newWidth, newHeight , handWidth, handHeight, coneWidth, coneHeight, handStyle);
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

            graphic.clearTransparent;
            graphic.fillRect(center.x - handWidth / 2, center.y - handHeight, handWidth, handHeight, handStyle
                    .fillColor);
        }

        return hand;
    }

}
