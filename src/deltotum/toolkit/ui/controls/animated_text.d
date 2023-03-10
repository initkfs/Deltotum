module deltotum.toolkit.ui.controls.animated_text;

import deltotum.toolkit.ui.controls.text : Text;
import deltotum.toolkit.display.animation.transition : Transition;
import deltotum.toolkit.display.animation.interp.interpolator : Interpolator;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.toolkit.i18n.langs.glyph : Glyph;

import std.conv : to;
import std.stdio;

/**
 * Authors: initkfs
 * TODO rewrite
 */
class AnimatedText : Text
{
    // private
    // {
    //     Transition!double animation;
    //     Glyph[] renderedGlyphs;
    //     Glyph[] textGlyphs;
    //     size_t currentGlyphIndex;
    //     string oldText;
    // }

    // void delegate() onEnd;

    this(string text = "text", int animationDelayMs = 2000)
    {
        super(text);
        //animation = new Transition!double(0.0, 0.0, animationDelayMs);
    }

    // override void create()
    // {
    //     super.create;
    //     build(animation);
    //     animation.onValue = (value) {
    //         if (value < 0 || textGlyphs.length <= 0)
    //         {
    //             return;
    //         }
    //         const size_t lastGlyphIndex = textGlyphs.length - 1;
    //         size_t index = cast(size_t) value;
    //         if (index > lastGlyphIndex)
    //         {
    //             index = lastGlyphIndex;
    //         }

    //         if (index == 0 && currentGlyphIndex == lastGlyphIndex)
    //         {
    //             //renderedGlyphs = [];
    //             animation.stop;
    //             if (onEnd !is null)
    //             {
    //                 onEnd();
    //             }
    //             return;
    //         }

    //         if (index == currentGlyphIndex && renderedGlyphs.length > 0)
    //         {
    //             return;
    //         }

    //         renderedGlyphs ~= textGlyphs[index];
    //         currentGlyphIndex = index;
    //     };
    // }

    // override void drawContent()
    // {
    //     renderText(renderedGlyphs);
    // }

    // override void update(double delta)
    // {
    //     super.update(delta);

    //     animation.update(delta);
    //     if (animation.isRun)
    //     {
    //         return;
    //     }

    //     if (text.length == 0 || (renderedGlyphs.length > 0 && oldText == text))
    //     {
    //         return;
    //     }

    //     textGlyphs = textToGlyphs(text);
    //     if (textGlyphs.length == 0)
    //     {
    //         return;
    //     }

    //     renderedGlyphs = [];

    //     animation.maxValue = textGlyphs.length - 1;

    //     animation.run;
    //     oldText = text;
    // }
}
