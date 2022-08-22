module deltotum.ui.controls.animated_text;

import deltotum.ui.controls.text : Text;
import deltotum.display.animation.transition : Transition;
import deltotum.display.animation.interp.interpolator : Interpolator;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.i18n.langs.glyph : Glyph;

import std.conv : to;
import std.stdio;

/**
 * Authors: initkfs
 */
class AnimatedText : Text
{
    private
    {
        Transition!double animation;
        Glyph[] renderedGlyphs;
        Glyph[] textGlyphs;
        size_t currentGlyphIndex;
        string oldText;
    }

    @property void delegate() onEnd;

    this(string text = "text")
    {
        super(text);
    }

    override void drawContent()
    {
        renderText(renderedGlyphs);
    }

    override void update(double delta)
    {
        super.update(delta);

        if (animation !is null)
        {
            animation.update(delta);
            if(animation.isRun){
                return;
            }
        }

        if (renderedGlyphs.length > 0 && oldText == text)
        {
            return;
        }

        textGlyphs = textToGlyphs(text);
        renderedGlyphs = [];
 
        //TODO reuse transition
        animation = new Transition!double(0.0, to!(double)(text.length - 1), 2000);
        build(animation);
        animation.onValue = (value) {
            assert(value >= 0);
            assert(textGlyphs.length > 0);
            size_t index = cast(size_t) value;
            if (index > textGlyphs.length - 1)
            {
                index = textGlyphs.length - 1;
            }

            if (index == 0 && currentGlyphIndex == textGlyphs.length - 1)
            {
                //renderedGlyphs = [];
                if (animation !is null)
                {
                    animation.stop;
                }

                if (onEnd !is null)
                {
                    onEnd();
                }

                return;
            }

            if (index == currentGlyphIndex && renderedGlyphs.length > 0)
            {
                return;
            }

            renderedGlyphs ~= textGlyphs[index];
            currentGlyphIndex = index;
        };
        animation.run;
        oldText = text;
    }
}
