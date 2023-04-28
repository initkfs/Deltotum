module deltotum.kit.windows.factories.sdl_window_factory;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.kit.windows.factories.window_factory : WindowFactory;
import deltotum.kit.windows.window : Window;
import deltotum.kit.scenes.scene_manager : SceneManager;

import deltotum.sys.sdl.sdl_window : SdlWindow, SdlWindowMode;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;

//TODO remove
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlWindowFactory : WindowFactory
{
    //TODO graphics, assets...
    SdlRenderer delegate() rendererProvider;
    SceneManager delegate() sceneManagerProvider;

    private
    {
        SdlWindowMode mode;
        dstring title;
        int width;
        int height;
        int x;
        int y;
    }

    this(dstring title = "New window", int prefWidth = 400, int prefHeight = 300, int x = -1, int y = -1, SdlWindowMode mode = SdlWindowMode
            .none)
    {
        //TODO validate
        this.title = title;
        this.width = prefWidth;
        this.height = prefHeight;
        this.x = x;
        this.y = y;
        this.mode = mode;
    }

    override Window createWindow()
    {
        import std.conv : to;

        auto sdlWindow = new SdlWindow;
        sdlWindow.mode = mode;

        auto newWindow = new Window(logger, sdlWindow);

        newWindow.initialize;
        newWindow.create;

        newWindow.setNormatWindow;

        newWindow.setSize(width, height);

        const int newX = (x == -1) ? SDL_WINDOWPOS_UNDEFINED : x;
        const int newY = (y == -1) ? SDL_WINDOWPOS_UNDEFINED : y;

        newWindow.setPos(newX, newY);

        //TODO extract renderer
        SdlRenderer sdlRenderer = !rendererProvider ? new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED)
            : rendererProvider();

        newWindow.renderer = sdlRenderer;

        if (hasWindow)
        {
            newWindow.windowManager = window.windowManager;
            newWindow.parent = window;
            newWindow.frameRate = window.frameRate;
        }

        this.window = newWindow;

        window.setTitle(title);

        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);

        import deltotum.kit.assets.asset : Asset;

        asset = new Asset(logger, assetsDir);

        import deltotum.kit.graphics.themes.theme : Theme;
        import deltotum.kit.graphics.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logger, config, context, asset
                .defaultFont);

        auto theme = themeLoader.create;

        import deltotum.kit.assets.fonts.font : Font;

        Font defaultFont = asset.font("fonts/NotoSans-Bold.ttf", 14);
        asset.defaultFont = defaultFont;

        import deltotum.kit.graphics.graphics : Graphics;

        graphics = new Graphics(logger, sdlRenderer, theme);
        graphics.comTextureFactory = ()
        {
            import deltotum.sys.sdl.sdl_texture : SdlTexture;

            return new SdlTexture(sdlRenderer);
        };

        graphics.comSurfaceFactory = (){
            import deltotum.sys.sdl.sdl_surface: SdlSurface;
            return new SdlSurface();
        };

        import deltotum.gui.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

        //TODO build and run services after all
        import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;

        //TODO from locale\config;
        if (mode == SdlWindowMode.none)
        {
            import deltotum.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
            import deltotum.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
            import deltotum.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
            import deltotum.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

            auto fontGenerator = new BitmapFontGenerator;
            build(fontGenerator);
            import deltotum.kit.graphics.colors.rgba : RGBA;

            asset.defaultBitmapFont = fontGenerator.generate([
                new ArabicNumeralsAlpabet,
                new SpecialCharactersAlphabet,
                new AlphabetEn,
                new AlphabetRu
            ], asset.defaultFont, theme.colorText);
        }

        import deltotum.kit.scenes.scene_manager : SceneManager;

        auto sceneManager = !sceneManagerProvider ? new SceneManager : sceneManagerProvider();
        build(sceneManager);
        window.scenes = sceneManager;

        return newWindow;
    }
}
