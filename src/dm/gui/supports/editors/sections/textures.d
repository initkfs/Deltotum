module dm.gui.supports.editors.sections.textures;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.math.flip : Flip;

import Math = dm.math;
import dm.math.vector2 : Vector2;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.rect2d : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Textures : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_textures";
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import dm.gui.containers.vbox : VBox;
        import dm.gui.containers.hbox : HBox;

        auto root = new VBox;
        addCreate(root);
        root.enableInsets;

        auto container1 = new HBox;
        root.addCreate(container1);
        container1.enableInsets;

        import dm.kit.sprites.textures.rgba_texture : RgbaTexture;

        class TestRgbaTexture : RgbaTexture
        {
            this()
            {
                super(50, 50);
            }

            override void createTextureContent()
            {
                this.graphics.fillRect(0, 0, 25, 25, RGBA.red);
                this.graphics.fillRect(25, 0, 25, 25, RGBA.yellow);
                this.graphics.fillRect(0, 25, 25, 25, RGBA.green);
                this.graphics.fillRect(25, 25, 25, 25, RGBA.blue);
            }
        }

        class TestDrawLeftUpperRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2d textureBounds = {0, 0, 25, 25};
                Rect2d destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        class TestDrawRightUpperRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2d textureBounds = {25, 0, 25, 25};
                Rect2d destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        class TestDrawLeftBottomRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2d textureBounds = {0, 25, 25, 25};
                Rect2d destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        class TestDrawRightBottomRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2d textureBounds = {25, 25, 25, 25};
                Rect2d destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        auto rgbaText1 = new TestRgbaTexture;
        container1.addCreate(rgbaText1);

        auto rgbaText1Copy = rgbaText1.copy;
        container1.add(rgbaText1Copy);
        rgbaText1Copy.opacity = 0.5;

        auto rgbaText1CopyFlip = rgbaText1.copy;
        container1.add(rgbaText1CopyFlip);
        rgbaText1CopyFlip.flip = Flip.horizontal;

        auto leftUpperRect = new TestDrawLeftUpperRect;
        container1.addCreate(leftUpperRect);
        auto rightUpperRect = new TestDrawRightUpperRect;
        container1.addCreate(rightUpperRect);
        auto leftBottomRect = new TestDrawLeftBottomRect;
        container1.addCreate(leftBottomRect);
        auto rightBottomRect = new TestDrawRightBottomRect;
        container1.addCreate(rightBottomRect);

        auto vContainer = new HBox;
        root.addCreate(vContainer);

        if(capGraphics.isVectorGraphics){
            import dm.kit.sprites.textures.vectors.vcircle: VCircle;

            auto vCircle = new VCircle(25, GraphicStyle(3.0, RGBA.red, true, RGBA.green));
            vContainer.addCreate(vCircle);
        }

    }

    override bool draw()
    {
        return super.draw();
    }
}
