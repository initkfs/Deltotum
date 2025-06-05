module api.dm.gui.controls.texts.base_text;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.math.geom2.vec2 : Vec2d;
import api.math.flip : Flip;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.assets.fonts.font_size : FontSize;

import Math = api.math;

import std.conv : to;


/**
 * Authors: initkfs
 */
class BaseText : Control
{
    int spaceWidth = 5;
    int rowHeight = 0;

    RGBA _color;
    FontSize fontSize = FontSize.medium;

    Sprite2d focusEffect;
    Sprite2d delegate() focusEffectFactory;

    void delegate(ref KeyEvent) onEnter;
    void delegate() onTextChange;

    bool isReduceWidthHeight = true;

    bool isShowNewLineGlyph;

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseTextTheme;
    }

    void loadBaseTextTheme()
    {
        if (_color == RGBA.init)
        {
            _color = theme.colorText;
        }
    }

    void setLargeSize()
    {
        fontSize = FontSize.large;
    }

    void setMediumSize()
    {
        fontSize = FontSize.medium;
    }

    void setSmallSize()
    {
        fontSize = FontSize.small;
    }
}
