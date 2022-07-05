module game.state.demo_state;

import deltotum.state.state : State;

import deltotum.display.bitmap.bitmap : Bitmap;

import std.stdio;

class DemoState : State
{
    enum gameWidth = 640;
    enum gameHeight = 480;

    private
    {
        Bitmap foreground;
    }
    override void create()
    {
        foreground = new Bitmap;
        build(foreground);

        bool isLoad = foreground.load("foreground.png", gameWidth, gameHeight);
        if (!isLoad)
        {
            logger.error("Unable to load test sprite");
        }

        add(foreground);
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
