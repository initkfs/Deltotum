module deltotum.gui.supports.editors.sections.textures;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.geom.flip : Flip;

import Math = deltotum.math;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.shapes.rect2d : Rect2d;

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
        import deltotum.gui.containers.hbox : HBox;

        auto container1 = new HBox;
        addCreate(container1);
        container1.enableInsets;

        import deltotum.kit.sprites.textures.rgba_texture : RgbaTexture;

        class TestRgbaTexture : RgbaTexture
        {
            this(){
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

        super.create;
    }

    override bool draw()
    {
        return super.draw();
    }
}
