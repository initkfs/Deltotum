module api.dm.kit.graphics.canvases.state_canvas;

import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.math.geom2.vec2: Vec2f;

/**
 * Authors: initkfs
 */
abstract class StateCanvas : GraphicCanvas
{
    protected
    {
        float x = 0;
        float y = 0;
    }

    void moveTo(float x, float y)
    {
        this.x = x;
        this.y = y;
    }

    void moveTo(Vec2f pos){
        moveTo(pos.x, pos.y);
    }

    void reset(){
        this.x = 0;
        this.y = 0;
    }
}
