module api.dm.gui.supports.debuggers.base_debugger_panel;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.scenes.gui_scene: GuiScene;
import api.dm.gui.controls.meters.spinners.spinner : Spinner, FracSpinner;

/**
 * Authors: initkfs
 */
class BaseDebuggerPanel : Container
{
    GuiScene targetScene;
    this(GuiScene newScene)
    {
        assert(newScene);
        this.targetScene = newScene;
        setVLayout;
        layout.isAutoResize = true;
    }

    FracSpinner createNumericField(void delegate(float value) onFieldValue, float dtValue = 0.1)
    {
        auto field = new FracSpinner(-float.max, float.max);
        field.incValue = dtValue;
        field.decValue = dtValue;
        setNumericField(field, onFieldValue);
        return field;
    }

    void setNumericField(FracSpinner field, void delegate(float value) onFieldValue)
    {
        //field.isCreateIncDec = true;
        buildInitCreate(field);

        field.onValueProvider = (v) {
            import Math = api.math;
            import std.math.operations : isClose;

            if (isClose(v, 0, 0, 0.001))
            {
                return 0;
            }

            enum factor = 10.0 ^^ 2;
            return Math.round(v * factor) / factor;
        };

        field.onChangeOldNew ~= (oldv, newv) { onFieldValue(newv); };
    }

    dstring toStringField(float v)
    {
        import std.format : format;
        import std.conv : to;

        return format("%.2g", v).to!dstring;
    }
}
