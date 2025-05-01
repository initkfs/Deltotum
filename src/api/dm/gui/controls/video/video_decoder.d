module api.dm.gui.controls.video.video_decoder;

import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.core.utils.structs.container_result : ContainerResult;
import api.dm.gui.controls.video.base_media_worker : BaseMediaWorker;

import std.logger : Logger;

import cffmpeg;

struct UVFrame
{
    private
    {
        AVFrame* frame;
    }

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

            SwsContext* convertContext = sws_getContext(
                ctx.width,
                ctx.height,
                ctx.pix_fmt,
                context.windowWidth,
                context.windowHeight,
                AV_PIX_FMT_YUV420P,
                SWS_BILINEAR,
                null,
                null,
                null
            );

            scope (exit)
            {
                sws_freeContext(convertContext);
            }

            logger.trace("Start videodecoder loop");

            while (_running)
            {
                if (packetQueue.isEmpty)
                {
                    //import std;

                    //debug writeln("Packet video queue is empty. Continue");
                    continue;
                }

                if (buffer.isFull)
                {
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

                assert(outFrame.height > 0);
                assert(outFrame.height == context.windowHeight);
                assert(outFrame.width == context.windowWidth);

                assert(outFrame.width <= outFrame.linesize[0]);
                assert(outFrame.linesize[1] == (outFrame.linesize[0] / 2));
                assert(outFrame.linesize[2] == (outFrame.linesize[0] / 2));

                UVFrame uvFrame = UVFrame(outFrame);

                double ptsSec = 0;
                enum ulong AV_NOPTS_VALUE = 0x8000000000000000;
                //TODO precalculate
                if (frame.pts == AV_NOPTS_VALUE)
                {
                    ptsSec = frame.pts * av_q2d(
                        context.videoTimeBase) * context.videoAvgRate.num / context
                        .videoAvgRate.den;
                }
                else
                {
                    ptsSec = frame.pts * av_q2d(context.videoTimeBase);
                }

                uvFrame.ptsSec = ptsSec;

                UVFrame[1] frames = [uvFrame];
                const isWriteUvFrame = buffer.writeSync(frames);
                if (isWriteUvFrame != ContainerResult.success)
                {
                    logger.error("Error writing video frame to buffer: ", isWriteUvFrame);
                }
            }

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
