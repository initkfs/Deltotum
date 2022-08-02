module deltotum.ui.layouts.horizontal_layout;

import deltotum.ui.controls.control : Control;
import deltotum.ui.layouts.layout : Layout;

class HorizontalLayout : Layout
{
    double spacing = 0;

    override void layout(Control root)
    {

        auto bounds = root.bounds;

        //TODO vertical align
        double nextX = bounds.x;
        foreach (child; root.children)
        {
            if (!child.isLayoutManaged)
            {
                continue;
            }
            auto childBounds = child.bounds;
            child.x = nextX;
            nextX = child.x + childBounds.width + spacing;
        }
    }
}
