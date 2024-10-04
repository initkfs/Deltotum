module api.dm.kit.graphics.contexts.state_graphics_context;

import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.math.vec2: Vec2d;

/**
 * Authors: initkfs
 */
abstract class StateGraphicsContext : GraphicsContext
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
