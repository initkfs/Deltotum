module dm.kit.graphics.contexts.graphics_context;

import dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
interface GraphicsContext
{
    void setColor(RGBA rgba);
    void restoreColor();
    void translate(double x, double y);
    void moveTo(double x, double y);
    void setLineWidth(double width);
    void reset();
    void clear(RGBA color);
    void lineTo(double x, double y);
    void stroke();
    void strokePreserve();
    void beginPath();
    void closePath();
    void fill();
    void fillPreserve();
    void fillRect(double x, double y, double width, double height);
    void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3);
}
