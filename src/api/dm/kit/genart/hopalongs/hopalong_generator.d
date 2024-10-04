module api.dm.kit.genart.hopalongs.hopalong_generator;

import api.dm.kit.genart.hopalongs.hopalong: Hopalong;

import api.dm.gui.controls.forms.fields.regulate_text_field: RegulateTextField;
import api.dm.gui.controls.forms.fields.regulate_text_panel: RegulateTextPanel;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite: Sprite;
import api.dm.gui.containers.container: Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.scrolls.hscroll: HScroll;
import api.dm.gui.controls.scrolls.vscroll: VScroll;
import api.math.random : Random;

import Math = api.math;
import api.math.vector2: Vector2i;
import api.dm.kit.graphics.colors.rgba: RGBA;
import api.dm.kit.graphics.colors.hsv: HSV;
import api.dm.back.sdl2.sdl_surface: SdlSurface;

/**
 * Authors: initkfs
 */

class HopalongGenerator : Control
{
    RegulateTextField scaleField;

    RegulateTextField aCoeffField;
    RegulateTextField bCoeffField;
    RegulateTextField cCoeffField;

    Container canvas;
    double canvasWidth;
    double canvasHeight;

    Hopalong hopalong;

    Random rnd;

    SdlSurface screenSurface;

    protected {
        Vector2i[] points;
    }

    this(double canvasWidth = 400, double canvasHeight = 400)
    {
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;

        rnd = new Random;

        import api.dm.kit.sprites.layouts.hlayout: HLayout;
        
        layout = new HLayout(5);
        layout.isAlignY = true;
        layout.isAutoResize = true;
        isDrawBounds = true;

        hopalong = new Hopalong;
        points = new Vector2i[](hopalong.iterations);
    }

    HSV color;

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated || isRunning)
        {
            return;
        }

        hopalong.generate;

        graphics.points(points);
    }

    override void create(){
        super.create;

        screenSurface = new SdlSurface;
        if(const err = screenSurface.createRGB(window.width, window.height)){
            throw new Exception(err.toString);
        }

        color.saturation = 0.8;
        color.value = 0.8;

        hopalong.onPostIterate = (){
            auto newHue = (color.hue + 5) % color.maxHue;
            color.hue = newHue;
        };

        hopalong.onIterXYIsContinue = (i, px, py){
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

        double minV = 0;
        double maxV = 500;

        double minScale = 0.1;
        double maxScale = 25;

        scaleField = createRegField(fieldRoot, "Scale:", minScale, maxScale, (v){
            hopalong.scale = v;
        });
        
        aCoeffField = createRegField(fieldRoot, "A:", minV, maxV, (v){
            hopalong.a = v;
        });
        bCoeffField = createRegField(fieldRoot, "B:", minV, maxV, (v){
            hopalong.b = v;
        });
        cCoeffField = createRegField(fieldRoot, "C:", minV, maxV, (v){
            hopalong.c = v;
        });

        fieldRoot.alignFields;

        scaleField.value = 1;
        aCoeffField.value = 1;
        bCoeffField.value = 0;
        cCoeffField.value = 0;
    }

    protected RegulateTextField createRegField(Sprite root, dstring label = "Label", double minValue = 0, double maxValue = 1, void delegate(double) onScrollValue = null){
        
        auto field = new RegulateTextField;
        root.addCreate(field);
        field.labelField.text = label;
        field.scrollField.minValue = minValue;
        field.scrollField.maxValue = maxValue;
        field.scrollField.onValue = onScrollValue;
        return field;
    }

    

}
