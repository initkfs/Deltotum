module deltotum.kit.window.window;

import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.input.mouse.mouse_cursor_type : MouseCursorType;
import deltotum.kit.scene.scene_manager : SceneManager;
import deltotum.kit.window.window_manager : WindowManager;

//TODO move to deltotum.platforms;
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Window
{
    Window parent;
    WindowManager windowManager;

    SdlRenderer renderer;
    SdlWindow nativeWindow;
    //TODO remove
    double frameRate;

    SceneManager scenes;

    bool isFocus;
    bool isShowing;

    const int id;

    this(SdlRenderer renderer, SdlWindow window, int id = 0)
    {
        this.renderer = renderer;
        this.nativeWindow = window;
        this.id = id;
    }

    void close()
    {
        destroy;
    }

    void present() @nogc nothrow
    {
        renderer.present;
    }

    void focus() @nogc nothrow
    {
        nativeWindow.focus;
    }

    int getWidth() @nogc nothrow
    {
        int width, height;
        nativeWindow.getSize(&width, &height);
        return width;
    }

    int getHeight() @nogc nothrow
    {
        int width, height;
        nativeWindow.getSize(&width, &height);
        return height;
    }

    uint getId() @nogc nothrow
    {
        return nativeWindow.getId;
    }

    int getX() @nogc nothrow
    {
        int x, y;
        nativeWindow.getPos(&x, &y);
        return x;
    }

    int getY() @nogc nothrow
    {
        int x, y;
        nativeWindow.getPos(&x, &y);
        return y;
    }

    Rect2d getWorldBounds() @nogc nothrow
    {
        auto bounds = nativeWindow.getWorldBounds;
        Rect2d boundsRect = {bounds.x, bounds.y, bounds.w, bounds.h};
        return boundsRect;
    }

    Rect2d getScaleBounds() @nogc nothrow
    {
        auto bounds = nativeWindow.getScaleBounds;
        Rect2d boundsRect = {bounds.x, bounds.y, bounds.w, bounds.h};
        return boundsRect;
    }

    double getScale() @nogc nothrow
    {
        int outputWidth;
        int outputHeight;

        if (const err = renderer.getOutputSize(&outputWidth, &outputHeight))
        {
            //TODO logging
            return 0;
        }

        int windowWidth;
        int windowHeight;

        nativeWindow.getSize(&windowWidth, &windowHeight);
        //TODO height
        double scale = (cast(double)(outputWidth)) / windowWidth;
        return scale;
    }

    void move(int x, int y) @nogc nothrow
    {
        //TODO check bounds
        nativeWindow.move(x, y);
    }

    void resize(int width, int height) @nogc nothrow
    {
        //TODO check bounds
        nativeWindow.resize(width, height);
    }

    void setBorder(bool border) @nogc nothrow
    {
        //TODO set lazy
        nativeWindow.setBordered(border);
    }

    void setMaximized(bool isMaximized) @nogc nothrow
    {
        if (isMaximized)
        {
            nativeWindow.maximize;
            return;
        }

        nativeWindow.restore;
    }

    void setMinimized(bool isMinimized) @nogc nothrow
    {
        if (isMinimized)
        {
            nativeWindow.minimize;
            return;
        }

        nativeWindow.restore;
    }

    void setResizable(bool isResizable) @nogc nothrow
    {
        nativeWindow.setResizable(isResizable);
    }

    void setTitle(string title) nothrow
    {
        nativeWindow.setTitle(title);
    }

    void restoreCursor()
    {
        if (const err = nativeWindow.restoreCursor)
        {
            //TODO logging
            throw new Exception(err.toString);
        }
    }

    void setCursor(MouseCursorType type)
    {
        if (const err = nativeWindow.setCursor(type))
        {
            //TODO logging
            throw new Exception(err.toString);
        }
    }

    Vector2d mousePos() @nogc nothrow
    {
        int x, y;
        nativeWindow.mousePos(&x, &y);
        return Vector2d(x, y);
    }

    void update(double delta)
    {
        scenes.currentScene.update(delta);
    }

    void destroy()
    {
        //TODO close child windows
        renderer.destroy;
        if (scenes !is null)
        {
            scenes.destroy;
        }
        //after window
        nativeWindow.destroy;
    }
}
