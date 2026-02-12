module api.dm.gui.webs.web_engine;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.core.utils.adt.rings.ring_buffer_lf : RingBufferLF;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f, Vec2i;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;

/**
 * Authors: initkfs
 */

//TODO remove, extract ComWebEngine interface
import api.dm.lib.wpe.native;

import core.atomic;
import std.string : toStringz, fromStringz;
import core.stdc.stdlib : malloc, free;
import std.conv : to;

class WebEngine : Sprite2d
{
    shared
    {
        wpe_view_backend_exportable_fdo* fdo;
    }

    Texture2d canvas;
    float pixelDensity = 0;

    WebKitWebView* webView;
    wpe_view_backend_exportable_fdo_client backClient;
    wpe_view_backend* webViewWpeBackend;
    WebKitWebViewBackend* webViewBackend;

    bool isAutoZoom = true;

    struct PixelBufferData
    {
        size_t width;
        size_t height;
        size_t stride;
        ubyte[] pixels;
    }

    __gshared RingBufferLF!(PixelBufferData, 10) pixelBuffer;

    protected
    {
        bool isLoadLib;
    }

    extern (C)
    {
        static void export_shm_buffer(void* data, wpe_fdo_shm_exported_buffer* ebuff)
        {
            WebEngine engine = cast(WebEngine) data;
            assert(engine);

            scope (exit)
            {
                auto wfdo = atomicLoad(engine.fdo);
                assert(wfdo);
                wpe_view_backend_exportable_fdo_dispatch_frame_complete(wfdo);
                //TODO need?
                wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer(wfdo, ebuff);
            }

            wl_shm_buffer* buffer = wpe_fdo_shm_exported_buffer_get_shm_buffer(ebuff);
            if (buffer)
            {
                int stride = wl_wl_shm_buffer_get_stride(buffer);
                ubyte* pixels = cast(ubyte*) wl_wl_shm_buffer_get_data(buffer);
                auto width = wl_wl_shm_buffer_get_width(buffer);
                auto height = wl_wl_shm_buffer_get_height(buffer);

                //TODO check format, BGRA32 
                auto buffSize = stride * height;
                auto buffPtr = cast(ubyte*) malloc(buffSize);
                if (!buffPtr)
                {
                    return;
                }

                auto storeBuff = buffPtr[0 .. buffSize];
                //storeBuff[] = pixels[0 .. buffSize];

                import core.stdc.string : memmove;

                memmove(storeBuff.ptr, pixels, buffSize);

                PixelBufferData[1] buff = [
                    PixelBufferData(width, height, stride, storeBuff)
                ];
                //TODO check result
                engine.pixelBuffer.write(buff);
            }
        }

        static void onEngineChangeState(WebKitWebView* web_view, WebKitLoadEvent load_event, void* user_data)
        {
            import std.stdio : writeln;

            writeln("Load event:", load_event);
        }

        static void onEngineTerminate(void* web_view, int reason, void* user_data)
        {
            import std.stdio;

            writeln("Web process exit");
        }

        static void onLoadFailed(WebKitWebView* self, WebKitLoadEvent loadEvent, gchar* failing_uri, GError* error, gpointer userData)
        {
            import std.stdio : stderr, writeln;
            import std.string : fromStringz;

            stderr.writeln("Load failed: ", error.message.fromStringz.idup, " URI: ", failing_uri);
        }
    }

    this(double width = 400, double height = 400)
    {
        initSize(width, height);
    }

    override void create()
    {
        super.create;

        pixelBuffer.initialize;

        pixelDensity = window.pixelDensity;

        canvas = new Texture2d(width, height);
        build(canvas);
        canvas.createMutBGRA32;
        addCreate(canvas);

        atomicStore(backClient.export_shm_buffer, &export_shm_buffer);

        auto wpe = new WpeWebkitLib;
        wpe.onLoad = () { logger.trace("Load WPE library: ", versionInfo); };
        wpe.onLoadErrors = (err) { logger.trace("WPE library errors: ", err); };

        wpe.load;

        assert(wpe_loader_init);
        if (!wpe_loader_init("libWPEBackend-fdo-1.0.so.1"))
        {
            throw new Exception("Error wpe loader initialization");
            return;
        }

        WebKitWebContext* context = webkit_web_context_get_default();
        if (!context)
        {
            throw new Exception("Webkit context must not be null");
        }

        shared wpe_view_backend_exportable_fdo* wpeBackFDO = wpe_view_backend_exportable_fdo_create(
            &backClient, cast(
                void*) this, canvas.widthu, canvas.heightu);
        if (!wpeBackFDO)
        {
            throw new Exception("FDO backend is null");

        }

        atomicStore(fdo, wpeBackFDO);

        wpe_view_backend* webViewBack = wpe_view_backend_exportable_fdo_get_view_backend(
            wpeBackFDO);
        if (!webViewBack)
        {
            throw new Exception("WPE view backend is null");
        }

        webViewWpeBackend = webViewBack;

        //wpe_view_backend_dispatch_set_size(webViewBack, 600, 400);

        WebKitWebViewBackend* webViewFullBack = webkit_web_view_backend_new(webViewBack, null, null);
        if (!webViewFullBack)
        {
            throw new Exception("Webkit webview backend is null");
        }

        webViewBackend = webViewFullBack;

        if (!wpe_fdo_initialize_shm())
        {
            throw new Exception("Error wpe shm initialization");
        }

        auto newWebView = webkit_web_view_new(webViewFullBack);
        if (!newWebView)
        {
            throw new Exception("WebView is null");
        }

        webView = newWebView;

        go_g_signal_connect(
            webView,
            cast(char*) "load-changed".toStringz,
            cast(void*)&onEngineChangeState,
            null
        );

        //TODO load-failed-with-tls-errors
        go_g_signal_connect(
            webView,
            cast(char*) "load-failed".toStringz,
            cast(void*)&onLoadFailed,
            null
        );

        go_g_signal_connect(webView, cast(char*) "web-process-terminated".toStringz, cast(void*)&onEngineTerminate, null);

        auto settings = webkit_web_view_get_settings(webView);
        if (!settings)
        {
            throw new Exception("Webkit settings is nul");
        }

        backgroundColor(RGBA.white);

        // wpe_view_backend_add_activity_state(webViewBack,
        //     WPE_VIEW_ACTIVITY_STATE.Visible |
        //         WPE_VIEW_ACTIVITY_STATE.Focused |
        //         WPE_VIEW_ACTIVITY_STATE.Active
        // );

        import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;

        canvas.onPointerPress ~= (ref e) {
            auto event = createPointerEvent(e.x, e.y);
            event.type = wpe_input_pointer_event_type.wpe_input_pointer_event_type_button;
            event.button = e.button;
            event.state = 1;
            dispatchPointerEvent(&event);
        };

        canvas.onPointerRelease ~= (ref e) {
            auto event = createPointerEvent(e.x, e.y);
            event.type = wpe_input_pointer_event_type.wpe_input_pointer_event_type_button;
            event.button = e.button;
            event.state = 0;
            dispatchPointerEvent(&event);
        };

        canvas.onPointerMove ~= (ref e) {
            auto event = createPointerEvent(e.x, e.y);
            event.type = wpe_input_pointer_event_type.wpe_input_pointer_event_type_motion;
            event.button = e.button;
            dispatchPointerEvent(&event);
        };

        canvas.onPointerWheel ~= (ref e) {
            auto pointerPos = input.pointerPos;
            auto enginePos = toRelEnginePos(pointerPos.x, pointerPos.y);

            wpe_input_axis_event event;
            event.x = enginePos.x;
            event.y = enginePos.y;
            event.time = cast(uint) platform.timer.ticksMs;
            event.value = cast(int)(1 * pixelDensity);
            if (e.y < 0)
            {
                event.value = -event.value;
            }
            event.axis = 0;
            wpe_view_backend_dispatch_axis_event(webViewWpeBackend, &event);
        };

        canvas.onKeyPress ~= (ref e) {
            wpe_input_keyboard_event event = createKeyEvent(true, e);
            wpe_view_backend_dispatch_keyboard_event(webViewWpeBackend, &event);
        };

        canvas.onKeyRelease ~= (ref e) {
            wpe_input_keyboard_event event = createKeyEvent(false, e);
            wpe_view_backend_dispatch_keyboard_event(webViewWpeBackend, &event);
        };

        isLoadLib = true;
    }

    wpe_input_keyboard_event createKeyEvent(bool isPressed, KeyEvent e)
    {
        wpe_input_keyboard_event event;
        event.time = cast(uint) platform.timer.ticksMs;
        event.pressed = isPressed ? 1 : 0;
        event.hardware_key_code = e.scanCode;
        
        import api.dm.com.inputs.com_keyboard : ComKeyName;

        switch (e.keyName)
        {
            case ComKeyName.key_backspace:
                event.key_code = WPE_KEY_BackSpace;
                break;
            case ComKeyName.key_tab:
                event.key_code = WPE_KEY_Tab;
                break;
            case ComKeyName.key_return:
                event.key_code = WPE_KEY_Return;
                break;
            case ComKeyName.key_escape:
                event.key_code = WPE_KEY_Escape;
                break;
            case ComKeyName.key_delete:
                event.key_code = WPE_KEY_Delete;
                break;
            case ComKeyName.key_left:
                event.key_code = WPE_KEY_Left;
                break;
            case ComKeyName.key_up:
                event.key_code = WPE_KEY_Up;
                break;
            case ComKeyName.key_right:
                event.key_code = WPE_KEY_Right;
                break;
            case ComKeyName.key_down:
                event.key_code = WPE_KEY_Down;
                break;
            default:
                event.key_code = e.keyCode;
                break;
        }

        auto keyMod = e.keyMod;
        uint mods;
        if (keyMod.isLeftCtrl || keyMod.isRightCtrl)
        {
            mods |= wpe_input_modifier.wpe_input_keyboard_modifier_control;
        }

        if (keyMod.isLeftShift || keyMod.isRightShift)
        {
            mods |= wpe_input_modifier.wpe_input_keyboard_modifier_shift;
        }

        if (keyMod.isLeftAlt || keyMod.isRightAlt)
        {
            mods |= wpe_input_modifier.wpe_input_keyboard_modifier_alt;
        }

        event.modifiers = mods;
        return event;
    }

    protected wpe_input_pointer_event createPointerEvent(float x, float y)
    {
        auto pos = toRelEnginePos(x, y);
        wpe_input_pointer_event event;
        event.x = pos.x;
        event.y = pos.y;
        event.time = cast(uint) platform.timer.ticksMs;
        return event;
    }

    private Vec2i toRelEnginePos(float x, float y)
    {
        auto dx = (x - canvas.x) * pixelDensity;
        auto dy = (y - canvas.y) * pixelDensity;
        return Vec2i(cast(int) dx, cast(int) dy);
    }

    protected void dispatchPointerEvent(wpe_input_pointer_event* e)
    {
        wpe_view_backend_dispatch_pointer_event(webViewWpeBackend, e);
    }

    void loadHtml(string text, string baseUrl = null)
    {
        assert(webView);
        webkit_web_view_load_html(webView, text.toStringz, baseUrl.length > 0 ? baseUrl.toStringz
                : null);
    }

    void loadUri(string uri)
    {
        assert(webView);
        webkit_web_view_load_uri(webView, uri.toStringz);
    }

    bool isLoading()
    {
        assert(webView);
        return webkit_web_view_is_loading(webView);
    }

    void backgroundColor(RGBA color)
    {
        assert(webView);
        WebKitColor wcolor = toEngineColor(color);
        webkit_web_view_set_background_color(webView, &wcolor);
    }

    protected RGBA fromEngineColor(WebKitColor color)
    {
        return RGBA.fromColorNorm(color.red, color.green, color.blue, color.alpha);
    }

    protected WebKitColor toEngineColor(RGBA color)
    {
        return WebKitColor(color.rNorm, color.gNorm, color.bNorm, color.a);
    }

    string versionInfo()
    {
        import std.format : format;

        if (!wpe_get_major_version)
        {
            throw new Exception("WPE major version function not loaded");
        }

        if (!wpe_fdo_get_major_version)
        {
            throw new Exception("WPE FDO major verion function not loaded");
        }

        return format("WPE %d:%d:%d, FDO: %d:%d:%d", wpe_get_major_version(), wpe_get_minor_version(), wpe_get_micro_version(), wpe_fdo_get_major_version(), wpe_fdo_get_minor_version(), wpe_fdo_get_micro_version());
    }

    override bool draw(float dt)
    {
        super.draw(dt);

        if (!isLoadLib)
        {
            return false;
        }

        go_g_main_context_iteration(null, false);

        PixelBufferData[1] readBuff;
        size_t isRead = pixelBuffer.read(readBuff);
        if (isRead == 0)
        {
            return false;
        }

        PixelBufferData data = readBuff[0];
        if (data.pixels.length > 0)
        {
            scope (exit)
            {
                free(data.pixels.ptr);
            }

            canvas.lock;
            scope (exit)
            {
                canvas.unlock;
            }

            //TODO check texture size == data.size
            //ubyte[] pixels = (cast(ubyte*) canvas.pixels)[0 .. data.pixels.length];
            //pixels[] = data.pixels;

            import core.stdc.string : memmove;

            memmove(canvas.pixels, data.pixels.ptr, data.pixels.length);
        }

        return true;
    }

    override void update(float dt)
    {
        super.update(dt);
    }
}
