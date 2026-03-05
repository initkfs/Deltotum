module api.dm.gui.controls.selects.choices.hchoice;

import api.dm.gui.controls.selects.choices.base_choice : BaseChoice;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton, NavigateDirection;
import api.dm.gui.controls.texts.text_view : TextView;

/**
 * Authors: initkfs
 */
class HChoice(T) : BaseChoice!T
{

    override void create()
    {
        super.create;
        tryCreatePrevButton(this, NavigateDirection.toLeft);
        tryCreateLabel;
        tryCreateNextButton(this, NavigateDirection.toRight);

        enablePadding;
    }

    override TextView newLabel()
    {
        auto label = super.newLabel;
        label.isHGrow = true;
        return label;
    }
}
