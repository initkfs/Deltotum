module api.dm.gui.controls.video.video_decoder;

import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.core.utils.structs.container_result : ContainerResult;
import api.dm.gui.controls.video.base_media_worker : BaseMediaWorker;

import std.logger : Logger;

import cffmpeg;

struct UVFrame
{
    import Mem = core.memory;

    size_t width;
    size_t height;

    size_t yPitch;
    size_t uPitch;
    size_t vPitch;

    ubyte[] yPlane;
    ubyte[] uPlane;
    ubyte[] vPlane;

    double ptsSec = 0;

    static UVFrame newFrame(size_t w, size_t h, size_t yPitch, size_t uPitch, size_t vPitch)
    {
        assert(w > 0);
        assert(h > 0);

        UVFrame frame = UVFrame(w, h, yPitch, uPitch, vPitch);

        const yPlaneSize = yPitch * h;

        const halfHeight = h / 2;
        const uPlaneSize = uPitch * halfHeight;
        const vPlaneSize = vPitch * halfHeight;

        auto yPlanePtr = cast(ubyte*) Mem.pureMalloc(yPlaneSize);
        assert(yPlanePtr);
        auto uPlanePtr = cast(ubyte*) Mem.pureMalloc(uPlaneSize);
        assert(uPlanePtr);
        auto vPlanePtr = cast(ubyte*) Mem.pureMalloc(vPlaneSize);
        assert(vPlanePtr);

        frame.yPlane = yPlanePtr[0 .. yPlaneSize];
        frame.uPlane = uPlanePtr[0 .. uPlaneSize];
        frame.vPlane = vPlanePtr[0 .. vPlaneSize];
        return frame;
    }

    void free()
    {
        if (yPlane)
        {
            Mem.pureFree(yPlane.ptr);
        }

        if (uPlane)
        {
            Mem.pureFree(uPlane.ptr);
        }

        if (vPlane)
        {
            Mem.pureFree(vPlane.ptr);
        }
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
            AVCodecContext* ctx = avcodec_alloc_context3(context.codec);

            if (avcodec_parameters_to_context(ctx, context.codecParams) < 0)
            {
                logger.error("Error parameters to context");
                return;
            }

            if (avcodec_open2(ctx, context.codec, null) < 0)
            {
                logger.error("Error open video codec");
                //goto clean_codec_context;
                return;
            }

            AVFrame* frame = av_frame_alloc();

            AVFrame* outFrame = av_frame_alloc();
            if (outFrame == null)
            {
                logger.error("Err frame");
            }

            outFrame.width = context.windowWidth;
            outFrame.height = context.windowHeight;
            outFrame.format = AV_PIX_FMT_YUV420P;

            //https://stackoverflow.com/questions/35678041/what-is-linesize-alignment-meaning
            int numBytes = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, context.windowWidth,
                context.windowHeight, 1);

            ubyte* scaleBuffer = cast(ubyte*) av_malloc(numBytes);

            int res = av_image_fill_arrays(cast(ubyte**) outFrame.data, outFrame.linesize.ptr, scaleBuffer, AV_PIX_FMT_YUV420P, context
                    .windowWidth,
                context.windowHeight, 1);
            if (res < 0)
            {
                logger.error("Error fillint buffer");
            }

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

            logger.trace("Start videodecoder loop");

            while (_running)
            {

                // if (_end)
                // {
                //     avcodec_send_packet(ctx, null);
                //     continue;
                // }

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
                const isPacketRead = packetQueue.readSync(pkt);
                if (isPacketRead != ContainerResult.success)
                {
                    import std;

                    debug writeln("Error read video packet from queue: ", isPacketRead);
                }

                //time_t start = time(NULL);
                //AVERROR_EOF, AVERROR(EAGAIN) == -11
                int isSend = avcodec_send_packet(ctx, pkt);
                // if (isSend == FFERRTAG('E', 'O', 'F', ' '))
                // {
                //     break;
                // }

                if (isSend < 0 && isSend != AVERROR(EAGAIN))
                {
                    //import std;

                    //debug writeln("Error send packet to codec");
                    continue;
                }

                int isReceive = avcodec_receive_frame(ctx, frame);
                if (isReceive < 0) //isReceive == AVERROR(EAGAIN) || ret == AVERROR_EOF)
                {
                    import std;

                    char[256] buff = 0;
                    av_strerror(isReceive, buff.ptr, buff.length);
                    debug writeln("Error receive frame from codec: ", buff.fromStringz);
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

                UVFrame uvFrame = UVFrame.newFrame(context.windowWidth, context.windowHeight, outFrame.linesize[0], outFrame
                        .linesize[1], outFrame
                        .linesize[2]);

                double ptsSec = 0;
                enum ulong AV_NOPTS_VALUE = 0x8000000000000000;
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

                uvFrame.yPlane[] = outFrame.data[0][0 .. uvFrame.yPlane.length];
                uvFrame.uPlane[] = outFrame.data[1][0 .. uvFrame.uPlane.length];
                uvFrame.vPlane[] = outFrame.data[2][0 .. uvFrame.vPlane.length];

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
