module api.dm.lib.ffmpeg.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.dm.lib.ffmpeg.native.types;
import api.core.contexts.libs.dynamics.dynamic_loader : DynamicLoader;
import api.core.contexts.libs.dynamics.dynamic_loader : DynLib;

import std.stdint;

double av_q2d(AVRational a)
{
    return a.num / cast(double) a.den;
}

__gshared extern (C) nothrow
{
    //libavutil
    int function(int errnum, char* errbuf, size_t errbuf_size) av_strerror;
    AVFrame* function() av_frame_alloc;
    int function(AVFrame* dst, const AVFrame* src) av_frame_ref;
    void function(AVFrame** src) av_frame_free;
    void function(AVFrame* frame) av_frame_unref;
    int64_t function() av_gettime_relative;

    int function(void* obj, const char* name, const char* val, int search_flags) av_opt_set;
    int function(void* obj, const char* name, int64_t val, int search_flags) av_opt_set_int;
    int function(void* obj, const char* name, double val, int search_flags) av_opt_set_double;
    int function(void* obj, void* av_log_obj, int req_flags, int rej_flags) av_opt_show2;

    const(char*) function(AVPixelFormat pix_fmt) av_get_pix_fmt_name;

    char* function(const char* s) av_strdup;

    AVSampleFormat function(AVSampleFormat sample_fmt) av_get_packed_sample_fmt;
    int function(AVSampleFormat sample_fmt) av_sample_fmt_is_planar;
    int function(AVSampleFormat sample_fmt) av_get_bytes_per_sample;
    const(char*) function(AVSampleFormat sample_fmt) av_get_sample_fmt_name;
    //TODO av_freep
    int function(uint8_t** audio_data, int* linesize, int nb_channels,
        int nb_samples, AVSampleFormat sample_fmt, int _align) av_samples_alloc;
    int function(const AVChannelLayout* channel_layout, char* buf, size_t buf_size) av_channel_layout_describe;

    void function(int arg) av_log_set_flags;
    void function(int level) av_log_set_level;

    //libavcodec
    AVPacket* function() av_packet_alloc;
    void function(AVPacket**) av_packet_free;
    void function(AVPacket*) av_packet_unref;
    int function(AVPacket* dst, const AVPacket* src) av_packet_ref;
    AVCodecContext* function(const AVCodec* codec) avcodec_alloc_context3;
    void function(AVCodecContext** avctx) avcodec_free_context;
    int function(AVCodecContext* avctx, const AVCodec* codec, AVDictionary** options) avcodec_open2;
    int function(AVCodecContext* codec,
        const AVCodecParameters* par) avcodec_parameters_to_context;
    int function(AVCodecContext* avctx, const AVPacket* avpkt) avcodec_send_packet;
    int function(AVCodecContext* avctx,
        AVFrame* frame) avcodec_receive_frame;
    int function(AVFrame* frame, int _align) av_frame_get_buffer;
    AVCodec* function(AVCodecID id) avcodec_find_decoder;

    //libavformat
    int function(AVFormatContext* s, AVPacket* pkt) av_read_frame;
    AVFormatContext* function() avformat_alloc_context;
    int function(AVFormatContext** ps, const char* url,
        const AVInputFormat* fmt, AVDictionary** options) avformat_open_input;
    void function(AVFormatContext* ic,
        int index,
        const char* url,
        int is_output) av_dump_format;
    int function(AVFormatContext* ic, AVDictionary** options) avformat_find_stream_info;

    //libswscale
    SwsContext* function(int srcW, int srcH, AVPixelFormat srcFormat,
        int dstW, int dstH, AVPixelFormat dstFormat,
        int flags, SwsFilter* srcFilter,
        SwsFilter* dstFilter, const double* param) sws_getContext;
    void function(SwsContext* swsContext) sws_freeContext;
    // int function(SwsContext* c, const uint8_t*[] srcSlice,
    //     const int[] srcStride, int srcSliceY, int srcSliceH,
    //     const uint8_t*[] dst, const int[] dstStride) sws_scale;

    int function(SwsContext* c, const uint8_t** srcSlice,
        const int* srcStride, int srcSliceY, int srcSliceH,
        const uint8_t** dst, const int* dstStride) sws_scale;

    //libavfilter
    AVFilterGraph* function() avfilter_graph_alloc;
    void function(AVFilterGraph** graph) avfilter_graph_free;
    AVFilter* function(const char* name) avfilter_get_by_name;

    int function(AVFilterContext** filt_ctx, const AVFilter* filt,
        const char* name, const char* args, void* opaque,
        AVFilterGraph* graph_ctx) avfilter_graph_create_filter;
    AVFilterContext* function(AVFilterGraph* graph,
        const AVFilter* filter,
        const char* name) avfilter_graph_alloc_filter;
    int function(AVFilterContext* ctx, AVDictionary** options) avfilter_init_dict;
    AVFilterInOut* function() avfilter_inout_alloc;
    void function(AVFilterInOut** _inout) avfilter_inout_free;
    int function(AVFilterContext* src, uint srcpad,
        AVFilterContext* dst, uint dstpad) avfilter_link;
    int function(AVFilterGraph* graphctx, void* log_ctx) avfilter_graph_config;
    int function(AVFilterContext* buffer_src,
        AVFrame* frame, int flags) av_buffersrc_add_frame_flags;
    int function(AVFilterContext* ctx, AVFrame* frame) av_buffersink_get_frame;

    //libswresample
    int function(SwrContext** ps, const AVChannelLayout* out_ch_layout, AVSampleFormat out_sample_fmt, int out_sample_rate, const AVChannelLayout* in_ch_layout, AVSampleFormat in_sample_fmt, int in_sample_rate,
        int log_offset, void* log_ctx) swr_alloc_set_opts2;
    void function(SwrContext** s) swr_free;
    int function(SwrContext* s) swr_init;
    SwrContext* function() swr_alloc;
    // int function(SwrContext* s, const uint8_t* _out, int out_count,
    //     const uint8_t* _in, int in_count) swr_convert;
    int function(SwrContext* s, const uint8_t** _out, int out_count,
        uint8_t** _in, int in_count) swr_convert;

}

class FfmpegLib : DynamicLoader
{
    override void bindAll(ref DynLib lib)
    {
        if (lib.name == "libavutil")
        {
            bind(lib, &av_strerror, "av_strerror");
            bind(lib, &av_frame_alloc, "av_frame_alloc");
            bind(lib, &av_frame_free, "av_frame_free");
            bind(lib, &av_frame_unref, "av_frame_unref");
            bind(lib, &av_gettime_relative, "av_gettime_relative");

            bind(lib, &av_opt_set, "av_opt_set");
            bind(lib, &av_opt_set_int, "av_opt_set_int");
            bind(lib, &av_opt_set_double, "av_opt_set_double");
            bind(lib, &av_opt_show2, "av_opt_show2");

            bind(lib, &av_get_pix_fmt_name, "av_get_pix_fmt_name");

            bind(lib, &av_strdup, "av_strdup");

            bind(lib, &av_get_packed_sample_fmt, "av_get_packed_sample_fmt");
            bind(lib, &av_sample_fmt_is_planar, "av_sample_fmt_is_planar");
            bind(lib, &av_get_bytes_per_sample, "av_get_bytes_per_sample");
            bind(lib, &av_get_sample_fmt_name, "av_get_sample_fmt_name");
            bind(lib, &av_samples_alloc, "av_samples_alloc");
            bind(lib, &av_channel_layout_describe, "av_channel_layout_describe");

            bind(lib, &av_log_set_flags, "av_log_set_flags");
            bind(lib, &av_log_set_level, "av_log_set_level");

            return;
        }

        if (lib.name == "libavcodec")
        {
            bind(lib, &av_packet_alloc, "av_packet_alloc");
            bind(lib, &av_packet_free, "av_packet_free");
            bind(lib, &av_packet_ref, "av_packet_ref");
            bind(lib, &av_packet_unref, "av_packet_unref");
            bind(lib, &avcodec_alloc_context3, "avcodec_alloc_context3");
            bind(lib, &avcodec_free_context, "avcodec_free_context");
            bind(lib, &avcodec_open2, "avcodec_open2");
            bind(lib, &avcodec_parameters_to_context, "avcodec_parameters_to_context");
            bind(lib, &avcodec_send_packet, "avcodec_send_packet");
            bind(lib, &avcodec_receive_frame, "avcodec_receive_frame");
            bind(lib, &av_frame_get_buffer, "av_frame_get_buffer");
            bind(lib, &avcodec_find_decoder, "avcodec_find_decoder");
            return;
        }

        if (lib.name == "libavformat")
        {
            bind(lib, &av_read_frame, "av_read_frame");
            bind(lib, &avformat_alloc_context, "avformat_alloc_context");
            bind(lib, &avformat_open_input, "avformat_open_input");
            bind(lib, &av_dump_format, "av_dump_format");
            bind(lib, &avformat_find_stream_info, "avformat_find_stream_info");
            return;
        }

        if (lib.name == "libswscale")
        {
            bind(lib, &sws_getContext, "sws_getContext");
            bind(lib, &sws_freeContext, "sws_freeContext");
            bind(lib, &sws_scale, "sws_scale");
        }

        if (lib.name == "libavfilter")
        {
            bind(lib, &avfilter_graph_alloc, "avfilter_graph_alloc");
            bind(lib, &avfilter_graph_free, "avfilter_graph_free");
            bind(lib, &avfilter_get_by_name, "avfilter_get_by_name");
            bind(lib, &avfilter_graph_create_filter, "avfilter_graph_create_filter");
            bind(lib, &avfilter_graph_alloc_filter, "avfilter_graph_alloc_filter");
            bind(lib, &avfilter_init_dict, "avfilter_init_dict");
            bind(lib, &avfilter_inout_alloc, "avfilter_inout_alloc");
            bind(lib, &avfilter_inout_free, "avfilter_inout_free");
            bind(lib, &avfilter_link, "avfilter_link");
            bind(lib, &avfilter_graph_config, "avfilter_graph_config");
            bind(lib, &av_buffersrc_add_frame_flags, "av_buffersrc_add_frame_flags");
            bind(lib, &av_buffersink_get_frame, "av_buffersink_get_frame");
        }

        if (lib.name == "libswresample")
        {
            bind(lib, &swr_alloc_set_opts2, "swr_alloc_set_opts2");
            bind(lib, &swr_free, "swr_free");
            bind(lib, &swr_init, "swr_init");
            bind(lib, &swr_alloc, "swr_alloc");
            bind(lib, &swr_convert, "swr_convert");
        }
    }

    override string[] libPaths()
    {
        version (Windows)
        {
            string[] paths = [
                "libavfilter.dll", "libavformat.dll",
                "libswresample.dll", "libswscale.dll", "libavcodec.dll",
                "libavutil.dll"
            ];
        }
        else version (OSX)
        {
            string[] paths = [
                "libavfilter.dylib", "libavformat.dylib",
                "libswresample.dylib", "libswscale.dylib", "libavcodec.dylib",
                "libavutil.dylib"
            ];
        }
        else version (Posix)
        {
            string[] paths = [
                "libavfilter.so", "libavformat.so",
                "libswresample.so", "libswscale.so", "libavcodec.so",
                "libavutil.so"
            ];
        }
        else
        {
            string[] paths;
        }
        return paths;
    }
}
