module api.dm.lib.wpe.native.types;
/**
 * Authors: initkfs
 */
import core.stdc.stdint;

struct WebKitWebContext;
struct WebKitWebView;
struct wpe_view_backend;
struct WebKitWebViewBackend;
struct WebKitSettings;

struct wpe_fdo_shm_buffer;
struct wpe_fdo_shm_exported_buffer;
struct wpe_view_backend_exportable_fdo;

struct wl_buffer;
struct wl_resource;
struct wl_shm_buffer;

alias GDestroyNotify = void function(gpointer data);
alias gpointer = void*;
alias gchar = char;
alias gboolean = bool;
alias gulong = ulong;
alias gdouble = double;
alias guint32 = uint;
alias gint = int;
struct GMainContext;
struct GMainLoop;

alias GQuark = guint32;

struct GError
{
    GQuark domain;
    gint code;
    gchar* message;
}

struct wpe_view_backend_interface
{
    extern (C)
    {
        void function(void*, wpe_view_backend*) create;
        void function(void*) destroy;

        void function(void*) initialize;
        int function(void*) get_renderer_host_fd;

        void function() _wpe_reserved0;
        void function() _wpe_reserved1;
        void function() _wpe_reserved2;
        void function() _wpe_reserved3;
    }

}

struct wpe_view_backend_exportable_fdo_dmabuf_resource
{
    shared wl_resource* buffer_resource;
    uint32_t width;
    uint32_t height;
    uint32_t format;
    uint8_t n_planes;
    int[4] fds;
    uint32_t[4] strides;
    uint32_t[4] offsets;
    uint64_t[4] modifiers;
}

struct wpe_view_backend_exportable_fdo_client
{
extern (C):

    void function(void* data, wl_resource* buffer_resource) export_buffer_resource;
    void function(void* data, wpe_view_backend_exportable_fdo_dmabuf_resource* dmabuf_resource) export_dmabuf_resource;
    void function(void* data, wpe_fdo_shm_exported_buffer*) export_shm_buffer;

    void function() _wpe_reserved0;
    void function() _wpe_reserved1;
}

enum WebKitLoadEvent
{
    WEBKIT_LOAD_STARTED,
    WEBKIT_LOAD_REDIRECTED,
    WEBKIT_LOAD_COMMITTED,
    WEBKIT_LOAD_FINISHED
}

struct WebKitColor
{
    gdouble red;
    gdouble green;
    gdouble blue;
    gdouble alpha;
}

enum WPE_VIEW_ACTIVITY_STATE
{
    Visible = 1 << 0,
    Focused = 1 << 1,
    Active = 1 << 2
}

enum wpe_input_pointer_event_type
{
    wpe_input_pointer_event_type_null,
    wpe_input_pointer_event_type_motion,
    wpe_input_pointer_event_type_button,
}

struct wpe_input_pointer_event
{
    wpe_input_pointer_event_type type;
    uint32_t time;
    int x;
    int y;
    uint32_t button;
    uint32_t state;
    uint32_t modifiers;
}

enum wpe_input_axis_event_type
{
    wpe_input_axis_event_type_null,
    wpe_input_axis_event_type_motion,
    wpe_input_axis_event_type_motion_smooth,
    wpe_input_axis_event_type_mask_2d = 1 << 16,
}

struct wpe_input_axis_event
{
    wpe_input_axis_event_type type;
    uint32_t time;
    int x;
    int y;
    uint32_t axis;
    int32_t value;
    uint32_t modifiers;
}

enum wpe_input_modifier
{
    wpe_input_keyboard_modifier_control = 1 << 0,
    wpe_input_keyboard_modifier_shift = 1 << 1,
    wpe_input_keyboard_modifier_alt = 1 << 2,
    wpe_input_keyboard_modifier_meta = 1 << 3,

    wpe_input_pointer_modifier_button1 = 1 << 20,
    wpe_input_pointer_modifier_button2 = 1 << 21,
    wpe_input_pointer_modifier_button3 = 1 << 22,
    wpe_input_pointer_modifier_button4 = 1 << 23,
    wpe_input_pointer_modifier_button5 = 1 << 24,
}

struct wpe_input_keyboard_event {
    uint32_t time;
    uint32_t key_code;
    uint32_t hardware_key_code;
    bool pressed;
    uint32_t modifiers;
}