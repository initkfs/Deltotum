module api.demo.main_controller;

import std;

import api.dm.back.sdl2.sdl_app : SdlApp;

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
        debug writeln(err.fromStringz);
    }

    int run(string[] args)
    {
        enum gameWidth = 1280;
        enum gameHeight = 720;

        application = new SdlApp();
        application.isStrictConfigs = false;
        auto initRes = application.initialize(args);
        if (!initRes)
        {
            import std.stdio: stderr;

            stderr.writeln("Not initialized!");
            return 1;
        }

        if(initRes.isExit){
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
