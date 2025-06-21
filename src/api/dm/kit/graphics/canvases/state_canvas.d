module api.dm.kit.graphics.canvases.state_canvas;

import api.dm.kit.graphics.canvases.graphics_canvas : GraphicsCanvas;
import api.math.geom2.vec2: Vec2d;

/**
 * Authors: initkfs
 */
abstract class StateCanvas : GraphicsCanvas
{
    protected
    {
        double x = 0;
        double y = 0;
    }

    void moveTo(double x, double y)
    {
        this.x = x;
        this.y = y;
    }

    void moveTo(Vec2d pos){
        moveTo(pos.x, pos.y);
    }

    void reset(){
        this.x = 0;
        this.y = 0;
    }
}
