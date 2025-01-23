module api.dm.addon.fractals.hopalongs.hopalong_generator;

import api.dm.addon.fractals.hopalongs.hopalong : Hopalong, HopalongType;

import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;
import api.dm.gui.controls.selects.choices.choice : Choice;
import api.math.random : Random;

import Math = api.math;
import api.math.geom2.vec2 : Vec2i;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.back.sdl2.sdl_surface : SdlSurface;

/**
 * Authors: initkfs
 */

class HopalongGenerator : Control
{
    RegulateTextField scaleField;

    RegulateTextField aCoeffField;
    RegulateTextField bCoeffField;
    RegulateTextField cCoeffField;
    RegulateTextField dCoeffField;

    Choice fractalType;

    Container canvas;
    double canvasWidth;
    double canvasHeight;

    Hopalong hopalong;

    Random rnd;

    protected
    {
        Vec2i[] points;
    }

    size_t colorVariations = 1000;

    this(double canvasWidth = 400, double canvasHeight = 400)
    {
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;

        rnd = new Random;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAlignY = true;
        layout.isAutoResize = true;
        isDrawBounds = true;

        hopalong = new Hopalong;
        points = new Vec2i[](hopalong.iterations);
    }

    HSVA color;

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated || isRunning)
        {
            return;
        }

        hopalong.generate;

        size_t windowStartPos;
        while (windowStartPos < points.length)
        {
            auto windowEndPos = windowStartPos + colorVariations;
            if (windowEndPos >= points.length)
            {
                windowEndPos = points.length;
            }
            auto slice = points[windowStartPos .. windowEndPos];

            auto newHue = (color.hue + 50) % color.maxHue;
            color.hue = newHue;

            graphics.points(slice, color.toRGBA);

            windowStartPos = windowEndPos;
        }

        //graphics.points(points);
    }

    override void create()
    {
        super.create;

        color.saturation = 0.98;
        color.value = 0.98;

        hopalong.onPostIterate = () {};

        hopalong.onIterXYIsContinue = (i, px, py) {
            auto newX = x + px + width / 2;
            auto newY = y + py + height / 2;

            import api.dm.com.graphics.com_blend_mode : ComBlendMode;

            // if(const err = screenSurface.lock){

            // }
            // auto rgba = color.toRGBA;
            // if(const err = screenSurface.setPixelRGBA(cast(int) newX, cast(int) newY, rgba.r, rgba.g, rgba.b, rgba.aByte)){

            // }

            // auto radius = 3;
            // graphics.changeBlendMode(ComBlendMode.blend);
            // scope(exit){
            //     graphics.restoreBlendMode;
            // }
            //graphics.circle(newX, newY, radius, color.toRGBA);
            points[i].x = cast(int) newX;
            points[i].y = cast(int) newY;
            //graphics.point(newX, newY, color.toRGBA);
            return true;
        };

        canvas = new Container;
        canvas.resize(canvasWidth, canvasHeight);
        addCreate(canvas);

        auto fieldRoot = new RegulateTextPanel(5);
        addCreate(fieldRoot);
        fieldRoot.paddingBottom = 600;
        fieldRoot.paddingLeft = 200;

        double minV = 0;
        double maxV = 1000;

        double minScale = 0.1;
        double maxScale = 25;

        scaleField = createRegField(fieldRoot, "Scale:", minScale, maxScale, (v) {
            hopalong.scale = v;
        });

        aCoeffField = createRegField(fieldRoot, "A:", minV, maxV, (v) {
            hopalong.a = v;
            hopalong.b = bCoeffField.scrollField.value;
            hopalong.c = cCoeffField.scrollField.value;
            hopalong.reset;
        });
        bCoeffField = createRegField(fieldRoot, "B:", minV, maxV, (v) {
            hopalong.a = aCoeffField.scrollField.value;
            hopalong.b = v;
            hopalong.c = cCoeffField.scrollField.value;
            hopalong.d = dCoeffField.scrollField.value;
            hopalong.reset;
        });
        cCoeffField = createRegField(fieldRoot, "C:", minV, maxV, (v) {
            hopalong.a = aCoeffField.scrollField.value;
            hopalong.b = bCoeffField.scrollField.value;
            hopalong.c = v;
            hopalong.d = dCoeffField.scrollField.value;
            hopalong.reset;
        });

        dCoeffField = createRegField(fieldRoot, "D:", minV, maxV, (v) {
            hopalong.a = aCoeffField.scrollField.value;
            hopalong.b = bCoeffField.scrollField.value;
            hopalong.c = cCoeffField.scrollField.value;
            hopalong.d = v;
            hopalong.reset;
        });

        fieldRoot.alignFields;

        fractalType = new Choice;
        fieldRoot.addCreate(fractalType);

        dstring[] types;
        import std.traits : EnumMembers;

        foreach (i, member; EnumMembers!HopalongType)
        {
            import std.conv: to;
            //TODO appender
            types ~= member.to!dstring;
        }
        fractalType.fill(types);

        fractalType.onChoice = (oldType, newType){
            if(oldType == newType){
                return;
            }
            import std.conv: to;
            hopalong.type = newType.to!HopalongType;
            hopalong.a = aCoeffField.scrollField.value;
            hopalong.b = bCoeffField.scrollField.value;
            hopalong.c = cCoeffField.scrollField.value;
            hopalong.d = dCoeffField.scrollField.value;
            hopalong.reset;
        };

        scaleField.value = 1;
        aCoeffField.value = 1;
        bCoeffField.value = 0;
        cCoeffField.value = 0;
        dCoeffField.value = 0;
    }

    protected RegulateTextField createRegField(Sprite2d root, dstring label = "Label", double minValue = 0, double maxValue = 1, void delegate(
            double) onScrollValue = null)
    {

        auto field = new RegulateTextField;
        root.addCreate(field);
        field.labelField.text = label;
        field.scrollField.minValue = minValue;
        field.scrollField.maxValue = maxValue;
        field.scrollField.onValue ~= onScrollValue;
        return field;
    }

}
