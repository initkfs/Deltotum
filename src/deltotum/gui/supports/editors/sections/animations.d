module deltotum.gui.supports.editors.sections.animations;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;

import Math = deltotum.math;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

import deltotum.kit.sprites.animations.interp.uni_interpolator : UniInterpolator;
import deltotum.kit.sprites.animations.object.motion.linear_motion_transition : LinearMotionTransition;
import deltotum.kit.sprites.animations.object.value_transition : ValueTransition;
import deltotum.kit.sprites.animations.object.property.angle_transition : AngleTransition;

import std.stdio;
import std.conv : to;

/**
 * Authors: initkfs
 */
class Animations : Control
{
    private
    {
        double function(double)[dstring] animationsMap;
        UniInterpolator interpolator;

        LinearMotionTransition motionTransition;
        AngleTransition angleTransition;
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

        static foreach (m; __traits(derivedMembers, UniInterpolator))
        {
            {
                alias func = __traits(getMember, interpolator, m);
                //TODO best filter
                static if (__traits(isFinalFunction, func))
                {
                    const funcName = __traits(identifier, func).to!dstring;
                    animationsMap[funcName] = &func;
                }

            }
        }

        import deltotum.kit.sprites.shapes.rectangle : Rectangle;
        import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;
        import deltotum.kit.graphics.colors.rgba: RGBA;

        auto rect = new Rectangle(50, 50, GraphicStyle(1.0, RGBA.lightcoral, true, RGBA.lightcoral));
        const startPos = Vector2d(200, 200);
        const endPos = Vector2d(450, 200);
        rect.x = startPos.x;
        rect.y = startPos.y;
        //TODO fix autoresize
        rect.maxWidth = 50;
        rect.maxHeight = 50;

        //rect.isManaged = false;
        rect.isLayoutManaged = false;
        addCreate(rect);

        motionTransition = new LinearMotionTransition(rect, startPos, endPos, 1000, interpolator);
        addCreate(motionTransition);
        motionTransition.isCycle = true;
        motionTransition.isInverse = true;

        import deltotum.gui.containers.hbox : HBox;

        auto guiContainer = new HBox;
        addCreate(guiContainer);

        import deltotum.gui.controls.choices.choice_box : ChoiceBox;

        auto animSelect = new ChoiceBox;

        import std.conv : to;

        dstring[] choiceItems = animationsMap.keys.to!(dstring[]);
        guiContainer.addCreate(animSelect);

        animSelect.fill(choiceItems);

        animSelect.selectFirst;

        import std.functional : toDelegate;

        animSelect.onChoice = (oldItem, newItem) {
            auto newFunc = animationsMap[newItem];
            motionTransition.stop;
            interpolator.interpolateMethod = newFunc.toDelegate;
            motionTransition.run;
        };

        motionTransition.run;

        import std;
    }
}
