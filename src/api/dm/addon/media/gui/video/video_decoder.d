module api.dm.addon.gui.video.video_decoder;

import api.core.utils.adt.rings.ring_buffer : RingBuffer;
import api.core.utils.adt.container_result : ContainerResult;
import api.dm.addon.gui.video.base_media_worker : BaseMediaWorker;

import std.logger : Logger;
import std.string : fromStringz, toStringz;

import cffmpeg;

struct UVFrame
{
    //private
    //{
    AVFrame* frame;
    //}

    size_t width;
    size_t height;

    size_t yPitch;
    size_t uPitch;
    size_t vPitch;

    ubyte[] yPlane;
    ubyte[] uPlane;
    ubyte[] vPlane;

    double ptsSec = 0;

    this(AVFrame* frame)
    {
        assert(frame);

        this.frame = frame;

        width = frame.width;
        height = frame.height;

        yPitch = frame.linesize[0];
        uPitch = frame.linesize[1];
        vPitch = frame.linesize[2];

        const yPlaneSize = yPitch * height;

        const halfHeight = height / 2;

        const uPlaneSize = uPitch * halfHeight;
        const vPlaneSize = vPitch * halfHeight;

        yPlane = frame.data[0][0 .. yPlaneSize];
        uPlane = frame.data[1][0 .. uPlaneSize];
        vPlane = frame.data[2][0 .. vPlaneSize];
    }

    bool free()
    {
        if (!frame)
        {
            return false;
        }

        av_frame_free(&frame);
        this = UVFrame.init;
        return true;
    }

}

struct VideoDecoderContext
{
    AVCodecParameters* codecParams;
    AVCodec* codec;
    int windowWidth;
    int windowHeight;
    AVRational videoTimeBase;
    AVRational videoAvgRate;
}

/**
 * Authors: initkfs
 */
class VideoDecoder(size_t PacketBufferSize, size_t VideoBufferSize) : BaseMediaWorker
{
    protected
    {
        VideoDecoderContext context;

        RingBuffer!(AVPacket*, PacketBufferSize)* packetQueue;
        RingBuffer!(UVFrame, VideoBufferSize)* buffer;
    }

    this(
        Logger logger,
        VideoDecoderContext context,
        typeof(packetQueue) videoPacketQueue,
        typeof(buffer) audioBuffer,
    )
    {
        super(logger);

        assert(context.windowWidth > 0);
        assert(context.windowHeight > 0);
        assert(context.codec);
        assert(context.codecParams);

        this.context = context;

        assert(videoPacketQueue);
        this.packetQueue = videoPacketQueue;

        assert(audioBuffer);
        this.buffer = audioBuffer;
    }

    AVFilter* colorbalance;
    AVFilterContext* colorbalanceCtx;

    void setColor(double r, double g, double b){
        assert(colorbalanceCtx, "Color balance is null");
        const isSet = av_opt_set_double(colorbalanceCtx, "rm", r, AV_OPT_SEARCH_CHILDREN);
        assert(isSet >= 0, errorText(isSet));
        av_opt_set_double(colorbalanceCtx, "gm", g, AV_OPT_SEARCH_CHILDREN);
        av_opt_set_double(colorbalanceCtx, "bm", b, AV_OPT_SEARCH_CHILDREN);
    }

    override void run()
    {
        try
        {
            logger.trace("Run video decoder");

            AVCodecContext* ctx = avcodec_alloc_context3(context.codec);
            if (!ctx)
            {
                logger.error("Video context is null");
                return;
            }

            scope (exit)
            {
                avcodec_free_context(&ctx);
            }

            const isToCtx = avcodec_parameters_to_context(ctx, context.codecParams);
            if (isToCtx < 0)
            {
                logger.error("Error parameters to context in video decoder: ", errorText(isToCtx));
                return;
            }

            const isOpenCodec = avcodec_open2(ctx, context.codec, null);
            if (isOpenCodec < 0)
            {
                logger.error("Error open video codec: ", errorText(isOpenCodec));
                return;
            }

            AVFrame* frame = av_frame_alloc();
            if (!frame)
            {
                logger.error("Main frame is null");
                return;
            }

            //https://stackoverflow.com/questions/35678041/what-is-linesize-alignment-meaning
            // int numBytes = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, context.windowWidth,
            //     context.windowHeight, 1);

            // ubyte* scaleBuffer = cast(ubyte*) av_malloc(numBytes);

            // int res = av_image_fill_arrays(cast(ubyte**) outFrame.data, outFrame.linesize.ptr, scaleBuffer, AV_PIX_FMT_YUV420P, context
            //         .windowWidth,
            //     context.windowHeight, 1);
            // if (res < 0)
            // {
            //     logger.error("Error fillint buffer");
            // }

            AVPixelFormat destFormat = AV_PIX_FMT_YUV420P;

            SwsContext* convertContext = sws_getContext(
                ctx.width,
                ctx.height,
                ctx.pix_fmt,
                context.windowWidth,
                context.windowHeight,
                destFormat,
                SWS_BILINEAR,
                null,
                null,
                null
            );

            scope (exit)
            {
                sws_freeContext(convertContext);
            }

            AVFilterGraph* graph = avfilter_graph_alloc();
            //avfilter_graph_set_auto_convert(graph, AVFILTER_AUTO_CONVERT_NONE);

            AVFilterContext* srcFilter, sinkFilter;

            AVFilter* bufferSrc = avfilter_get_by_name("buffer");
            if (!bufferSrc)
            {
                logger.error("Error getting src filter buffer");
                return;
            }

            import std.format : format;
            import std.string : toStringz, fromStringz;

            auto args = format("video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d", context.windowWidth, context.windowHeight, destFormat, context
                    .videoTimeBase.num, context.videoTimeBase.den, ctx.sample_aspect_ratio.num, ctx
                    .sample_aspect_ratio.den).toStringz;

            const isNewGraph = avfilter_graph_create_filter(&srcFilter, bufferSrc, "in", args, null, graph);
            if (isNewGraph < 0)
            {
                logger.error("Error creating new filter graph: ", errorText(isNewGraph));
                return;
            }

            AVFilter* bufferSink = avfilter_get_by_name("buffersink");
            if (!bufferSink)
            {
                logger.error("Not found buffer sink",);
                return;
            }

            sinkFilter = avfilter_graph_alloc_filter(graph, bufferSink, "out");
            if (!sinkFilter)
            {
                logger.error("Error create sink filter: ");
                return;
            }

            const isOutFormatSet = av_opt_set(sinkFilter, "pixel_formats", av_get_pix_fmt_name(
                            destFormat).fromStringz.ptr,
                AV_OPT_SEARCH_CHILDREN);
            if (isOutFormatSet < 0)
            {
                logger.error("Error setting out sink format: ", errorText(isOutFormatSet));
            }

            const isInitOutDict = avfilter_init_dict(sinkFilter, null);
            if (isInitOutDict < 0)
            {
                logger.error("Error initialization buffer sink: ", errorText(isInitOutDict));
                return;
            }

            AVFilterInOut* outputs = avfilter_inout_alloc();
            assert(outputs);
            scope (exit)
            {
                avfilter_inout_free(&outputs);
            }

            outputs.name = av_strdup("in");
            outputs.filter_ctx = srcFilter;
            outputs.pad_idx = 0;
            outputs.next = null;

            AVFilterInOut* inputs = avfilter_inout_alloc();
            assert(inputs);
            scope (exit)
            {
                avfilter_inout_free(&inputs);
            }

            inputs.name = av_strdup("out");
            inputs.filter_ctx = sinkFilter;
            inputs.pad_idx = 0;
            inputs.next = null;

            auto filterDescr = "colorbalance=0:0:0,format".toStringz;

            // const isParse = avfilter_graph_parse_ptr(graph, null, &inputs, &outputs, null);
            // if (isParse < 0)
            // {
            //     logger.error("Error parsing filter graph: ", isParse);
            //     return;
            // }

            colorbalance = avfilter_get_by_name("colorbalance");
            assert(colorbalance);

            auto res = avfilter_graph_create_filter(&colorbalanceCtx, colorbalance, "colorbalance", null, null, graph);
            assert(res >= 0);

            av_opt_show2(colorbalanceCtx, null, AV_OPT_FLAG_FILTERING_PARAM, 0);

            AVFilter* formatF = avfilter_get_by_name("format");
            assert(formatF);

            AVFilterContext* formatContext;
            res = avfilter_graph_create_filter(&formatContext, formatF, "format", null, null, graph);
            assert(res >= 0);

            res = avfilter_link(srcFilter, 0, colorbalanceCtx, 0);
            assert(res >= 0, errorText(res));
            avfilter_link(colorbalanceCtx, 0, formatContext, 0);
            avfilter_link(formatContext, 0, sinkFilter, 0);

            //av_opt_set_double(eq_ctx, "rs", 0.5, 0);

            const isConfig = avfilter_graph_config(graph, null);
            if (isConfig < 0)
            {
                logger.error("Error filter config: ", errorText(isConfig));
                return;
            }

            assert(srcFilter);
            assert(sinkFilter);

            scope (exit)
            {
                avfilter_graph_free(&graph);
            }

            logger.trace("Start videodecoder loop");

            int stopCause;

            while (_running)
            {
                if (packetQueue.isEmpty)
                {
                    waitInLoop;
                    //import std;

                    //debug writeln("Packet video queue is empty. Continue");
                    continue;
                }

                if (buffer.isFull)
                {
                    waitInLoop;
                    //import std;

                    //debug writeln("Video buffer is full. Continue");
                    continue;
                }

                AVPacket* pkt;
                try
                {
                    packetQueue.mutex.lock;

                    const isPacketRead = packetQueue.peek(pkt);
                    if (isPacketRead != ContainerResult.success)
                    {
                        logger.error("Error peek video packet from queue: ", isPacketRead);
                        continue;
                    }

                    const isSend = avcodec_send_packet(ctx, pkt);

                    if (isSend == codeEOF)
                    {
                        if (pkt)
                        {
                            packetQueue.removeStrict;
                            av_packet_free(&pkt);
                        }
                        logger.error("EOF in video decoder, break");
                        stopCause = codeEOF;
                        break;
                    }

                    if (isSend < 0 && isSend != AVERROR(EAGAIN))
                    {
                        //TODO drop packet?
                        packetQueue.removeStrict;
                        av_packet_free(&pkt);
                        logger.error("Error sending packet in video decoder: ", errorText(isSend));
                        continue;
                    }

                    const isReceive = avcodec_receive_frame(ctx, frame);
                    if (isReceive == AVERROR(EAGAIN))
                    {
                        continue;
                    }

                    if (isReceive < 0)
                    {
                        logger.error("Error receiving frame in video decoder: ", errorText(
                                isReceive));
                        continue;
                    }

                    packetQueue.removeStrict;
                }
                finally
                {
                    packetQueue.mutex.unlock;
                }

                scope (exit)
                {
                    if (frame)
                    {
                        av_frame_unref(frame);
                    }

                    if (pkt)
                    {
                        av_packet_free(&pkt);
                    }
                }

                //TODO remove alloc
                AVFrame* outFrame = av_frame_alloc();
                if (!outFrame)
                {
                    logger.error("Output frame is null");
                }

                outFrame.width = context.windowWidth;
                outFrame.height = context.windowHeight;
                outFrame.format = AV_PIX_FMT_YUV420P;

                const isOutBuffer = av_frame_get_buffer(outFrame, 1);
                if (isOutBuffer < 0)
                {
                    logger.error("Error getting out frame buffer: ", errorText(isOutBuffer));
                    av_frame_free(&outFrame);
                    continue;
                }

                sws_scale(convertContext, frame.data.ptr, frame.linesize.ptr, 0, frame.height,
                    outFrame.data.ptr, outFrame.linesize.ptr);

                const isSrcKeepRef = av_buffersrc_add_frame_flags(srcFilter, outFrame, AV_BUFFERSRC_FLAG_KEEP_REF);
                if (isSrcKeepRef < 0)
                {
                    logger.error("Error setting keeping src buffer frame ref");
                    continue;
                }
                AVFrame* filterFrame = av_frame_alloc();
                //while, ret == AVERROR(EAGAIN) || ret == AVERROR_EOF break
                const isSinkFilterRet = av_buffersink_get_frame(sinkFilter, filterFrame);
                if (isSinkFilterRet < 0)
                {
                    logger.error("Error sink filter: ", isSinkFilterRet);
                    continue;
                }

                if (filterFrame.format != destFormat)
                {
                    import std.string : toStringz;

                    logger.errorf("Invalid frame format, expected %s, but received %s", av_get_pix_fmt_name(
                            destFormat).fromStringz, av_get_pix_fmt_name(
                            cast(AVPixelFormat) filterFrame.format).fromStringz);
                    return;
                }

                if (filterFrame.width != context.windowWidth || filterFrame.height != context
                    .windowHeight)
                {
                    logger.errorf("Invalid frame size, expected %sx%s, but received %sx%s", context.windowWidth, context
                            .windowHeight, filterFrame.width, filterFrame.height);
                    return;
                }

                const yPitch = frame.linesize[0];
                const halfYPitch = yPitch / 2;
                const uPitch = frame.linesize[1];
                const vPitch = frame.linesize[2];

                if (filterFrame.width > yPitch ||
                    uPitch != halfYPitch ||
                    vPitch != halfYPitch
                    )
                {
                    logger.errorf("Invalid YUV-frame received. Expected w(%s)<=y(%s), u(%s)==y/2(%s), v(%s)==y/2(%s)", filterFrame
                            .width, yPitch, uPitch, halfYPitch, vPitch, halfYPitch);
                    return;
                }

                //assert(filterFrame.width <= filterFrame.linesize[0]);
                //assert(filterFrame.linesize[1] == (filterFrame.linesize[0] / 2));
                //assert(filterFrame.linesize[2] == (filterFrame.linesize[0] / 2));

                UVFrame uvFrame = UVFrame(filterFrame);

                double ptsSec = 0;
                enum ulong AV_NOPTS_VALUE = 0x8000000000000000;
                //TODO precalculate
                if (frame.pts == AV_NOPTS_VALUE)
                {
                    //best_effort_timestamp
                    ptsSec = frame.pts * av_q2d(
                        context.videoTimeBase) * context.videoAvgRate.num / context
                        .videoAvgRate.den;
                }
                else
                {
                    ptsSec = frame.best_effort_timestamp * av_q2d(context.videoTimeBase);
                }

                uvFrame.ptsSec = ptsSec;

                UVFrame[1] frames = [uvFrame];
                const isWriteUvFrame = buffer.writeSync(frames);
                if (isWriteUvFrame != ContainerResult.success)
                {
                    logger.error("Error writing video frame to buffer: ", isWriteUvFrame);
                }
            }

            // if (stopCause == codeEOF)
            // {
            //     logger.trace("Read filter buffer after EOF");

            //     const isSetFrameFlags = av_buffersrc_add_frame_flags(srcFilter, null, 0);
            //     if (isSetFrameFlags < 0)
            //     {
            //         logger.error("Error add frame flags");
            //     }

            //     while (true)
            //     {
            //         av_frame_unref(filteredFrame);

            //         const isGetFrame = av_buffersink_get_frame(srcFilter, filteredFrame);
            //         if (isGetFrame == AVERROR(EAGAIN) || isGetFrame == codeEOF)
            //             break;

            //         if (isGetFrame < 0)
            //         {
            //             logger.error("Error getting frame after EOF: ", errorText(isGetFrame));
            //             break;
            //         }

            //         sendFrameYUV(filteredFrame, destFormat, context);
            //     }
            // }

            logger.trace("Video decoder finished work");
        }

        catch (Exception e)
        {
            logger.error("Exception in video decoder: ", e);
        }

        catch (Throwable th)
        {
            logger.error("Error in video decoder: ", th);
            throw th;
        }
    }
}
