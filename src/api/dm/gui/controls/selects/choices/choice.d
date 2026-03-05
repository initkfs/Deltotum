module api.dm.gui.controls.selects.choices.choice;

import api.dm.gui.controls.selects.choices.base_choice: BaseChoice;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton, NavigateDirection;

/**
 * Authors: initkfs
 */
class Choice(T) : BaseChoice!T
{
    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.vbox: VBox;

        if (isCreateNextButton || isCreatePrevButton)
        {
            auto prevNextContainer = new VBox;
            prevNextContainer.isAlignX = true;
            addCreate(prevNextContainer);
            prevNextContainer.enablePadding;

            tryCreatePrevButton(prevNextContainer, NavigateDirection.toTop);
            tryCreateNextButton(prevNextContainer, NavigateDirection.toBottom);
        }

        tryCreateLabel;
    }
}
