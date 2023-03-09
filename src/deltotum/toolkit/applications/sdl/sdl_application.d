module deltotum.toolkit.applications.sdl.sdl_application;

import deltotum.core.applications.application_exit: ApplicationExit;
import deltotum.core.applications.graphic_application : GraphicApplication;
import deltotum.toolkit.applications.components.graphics_component: GraphicsComponent;
import deltotum.toolkit.events.event_manager : EventManager;
import deltotum.platform.sdl.events.sdl_event_processor : SdlEventProcessor;
import deltotum.toolkit.asset.assets : Assets;
import deltotum.toolkit.asset.fonts.font : Font;
import deltotum.toolkit.scene.scene_manager : SceneManager;
import deltotum.toolkit.audio.audio : Audio;
import deltotum.toolkit.graphics.graphics : Graphics;
import deltotum.toolkit.scene.scene : Scene;
import deltotum.toolkit.input.keyboard.event.key_event : KeyEvent;
import deltotum.toolkit.input.joystick.event.joystick_event : JoystickEvent;

import deltotum.platform.sdl.sdl_lib : SdlLib;
import deltotum.platform.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.platform.sdl.mix.sdl_mix_lib : SdlMixLib;
import deltotum.platform.sdl.ttf.sdl_ttf_lib : SdlTTFLib;
import deltotum.platform.sdl.sdl_window : SdlWindow;
import deltotum.platform.sdl.sdl_renderer : SdlRenderer;
import deltotum.platform.sdl.sdl_joystick : SdlJoystick;

import deltotum.toolkit.window.window : Window;
import deltotum.toolkit.input.input : Input;

import std.experimental.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlApplication : GraphicApplication
{

    private
    {
        SdlLib sdlLib;
        SdlImgLib imgLib;
        SdlMixLib audioMixLib;
        SdlTTFLib fontLib;
        SdlJoystick joystick;

        //TODO check overflow and remove increment
        double deltaTime = 0;
        double deltaTimeAccumulator = 0;
        double lastUpdateTime = 0;
        int sceneWidth;
        int sceneHeight;

    }

    string title;
    bool isRunning;
    EventManager eventManager;
    SceneManager sceneManager;

    this(string title, int sceneWidth, int sceneHeight, SdlLib lib, SdlImgLib imgLib, SdlMixLib audioMixLib, SdlTTFLib fontLib)
    {
        this.title = title;
        this.sceneWidth = sceneWidth;
        this.sceneHeight = sceneHeight;
        this.sdlLib = lib;
        this.imgLib = imgLib;
        this.audioMixLib = audioMixLib;
        this.fontLib = fontLib;
        this.frameRate = 60;
    }

    override ApplicationExit initialize(string[] args)
    {
        if(auto isExit = super.initialize(args)){
            return isExit;
        }

        sdlLib.initialize(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK);

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;
        audioMixLib.initialize;
        fontLib.initialize;

        joystick = SdlJoystick.fromDevices;
        // if(joystick !is null){

        // }

        this.frameRate = frameRate;

        auto sdlWindow = new SdlWindow(title, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            sceneWidth,
            sceneHeight);
        auto sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED);
        auto window = new Window(sdlRenderer, sdlWindow);
        //TODO remove
        window.frameRate = frameRate;
        gservices.window = window;

        gservices.input = new Input;

        gservices.audio = new Audio(audioMixLib);

        sceneManager = new SceneManager;

        //TODO remove sdl api
        eventManager = new EventManager(sceneManager);
        eventManager.eventProcessor = new SdlEventProcessor;
        eventManager.startEvents;
        eventManager.onKey = (key) {
            if (key.event == KeyEvent.Event.keyDown)
            {
                gservices.input.addPressedKey(key.keyCode);
            }
            else if (key.event == KeyEvent.Event.keyUp)
            {
                gservices.input.addReleasedKey(key.keyCode);
            }
        };
        eventManager.onJoystick = (joystickEvent) {

            if (joystickEvent.event == JoystickEvent.Event.axis)
            {
                if (gservices.input.justJoystickActive)
                {
                    gservices.input.justJoystickChangeAxis = joystickEvent.axis != gservices.input
                        .lastJoystickEvent.axis;
                    gservices.input.justJoystickChangesAxisValue = gservices.input.lastJoystickEvent.axisValue != joystickEvent
                        .axisValue;
                    gservices.input.joystickAxisDelta = joystickEvent.axisValue - gservices.input
                        .lastJoystickEvent.axisValue;
                }
            }
            else if (joystickEvent.event == JoystickEvent.Event.press)
            {
                gservices.input.justJoystickPressed = true;
            }
            else if (joystickEvent.event == JoystickEvent.Event.release)
            {
                gservices.input.justJoystickPressed = false;
            }

            gservices.input.lastJoystickEvent = joystickEvent;
            if (!gservices.input.justJoystickActive)
            {
                gservices.input.justJoystickActive = true;
            }
        };

        //TODO move to config
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);
        if (!exists(assetsDir) || !isDir(assetsDir))
        {
            throw new Exception("Unable to find resource directory: " ~ assetsDir);
        }

        auto assetManager = new Assets(gservices.logger, assetsDir);
        gservices.assets = assetManager;

        //TODO from config
        Font defaultFont = assetManager.font("fonts/OpenSans-Regular.ttf", 14);
        assetManager.defaultFont = defaultFont;

        import deltotum.toolkit.graphics.themes.theme : Theme;

        auto theme = new Theme(defaultFont);

        gservices.graphics = new Graphics(gservices.logger, window.renderer, theme);

        //TODO build and run services after all
        import deltotum.toolkit.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;

        //TODO from locale\config;
        import deltotum.toolkit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import deltotum.toolkit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
        import deltotum.toolkit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import deltotum.toolkit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

        import deltotum.toolkit.ui.texts.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

        auto fontGenerator = new BitmapFontGenerator;
        build(fontGenerator);
        assetManager.defaultBitmapFont = fontGenerator.generate([
            new ArabicNumeralsAlpabet,
            new SpecialCharactersAlphabet,
            new AlphabetEn,
            new AlphabetRu
        ], defaultFont);

        isRunning = true;
        return ApplicationExit(false);
    }

    override void runWait()
    {
        while (isRunning)
        {
            update;
        }
    }

    void clearErrors()
    {
        sdlLib.clearError;
    }

    void addScene(Scene scene)
    {
        build(scene);
        scene.create;
        sceneManager.currentScene = scene;
    }

    override void quit()
    {
        clearErrors;
        if (gservices.window !is null)
        {
            gservices.window.destroy;
        }

        if (sceneManager !is null)
        {
            sceneManager.destroy;
        }

        //TODO auto destroy all services
        gservices.audio.destroy;

        if (joystick !is null)
        {
            joystick.destroy;
        }

        //TODO process EXIT event
        audioMixLib.quit;
        imgLib.quit;
        sdlLib.quit;
        fontLib.quit;
    }

    void updateState(double delta)
    {
        if (gservices.window !is null)
        {
            //window.renderer.clear;
            sceneManager.update(delta);
            //window.renderer.present;
        }
    }

    override bool update()
    {
        enum msInSec = 1000;
        const frameTime = msInSec / frameRate;

        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        const start = SDL_GetTicks();
        deltaTime = start - lastUpdateTime;
        lastUpdateTime = start;
        deltaTimeAccumulator += deltaTime;

        SDL_Event event;

        sceneManager.currentScene.timeEventProcessingMs = 0;

        while (SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();
            sceneManager.currentScene.timeEventProcessingMs = endEvent - startEvent;
            if (!isRunning)
            {
                return isRunning;
            }
        }

        while (deltaTimeAccumulator > frameTime)
        {
            immutable constantDelta = frameTime / 100;
            const startStateTime = SDL_GetTicks();
            updateState(constantDelta);
            const endStateTime = SDL_GetTicks();
            sceneManager.currentScene.timeUpdateProcessingMs = endStateTime - startStateTime;
            deltaTimeAccumulator -= frameTime;
        }

        return true;
    }

    void handleEvent(SDL_Event* event)
    {
        eventManager.eventProcessor.process(event);

        if (event.type == SDL_QUIT)
        {
            isRunning = false;
            return;
        }
    }
}
