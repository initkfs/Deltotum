module api.dm.lib.wpe.native.binddynamic;

import core.stdc.stdint;

/**
 * Authors: initkfs
 */
import api.core.utils.libs.multi_dynamic_loader : MultiDynamicLoader;
import api.core.utils.libs.dynamic_loader : DynLib;
import api.dm.lib.wpe.native.types;

gulong go_g_signal_connect(void* instance, char* sig, void* handler, void* data)
{
    return go_g_signal_connect_data(instance, sig, handler, data, null, 0);
}

__gshared extern (C) nothrow
{
    /** 
     * WPE
     */
    bool function(const char* impl_library_name) wpe_loader_init;
    void function(wpe_view_backend*, uint32_t, uint32_t) wpe_view_backend_dispatch_set_size;
    void function(wpe_view_backend*, uint32_t) wpe_view_backend_add_activity_state;
    uint function() wpe_get_major_version;
    uint function() wpe_get_minor_version;
    uint function() wpe_get_micro_version;

    /** 
     * Webkit
     */

    WebKitWebContext* function() webkit_web_context_get_default;
    WebKitWebViewBackend* function(wpe_view_backend* backend, GDestroyNotify notify, gpointer user_data) webkit_web_view_backend_new;
    WebKitWebView* function(WebKitWebViewBackend* backend) webkit_web_view_new;
    WebKitWebView* function(WebKitWebViewBackend* backend, WebKitWebContext* context) webkit_web_view_new_with_context;
    gboolean function(WebKitWebView* web_view) webkit_web_view_is_loading;
    void function(WebKitWebView* web_view, WebKitColor* color) webkit_web_view_set_background_color;
    void function(WebKitWebView* web_view, const gchar* uri) webkit_web_view_load_uri;
    void function(WebKitWebView* web_view, const gchar* content, const gchar* base_uri) webkit_web_view_load_html;
    void function(WebKitWebView* web_view, const gchar* plain_text) webkit_web_view_load_plain_text;
    void function(WebKitWebView* web_view, gdouble zoom_level) webkit_web_view_set_zoom_level;
    WebKitSettings *  function(WebKitWebView             *web_view) webkit_web_view_get_settings;
    /** 
     * FDO
     */
    shared(wpe_view_backend_exportable_fdo*) function(
        const wpe_view_backend_exportable_fdo_client*, void*, uint width, uint height) wpe_view_backend_exportable_fdo_create;
    wpe_view_backend* function(shared wpe_view_backend_exportable_fdo*) wpe_view_backend_exportable_fdo_get_view_backend;
    bool function() wpe_fdo_initialize_shm;
    wl_shm_buffer* function(wpe_fdo_shm_exported_buffer*) wpe_fdo_shm_exported_buffer_get_shm_buffer;
    void function(shared wpe_view_backend_exportable_fdo*, wpe_fdo_shm_exported_buffer*) wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer;
    void function(wpe_view_backend_exportable_fdo*, wl_resource*) wpe_view_backend_exportable_fdo_dispatch_release_buffer;
    void function(shared wpe_view_backend_exportable_fdo*) wpe_view_backend_exportable_fdo_dispatch_frame_complete;
    void function(shared wpe_view_backend_exportable_fdo*) wpe_view_backend_exportable_fdo_destroy;
    uint function() wpe_fdo_get_major_version;
    uint function() wpe_fdo_get_minor_version;
    uint function() wpe_fdo_get_micro_version;
    void function(wpe_view_backend*, wpe_input_pointer_event*) wpe_view_backend_dispatch_pointer_event;
    void function(wpe_view_backend*, wpe_input_axis_event*) wpe_view_backend_dispatch_axis_event;
    void function(wpe_view_backend*, wpe_input_keyboard_event*) wpe_view_backend_dispatch_keyboard_event;
    /** 
     * Gobject
     */
    void function() go_g_type_init;
    gboolean function(GMainContext* context, gboolean may_block) go_g_main_context_iteration;
    gulong function(
        void* instance,
        char* signalName,
        void* handler,
        void* data,
        void* destroy_data,
        int connect_flags
    ) go_g_signal_connect_data;

    /** 
     * Wayland
     */
    int32_t function(wl_shm_buffer* buffer) wl_wl_shm_buffer_get_stride;
    void* function(wl_shm_buffer* buffer) wl_wl_shm_buffer_get_data;
    int32_t function(wl_shm_buffer* buffer) wl_wl_shm_buffer_get_width;
    int32_t function(wl_shm_buffer* buffer) wl_wl_shm_buffer_get_height;
}

class WpeWebkitLib : MultiDynamicLoader
{
    bool isInit;

    protected
    {

    }

    override void bindAll(const(char[]) name, ref DynLib lib)
    {
        if (name == "libwpe-1.0")
        {
            bind(lib, &wpe_loader_init, "wpe_loader_init");
            bind(lib, &wpe_view_backend_dispatch_set_size, "wpe_view_backend_dispatch_set_size");
            bind(lib, &wpe_view_backend_add_activity_state, "wpe_view_backend_add_activity_state");
            bind(lib, &wpe_get_major_version, "wpe_get_major_version");
            bind(lib, &wpe_get_minor_version, "wpe_get_minor_version");
            bind(lib, &wpe_get_micro_version, "wpe_get_micro_version");
            bind(lib, &wpe_view_backend_dispatch_pointer_event, "wpe_view_backend_dispatch_pointer_event");
            bind(lib, &wpe_view_backend_dispatch_axis_event, "wpe_view_backend_dispatch_axis_event");
            bind(lib, &wpe_view_backend_dispatch_keyboard_event, "wpe_view_backend_dispatch_keyboard_event");
        }

        if (name == "libWPEWebKit-1.0")
        {
            bind(lib, &webkit_web_context_get_default, "webkit_web_context_get_default");
            bind(lib, &webkit_web_view_backend_new, "webkit_web_view_backend_new");
            bind(lib, &webkit_web_view_new, "webkit_web_view_new");
            bind(lib, &webkit_web_view_new_with_context, "webkit_web_view_new_with_context");

            bind(lib, &webkit_web_view_is_loading, "webkit_web_view_is_loading");
            bind(lib, &webkit_web_view_set_background_color, "webkit_web_view_set_background_color");

            bind(lib, &webkit_web_view_load_uri, "webkit_web_view_load_uri");
            bind(lib, &webkit_web_view_load_html, "webkit_web_view_load_html");
            bind(lib, &webkit_web_view_load_plain_text, "webkit_web_view_load_plain_text");
            bind(lib, &webkit_web_view_set_zoom_level, "webkit_web_view_set_zoom_level");
            bind(lib, &webkit_web_view_get_settings, "webkit_web_view_get_settings");
        }

        if (name == "libWPEBackend-fdo-1.0")
        {
            bind(lib, &wpe_view_backend_exportable_fdo_create, "wpe_view_backend_exportable_fdo_create");
            bind(lib, &wpe_view_backend_exportable_fdo_get_view_backend, "wpe_view_backend_exportable_fdo_get_view_backend");
            bind(lib, &wpe_fdo_initialize_shm, "wpe_fdo_initialize_shm");
            bind(lib, &wpe_fdo_shm_exported_buffer_get_shm_buffer, "wpe_fdo_shm_exported_buffer_get_shm_buffer");
            bind(lib, &wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer, "wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer");
            bind(lib, &wpe_view_backend_exportable_fdo_dispatch_release_buffer, "wpe_view_backend_exportable_fdo_dispatch_release_buffer");
            bind(lib, &wpe_view_backend_exportable_fdo_dispatch_frame_complete, "wpe_view_backend_exportable_fdo_dispatch_frame_complete");
            bind(lib, &wpe_view_backend_exportable_fdo_destroy, "wpe_view_backend_exportable_fdo_destroy");
            bind(lib, &wpe_fdo_get_major_version, "wpe_fdo_get_major_version");
            bind(lib, &wpe_fdo_get_minor_version, "wpe_fdo_get_minor_version");
            bind(lib, &wpe_fdo_get_micro_version, "wpe_fdo_get_micro_version");
        }

        if (name == "libgobject-2.0")
        {
            bind(lib, &go_g_type_init, "g_type_init");
            bind(lib, &go_g_main_context_iteration, "g_main_context_iteration");
            bind(lib, &go_g_signal_connect_data, "g_signal_connect_data");
        }

        if (name == "libwayland-server")
        {
            bind(lib, &wl_wl_shm_buffer_get_stride, "wl_shm_buffer_get_stride");
            bind(lib, &wl_wl_shm_buffer_get_data, "wl_shm_buffer_get_data");
            bind(lib, &wl_wl_shm_buffer_get_width, "wl_shm_buffer_get_width");
            bind(lib, &wl_wl_shm_buffer_get_height, "wl_shm_buffer_get_height");
        }

    }

    version (Windows)
    {
        const(char)[][1] paths = [
            "libwpe-1.0.dll"
        ];
    }
    else version (OSX)
    {
        const(char)[][1] paths = [
            "libwpe-1.0.dylib"
        ];
    }
    else version (Posix)
    {
        const(char)[][5] paths = [
            "libwpe-1.0.so", "libWPEWebKit-1.0.so", "libgobject-2.0.so",
            "libWPEBackend-fdo-1.0.so", "libwayland-server.so"
        ];
    }
    else
    {
        const(char)[0][0] paths;
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override int libVersion()
    {
        return 0;
    }

    override string libVersionStr()
    {
        return null;
    }

    bool initialize(out string error)
    {
        return false;
    }

}
