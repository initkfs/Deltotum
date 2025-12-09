module api.dm.gui.supports.editors.sections.graphics;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.rect2 : Rect2f;
import api.math.pos2.flip : Flip;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Graphics : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_graphics";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    Control drawContainer;

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.hbox : HBox;

        auto shapeContainer = new HBox;
        addCreate(shapeContainer);

        import api.dm.kit.sprites2d.shapes.circle : Circle;

        auto circle = new Circle(20, GraphicStyle(1, RGBA.red));
        shapeContainer.addCreate(circle);

        auto circleFill = new Circle(20, GraphicStyle(1, RGBA.blue, true, RGBA.blue));
        shapeContainer.addCreate(circleFill);

        import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;

        auto rect = new Rectangle(50, 50, GraphicStyle(1, RGBA.yellow));
        shapeContainer.addCreate(rect);

        auto rectFill = new Rectangle(50, 50, GraphicStyle(1, RGBA.green, true, RGBA.green));
        shapeContainer.addCreate(rectFill);

        import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

        auto reg = new ConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightcoral), 10);
        shapeContainer.addCreate(reg);

        auto regFill = new ConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightsteelblue, true, RGBA
                .lightsteelblue), 10);
        shapeContainer.addCreate(regFill);

        auto container1 = new HBox;
        addCreate(container1);
        container1.enablePadding;

        import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;

        class TestRgbaTexture : RgbaTexture
        {
            this()
            {
                super(50, 50);
            }

            override void createTextureContent()
            {
                this.graphic.fillRect(0, 0, 25, 25, RGBA.red);
                this.graphic.fillRect(25, 0, 25, 25, RGBA.yellow);
                this.graphic.fillRect(0, 25, 25, 25, RGBA.green);
                this.graphic.fillRect(25, 25, 25, 25, RGBA.blue);
            }
        }

        class TestDrawLeftUpperRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2f textureBounds = {0, 0, 25, 25};
                Rect2f destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        class TestDrawRightUpperRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2f textureBounds = {25, 0, 25, 25};
                Rect2f destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        class TestDrawLeftBottomRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2f textureBounds = {0, 25, 25, 25};
                Rect2f destBounds = {this.x, this.y, this.width, this.height};
                drawTexture(texture, textureBounds, destBounds, this.angle);
            }
        }

        class TestDrawRightBottomRect : TestRgbaTexture
        {
            override void drawContent()
            {
                Rect2f textureBounds = {25, 25, 25, 25};
                Rect2f destBounds = {this.x, this.y, this.width, this.height};
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

        auto vContainer = new HBox(5);
        addCreate(vContainer);

        if (platform.cap.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

            auto style = GraphicStyle(3.0, RGBA.red, true, RGBA.green);

            enum size = 50;

            auto vCircle = new VCircle(size / 2, style);
            vContainer.addCreate(vCircle);

            import api.dm.kit.sprites2d.textures.vectors.shapes.vtriangle : VTriangle;

            auto vTrig = new VTriangle(size, size, style);
            vContainer.addCreate(vTrig);

            import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            auto vReg = new VConvexPolygon(size, size, style, 10);
            vContainer.addCreate(vReg);

            import api.dm.kit.sprites2d.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            auto vHex = new VRegularPolygon(size, style);
            vContainer.addCreate(vHex);

            import api.dm.kit.sprites2d.textures.vectors.shapes.vregular_polygon_grid : VRegularPolygonGrid;

            auto vHexGrid = new VRegularPolygonGrid(250, 250, 35, style);
            vContainer.addCreate(vHexGrid);

        }

        drawContainer = new Control;
        drawContainer.resize(window.width, 100);
        addCreate(drawContainer);
    }

    override bool draw()
    {
        super.draw();

        if (!drawContainer)
        {
            return false;
        }

        const bounds = drawContainer.boundsRect;
        
        float startX = bounds.x;
        float startY = bounds.y;

        graphic.line(startX, startY, startX + 100, startY, RGBA.lightblue);

        graphic.changeColor(RGBA.pink);
        startY += 10;
        graphic.line(startX, startY, startX + 100, startY);
        graphic.restoreColor;

        startY += 10;
        graphic.changeColor(RGBA.lightblue);
        foreach (i; 0 .. 10)
        {
            graphic.point(startX + i * 5, startY);
        }

        // graphic.linePoints(Vec2f(220, 120), Vec2f(250, 120), (p) {
        //     graphic.point(p);
        //     return true;
        // });

        // graphic.circlePoints(Vec2f(235, 150), 10, (p) {
        //     graphic.point(p);
        //     return true;
        // });

        // graphic.restoreColor;

        // graphic.fillTriangle(Vec2f(300, 100), Vec2f(325, 150), Vec2f(350, 100), RGBA
        //         .yellowgreen);
        // graphic.fillTriangle(Vec2f(360, 150), Vec2f(410, 150), Vec2f(385, 100), RGBA
        //         .yellowgreen);
        // graphic.fillTriangle(Vec2f(420, 150), Vec2f(450, 100), Vec2f(430, 200), RGBA
        //         .yellowgreen);

        // graphic.fillRect(480, 100, 50, 20, RGBA.lightsalmon);
        // graphic.rect(480, 130, 50, 20, RGBA.lightcoral);

        // graphic.changeColor(RGBA.lightskyblue);

        // graphic.bezier(Vec2f(550, 150), Vec2f(510, 150), Vec2f(580, 100));

        // graphic.ellipse(Vec2f(650, 100), Vec2f(40, 20), RGBA.lightseagreen, true, false);
        // graphic.ellipse(Vec2f(650, 150), Vec2f(40, 20), RGBA.lightseagreen, false, true);

        // import api.dm.com.graphics.com_blend_mode : ComBlendMode;

        // graphic.fillRect(750, 100, 50, 50, RGBA.lightpink);
        // auto color2 = RGBA.lightcoral;
        // color2.a = 0.5;
        // graphic.fillRect(775, 100, 50, 50, color2);

        // auto points = [
        //     Vec2f(20, 200),
        //     Vec2f(75, 240),
        //     Vec2f(50, 270),
        //     Vec2f(40, 260),
        //     Vec2f(10, 270),
        // ];
        // graphic.polygon(points);

        // graphic.restoreColor;

        // graphic.point(150, 200);
        // graphic.arc(150, 200, 0, 90, 50);

        return true;
    }
}
