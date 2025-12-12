module api.dm.addon.procedural.vecfields.vec_field_gen;

import api.dm.addon.procedural.vecfields.vec_field : VecField;
import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;
import api.math.random : Random, rands;

import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

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

    float canvasWidth = 0;
    float canvasHeight = 0;

    Random rnd;

    this(float canvasWidth = 200, float canvasHeight = 200)
    {
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        rnd = rands;

        vecField = new VecField(canvasWidth, canvasHeight);
        vecField.create(0, 0);

        canvas = new class VectorTexture
        {
            this()
            {
                super(canvasWidth, canvasHeight);
            }

            override void createTextureContent()
            {
                super.createTextureContent;

                auto ctx = canvas;
                //ctx.translate(canvasWidth / 2, canvasHeight / 2);

                ctx.color = RGBA.lightblue;

                Vec2f[] points;
                foreach (newX; vecField.gridBounds.x .. vecField.gridBounds.right)
                {
                    points ~= Vec2f(newX, vecField.gridBounds.bottom);
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
        canvas.isDrawBounds = true;

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

        graphic.color(RGBA.lightblue);
        scope (exit)
        {
            graphic.restoreColor;
        }

        vecField.drawGrid((p1, p2) {

            assert(canvas);
            const pos = canvas.boundsRect.center;

            auto cp1 = pos.add(p1);
            auto cp2 = pos.add(p2);

            graphic.line(cp1, cp2);
            graphic.fillCircle(cp1.x, cp1.y, 2);
        });
    }
}
