module api.dm.ext.ext_app;

import std;

import api.dm.back.sdl3.sdl_app : SdlApp;
import api.dm.kit.apps.graphic_app : GraphicApp;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.windows.window : Window;

import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;

import std.container.slist : SList;

/**
 * Authors: initkfs
 */

private
{
    SdlApp app;
    Window window;
    Scene2d scene;
    extern (C) void function() drawPtr;

    SList!Control controlStack;
    Control root;
}

extern (C) int rt_init();

extern (C) int dm_init(int argc, char** argv)
{
    if (!rt_init())
    {
        writeln("Error runtime initialization");
        return -1;
    }

    string[] args;
    foreach (i; 0 .. argc)
    {
        char* c = argv[i];
        args ~= c.fromStringz.idup;
    }

    controlStack = SList!Control();

    app = new SdlApp("ext_app");
    app.isStrictConfigs = false;
    auto initRes = app.initialize(args);
    if (initRes.isExit && !initRes.isInit)
    {
        writeln("Exit on initialization!");
        return -1;
    }

    app.create;

    scene = new Scene2d;

    enum gameWidth = 1280;
    enum gameHeight = 720;

    window = app.newWindow("window", gameWidth, gameHeight);
    window.add(scene);
    window.change(scene);
    window.show;

    return 0;
}

extern (C) void dm_run()
{
    app.run;
}

extern (C) int dm_exit()
{
    assert(app);
    app.requestExit;
    return 0;
}

extern (C) void dm_window_resize(int width, int height)
{
    window.resize(width, height);
}

extern (C) void dm_graphic_point(int x, int y)
{
    scene.graphics.point(x, y);
}

extern (C) void dm_graphic_line(int x1, int y1, int x2, int y2)
{
    scene.graphics.line(x1, y1, x2, y2);
}

extern (C) void dm_graphic_set_color(ubyte r, ubyte g, ubyte b)
{
    import api.dm.kit.graphics.colors.rgba : RGBA;

    scene.graphics.setColor(RGBA(r, g, b));
}

extern (C) void dm_scene_set_draw_callback(void function() ptr)
{
    drawPtr = ptr;
    scene.onDraw = () { drawPtr(); };
}

private void startControl(Control control)
{
    if (!root)
    {
        root = control;
        scene.addCreate(control);
    }

    if (!controlStack.empty)
    {
        auto prev = controlStack.front;
        prev.addCreate(control);
    }
    controlStack.insertFront(control);
}

extern (C) void dm_end_control()
{
    assert(!controlStack.empty);
    controlStack.removeFront;
}

extern (C) void dm_start_vbox()
{
    startControl(new VBox(5));
}

extern (C) void dm_start_button(char* text)
{
    startControl(new Button(text.fromStringz.to!dstring));
}

extern (C) void dm_control_set_center()
{
    assert(!controlStack.empty);
    auto node = controlStack.front;
    node.toCenter();
}

extern (C) void dm_control_full_screen()
{
    assert(!controlStack.empty);
    auto node = controlStack.front;
    node.width = window.width;
    node.height = window.height;
}

extern (C) void dm_control_show_bounds()
{
    assert(!controlStack.empty);
    auto node = controlStack.front;
    node.isDrawBounds = true;
}

extern (C) void dm_control_children_align_x()
{
    assert(!controlStack.empty);
    auto node = controlStack.front;
    assert(node.layout);
    node.layout.isAlignX = true;
}
