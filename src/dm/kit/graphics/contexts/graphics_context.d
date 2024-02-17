module dm.kit.graphics.contexts.graphics_context;

import dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
interface GraphicsContext
{
    void setColor(RGBA rgba);
    void restoreColor();
    void moveTo(double x, double y);
    void lineTo(double x, double y);
    void stroke();
    void fill();
}
