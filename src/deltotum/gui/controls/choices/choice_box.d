module deltotum.gui.controls.choices.choice_box;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.gui.controls.texts.text : Text;

import deltotum.gui.containers.vbox : VBox;

class ChoiceItem : Sprite
{
    Text label;

    void delegate() onChoice;

    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(0);
        layout.isAutoResize(true);
    }

    override void create()
    {
        super.create;

        label = new Text;
        addCreate(label);

        onMouseDown = (e) {
            if (onChoice)
            {
                onChoice();
            }
            return false;
        };
    }

    dstring text;
}

/**
 * Authors: initkfs
 */
class ChoiceBox : Control
{
    protected
    {
        Text label;
        Button button;

        VBox choiceList;
    }

    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(5);
        layout.isAutoResize(true);
        layout.isAlignY = true;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        label = new Text("----");
        label.isFocusable = false;
        addCreate(label);

        button = new Button("▼");
        button.isBackground = true;
        button.width = 50;
        addCreate(button);

        button.onAction = (e) { toggleChoiceList; };

        choiceList = new VBox(2);
        choiceList.isLayoutManaged = false;
        addCreate(choiceList);
        choiceList.isVisible = false;
    }

    protected void toggleChoiceList()
    {
        choiceList.x = x;
        choiceList.y = bounds.bottom;
        choiceList.isVisible = !choiceList.isVisible;
    }

    void fill(dstring[] list)
    {
        foreach (s; list)
            (dstring s) {
            import deltotum.gui.containers.hbox : HBox;

            auto choiceListRow = new ChoiceItem;
            choiceList.addCreate(choiceListRow);
            choiceListRow.label.text = s;
            choiceListRow.onChoice = () { label.text = s; toggleChoiceList; };
        }(s);
    }

}
