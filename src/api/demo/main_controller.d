module api.demo.main_controller;

import api.dm.back.sdl3.sdl_app : SdlApp;

import std.stdio : writeln;

/**
 * Authors: initkfs
 */
class MainController
{

    private
    {
        dstring windowTitle = "SDL Application";
        SdlApp application;
    }

    static extern (C) void err(int code, const(char)* err) nothrow
    {
        import std.string : fromStringz;

        debug writeln(err.fromStringz);
    }

    int run(string[] args)
    {
        enum gameWidth = 1366;
        enum gameHeight = 768;

        application = new SdlApp("SdlApp");
        auto initRes = application.initialize(args);
        if (!initRes.isInit)
        {
            import std.stdio : stderr;

            stderr.writeln("Not initialized!");
            return 1;
        }

        if (initRes.isExit)
        {
            writeln("Exit after initializaion");
            return 0;
        }

        application.create;

        import api.demo.demo1.scenes.start : Start;
        import api.demo.demo1.scenes.game : Demo1;
        import api.demo.demo1.scenes.settings : Settings;
        import api.demo.demo1.scenes.about : About;
        import api.demo.demo1.scenes.help : Help;

        auto startScene = new Start;

        import api.dm.kit.windows.window : Window;

        Window win1 = application.newWindow(windowTitle, gameWidth, gameHeight);
        win1.add(startScene, new Demo1, new Settings, new Help, new About);
        win1.change(startScene);
        win1.show;

        //win1.support.printReport;

        application.run;
        return 0;
    }
}
