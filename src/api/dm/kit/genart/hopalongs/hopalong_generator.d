module api.dm.kit.genart.hopalongs.hopalong_generator;

import api.dm.kit.genart.hopalongs.hopalong: Hopalong;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container: Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.scrolls.hscroll: HScroll;
import api.dm.gui.controls.scrolls.vscroll: VScroll;
import api.math.random : Random;

import Math = api.math;
import api.dm.kit.graphics.colors.rgba;

/**
 * Authors: initkfs
 */

class HopalongGenerator : Control
{
    Text aCoeff;
    Text bCoeff;
    Text cCoeff;

    HScroll aCoeffStep;
    HScroll bCoeffStep;
    HScroll cCoeffStep;
    HScroll scaleStep;

    Container canvas;
    double canvasWidth;
    double canvasHeight;

    Hopalong hopalong;

    Random rnd;

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
    }

    RGBA color = RGBA.lightblue;

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated || isRunning)
        {
            return;
        }

        hopalong.generate;
    }

    override void create(){
        super.create;

        hopalong.onPostIterate = (){
            color = RGBA.random(rnd);
        };

        hopalong.onIterXYIsContinue = (i, px, py){
            auto newX = x + px + width / 2;
            auto newY = y + py + height / 2;
            graphics.point(newX, newY, color);
            return true;
        };

        hopalong.a = 10;
        hopalong.b = 5;

        canvas = new Container;
        canvas.resize(canvasWidth, canvasHeight);
        addCreate(canvas);

        auto fieldRoot = new VBox;
        addCreate(fieldRoot);

        double minV = 0;
        double maxV = 50;

        aCoeffStep = new HScroll(minV, maxV);
        bCoeffStep = new HScroll(minV, maxV);
        cCoeffStep = new HScroll(minV, maxV);

        aCoeffStep.onValue = (v){
            hopalong.a = v;
        };

        bCoeffStep.onValue = (v){
            hopalong.b = v;
        };

        cCoeffStep.onValue = (v){
            hopalong.c = v;
        };

        scaleStep = new HScroll(0.1, 25);
        scaleStep.onValue = (v){
            hopalong.scale = v;
        };

        fieldRoot.addCreate([aCoeffStep, bCoeffStep, cCoeffStep, scaleStep]);

        aCoeffStep.value = hopalong.a;
        bCoeffStep.value = hopalong.b;
        cCoeffStep.value = hopalong.c;
        scaleStep.value = hopalong.scale;

        // aCoeff = new Text("0");
        // aCoeff.isReduceWidthHeight = false;
        // aCoeff.width = 100;
        // aCoeff.isEditable = true;
        // fieldRoot.addCreate(aCoeff);

        // bCoeff = new Text("0");
        // bCoeff.width = 100;
        // bCoeff.isReduceWidthHeight = false;
        // bCoeff.isEditable = true;
        // fieldRoot.addCreate(bCoeff);

        // cCoeff = new Text("0");
        // cCoeff.isReduceWidthHeight = false;
        // cCoeff.width = 100;
        // cCoeff.isEditable = true;
        // fieldRoot.addCreate(cCoeff);

        // import api.dm.gui.controls.buttons.button: Button;


        // auto updateBtn = new Button("Update");
        // fieldRoot.addCreate(updateBtn);

        // updateBtn.onAction = (ref e){
        //     import std.conv: to;
        //     a = aCoeff.text.to!double;
        //     b = bCoeff.text.to!double;
        //     c = cCoeff.text.to!double;
        // };

    }

    

}
