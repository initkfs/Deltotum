module deltotum.kit.window.factories.sdl_window_factory;

import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.kit.window.window : Window;

import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlWindowFactory : GraphicsComponent
{
    Window create(dstring title, size_t prefWidth, size_t prefHeight, long x = 0, long y = 0)
    {
        //SDL_WINDOWPOS_UNDEFINED
        import std.conv : to;

        auto sdlWindow = new SdlWindow(title, cast(int) x, cast(int) y, cast(int) prefWidth, cast(
                int) prefHeight);

        auto sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED);
        uint id;
        if (const err = sdlWindow.windowId(id))
        {
            throw new Exception(err.toString);
        }
        auto newWindow = new Window(sdlRenderer, sdlWindow, id);
        if (hasWindow)
        {
            newWindow.windowManager = window.windowManager;
            newWindow.parent = window;
            newWindow.frameRate = window.frameRate;
        }

        this.window = newWindow;

        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);

        import deltotum.kit.asset.assets : Assets;

        assets = new Assets(logger, assetsDir);

        import deltotum.kit.graphics.themes.theme : Theme;
        import deltotum.kit.graphics.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logger, config, context, assets
                .defaultFont);

        auto theme = themeLoader.create;

        import deltotum.kit.asset.fonts.font : Font;

        Font defaultFont = assets.font("fonts/NotoSans-Bold.ttf", 14);
        assets.defaultFont = defaultFont;

        import deltotum.kit.graphics.graphics : Graphics;

        graphics = new Graphics(logger, sdlRenderer, theme);

        import deltotum.gui.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

        //TODO build and run services after all
        import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;

        //TODO from locale\config;
        import deltotum.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import deltotum.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
        import deltotum.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import deltotum.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

        auto fontGenerator = new BitmapFontGenerator;
        build(fontGenerator);
        import deltotum.kit.graphics.colors.rgba : RGBA;

        assets.defaultBitmapFont = fontGenerator.generate([
            new ArabicNumeralsAlpabet,
            new SpecialCharactersAlphabet,
            new AlphabetEn,
            new AlphabetRu
        ], assets.defaultFont, theme.colorText);

        import deltotum.kit.scene.scene_manager : SceneManager;

        auto sceneManager = new SceneManager;
        build(sceneManager);
        window.scenes = sceneManager;

        return newWindow;
    }
}
