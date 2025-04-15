module api.dm.gui.controls.audio.sound_pattern_item;

import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.texts.text : Text;

import api.dm.kit.media.synthesis.sound_pattern : SoundPattern;
import api.dm.kit.media.synthesis.effect_synthesis : ADSR;
import api.dm.kit.media.synthesis.music_notes;

/**
 * Authors: initkfs
 */
class SoundPatternItem : BaseBiswitch
{
    SoundPattern pattern;

    Text text;
    Button deleteThis;
    Button insertNext;

    void delegate() onDelete;
    void delegate() onInsertNext;

    Button play;
    void delegate() onPlay;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        deleteThis = new Button("-");
        deleteThis.resize(theme.checkMarkerWidth, theme.checkMarkerHeight);
        addCreate(deleteThis);
        deleteThis.onAction ~= (ref e) {
            if (onDelete)
            {
                onDelete();
            }
            e.isConsumed = true;
        };

        text = new Text("(0)");
        addCreate(text);

        onOldNewValue ~= (oldv, newv) { isDrawBounds = newv; };

        play = new Button("▶");
        play.resize(theme.meterThumbWidth, theme.meterThumbHeight);
        addCreate(play);
        play.onAction ~= (ref e) {
            if (onPlay)
            {
                onPlay();
            }
            e.isConsumed = true;
        };

        insertNext = new Button(">");
        addCreate(insertNext);
        insertNext.resize(theme.meterThumbWidth, theme.meterThumbHeight);
        insertNext.onAction ~= (ref e) {
            if (onInsertNext)
            {
                onInsertNext();
            }
            e.isConsumed = true;
        };

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto style = GraphicStyle(1, RGBA.transparent);
        auto shape = theme.background(1, 1, angle, &style);
        shape.isResizedByParent = true;
        shape.isLayoutManaged = false;
        addCreate(shape);
        shape.onPointerPress ~= (ref e) {
            if (!e.isConsumed)
            {
                toggle;
            }
        };

    }

    void updateData()
    {
        assert(text);
        text.text = toStringShort;
    }

    string toStringShort()
    {
        import std.format : format;

        return format("%d(%.0f)", cast(int) pattern.noteType, pattern.freqHz);
    }

    override string toString()
    {
        import std.format : format;

        return format("%d(%.0f,%.0f,%.0f)", cast(int) pattern.noteType, pattern.freqHz, pattern.fmHz, pattern
                .fmIndex);
    }

}
