module api.dm.addon.vecfields.vec_field_gen;

import api.dm.addon.vecfields.vec_field : VecField;
import api.dm.kit.sprites.sprites2d.textures.vectors.vector_texture : VectorTexture;

import api.dm.gui.containers.container : Container;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;
import api.math.random : Random;

import api.dm.gui.controls.forms.fields.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.fields.regulate_text_field : RegulateTextField;

import Math = api.math;

/**
 * Authors: initkfs
 * https://tylerxhobbs.com/words/flow-fields
 * https://habr.com/ru/companies/skillfactory/articles/524656
 * https://habr.com/ru/companies/skillfactory/articles/575402
 */
class VecFieldGen : Container
{
    VecField vecField;
    VectorTexture canvas;

    double canvasWidth = 0;
    double canvasHeight = 0;

    Random rnd;

    bool isStartRender;

    this(double canvasWidth = 100, double canvasHeight = 100)
    {
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;

        import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        rnd = new Random;

        vecField = new VecField(canvasWidth, canvasHeight);
        vecField.create(x, y);

        canvas = new class VectorTexture
        {
            this()
            {
                super(canvasWidth, canvasHeight);
            }

            override void createTextureContent()
            {
                super.createTextureContent;

                if (!isStartRender)
                {
                    return;
                }

                auto ctx = canvas;

                ctx.color = RGBA.lightblue;

                ctx.color = RGBA.red;

                Vec2d[] points;
                foreach (newX; vecField.gridBounds.x .. vecField.gridBounds.right)
                {
                    points ~= Vec2d(newX, vecField.gridBounds.bottom - 250);
                }

                vecField.drawFlows(points, (p) {
                    ctx.moveTo(p);
                    ctx.color = RGBA.random(rnd);
                    return true;
                }, (p) { ctx.lineTo(p); return true; },

                    (p) { ctx.stroke; return true; });
            }
        };

        addCreate(canvas);
        //canvas.isDrawBounds = true;

        RegulateTextPanel controlPanel = new RegulateTextPanel;
        addCreate(controlPanel);

        auto stepsField = new RegulateTextField("Steps", 1, 100, (v) {
            vecField.steps = cast(size_t) v;
            canvas.recreate;
        });
        controlPanel.addCreate(stepsField);

        auto stepLengthField = new RegulateTextField("StepLength", 1, canvasWidth / 2, (
                v) { vecField.stepLength = v; canvas.recreate; });
        controlPanel.addCreate(stepLengthField);

        auto resolutionField = new RegulateTextField("Res", 1, canvasWidth, (v) {
            vecField.resolution = v;
            canvas.recreate;
        });
        controlPanel.addCreate(resolutionField);

        controlPanel.alignFields;
        stepsField.value = 30;
        stepsField.scrollField.valueStep = 1;
        stepLengthField.value = 20;
        stepLengthField.scrollField.valueStep = 1;
        resolutionField.value = 15;
    }

    override void drawContent()
    {
        super.drawContent;

        graphics.changeColor(RGBA.lightblue);
        scope (exit)
        {
            graphics.restoreColor;
        }

        vecField.drawGrid((p1, p2) {
            graphics.line(p1, p2);
            graphics.fillCircle(p1.x, p1.y, 2);
        });
    }
}
