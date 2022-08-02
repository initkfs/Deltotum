module deltotum.ui.layouts.center_layout;

import deltotum.ui.controls.control : Control;
import deltotum.ui.layouts.layout : Layout;

class CenterLayout : Layout
{

    override void layout(Control root)
    {

        auto bounds = root.bounds;

        foreach (child; root.children)
        {
            auto childBounds = child.bounds;
            if (childBounds.width > 0 && childBounds.width < bounds.width)
            {
                child.x = bounds.x + bounds.width / 2 - childBounds.width / 2;
            }

            if (childBounds.height > 0 && childBounds.height < bounds.height)
            {
                child.y = bounds.y + bounds.height / 2 - childBounds.height / 2;
            }
        }
    }
}
