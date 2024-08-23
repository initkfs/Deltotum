module api.game.main_controller;

import std;

import api.dm.back.sdl2.sdl_application : SdlApplication;

/**
 * Authors: initkfs
 */
class MainController
{

    private
    {
        dstring windowTitle = "SDL Application";
        SdlApplication application;
    }

    static extern (C) void err(int code, const(char)* err) nothrow
    {
        debug writeln(err.fromStringz);
    }

    int run(string[] args)
    {
        enum gameWidth = 1280;
        enum gameHeight = 720;

        application = new SdlApplication();
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

        import api.game.demo.galaxyd.scenes.start : Start;
        import api.game.demo.galaxyd.scenes.game : Game;
        import api.game.demo.galaxyd.scenes.settings : Settings;
        import api.game.demo.galaxyd.scenes.about : About;
        import api.game.demo.galaxyd.scenes.help : Help;

        auto startScene = new Start;

        import api.dm.kit.windows.window : Window;

        Window win1 = application.newWindow(windowTitle, gameWidth, gameHeight);
        win1.scenes.add(startScene, new Game, new Settings, new Help, new About);
        win1.scenes.change(startScene);
        win1.show;

        //win1.support.printReport;

        application.run;
        return 0;
    }
}
