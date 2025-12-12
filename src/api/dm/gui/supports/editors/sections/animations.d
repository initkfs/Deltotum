module api.dm.gui.supports.editors.sections.animations;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.dm.math;
import api.math.geom2.vec2 : Vec2f;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.kit.sprites2d.tweens.curves.uni_interpolator : UniInterpolator;
import api.dm.kit.sprites2d.tweens.targets.motions.linear_motion : LinearMotion;
import api.dm.kit.sprites2d.tweens.targets.value_tween : ValueTween;
import api.dm.kit.sprites2d.tweens.targets.props.angle_tween : AngleTween;

import std.stdio;
import std.conv : to;

/**
 * Authors: initkfs
 */
class Animations : Control
{
    private
    {
        float function(float)[dstring] animationsMap;
        UniInterpolator interpolator;

        LinearMotion motionTween;
        AngleTween angleTween;
    }

    this()
    {
        id = "deltotum_gui_editor_section_animations";
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        interpolator = new UniInterpolator;

        import std.traits: ReturnType;

        static foreach (m; __traits(derivedMembers, UniInterpolator))
        {
            {
                alias func = __traits(getMember, interpolator, m);
                //TODO best filter
                static if (__traits(isStaticFunction, func) && is(ReturnType!func : float))
                {
                    const funcName = __traits(identifier, func).to!dstring;
                    animationsMap[funcName] = &func;
                }

            }
        }

        import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto rect = new Rectangle(50, 50, GraphicStyle(1.0, RGBA.lightcoral, true, RGBA.lightcoral));
        const startPos = Vec2f(200, 200);
        const endPos = Vec2f(450, 200);
        rect.x = startPos.x;
        rect.y = startPos.y;
        //TODO fix autoresize
        rect.maxWidth = 50;
        rect.maxHeight = 50;

        //rect.isManaged = false;
        rect.isLayoutManaged = false;
        addCreate(rect);

        motionTween = new LinearMotion(startPos, endPos, 1000, interpolator);
        motionTween.addTarget(rect);
        addCreate(motionTween);
        motionTween.isInfinite = true;
        motionTween.isReverse = true;

        import api.dm.gui.controls.containers.hbox : HBox;

        auto guiContainer = new HBox;
        addCreate(guiContainer);

        import api.dm.gui.controls.selects.choices.choice : Choice;

        // auto animSelect = new Choice;

        // import std.conv : to;

        // dstring[] choiceItems = animationsMap.keys.to!(dstring[]);
        // guiContainer.addCreate(animSelect);

        // animSelect.fill(choiceItems);

        // animSelect.selectFirst;

        // animSelect.onChoice = (oldItem, newItem) {
        //     auto newFunc = animationsMap[newItem];
        //     motionTween.stop;
        //     interpolator.interpolateMethod = newFunc;
        //     motionTween.run;
        // };

        motionTween.run;
    }
}
