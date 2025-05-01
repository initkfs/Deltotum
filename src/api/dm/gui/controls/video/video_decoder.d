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

/**
 * Authors: initkfs
 */
class VideoDecoder(size_t PacketBufferSize, size_t VideoBufferSize) : BaseMediaWorker
{
    AVCodec* codec;
    AVCodecParameters* codecParams;

    RingBuffer!(AVPacket*, PacketBufferSize)* packetQueue;
    RingBuffer!(UVFrame, VideoBufferSize)* buffer;

    int windowWidth, windowHeight;

    AVRational videoTimeBase;
    AVRational videoAvgRate;

    this(Logger logger, AVCodec* codec, AVCodecParameters* codecParams, int windowWidth, int windowHeight, typeof(
            packetQueue) newPacketQueue, typeof(
            buffer) newbuffer, AVRational videoTimeBase, AVRational videoAvgRate)
    {
        super(logger);
        this.windowHeight = windowHeight;
        assert(windowHeight > 0);

        this.windowWidth = windowWidth;
        assert(windowWidth > 0);

        assert(newPacketQueue);
        this.packetQueue = newPacketQueue;

        assert(newbuffer);
        this.buffer = newbuffer;

        assert(codec);
        this.codec = codec;

        assert(codecParams);
        this.codecParams = codecParams;

        this.videoTimeBase = videoTimeBase;
        this.videoAvgRate = videoAvgRate;
    }

    override void run()
    {
        logger.trace("Run video decoder");
        // AVCodecContext* decoder_ctx1 = avcodec_alloc_context3(codec);
        // avcodec_open2(decoder_ctx1, codec, NULL);

        AVCodecContext* ctx = avcodec_alloc_context3(codec);

        if (avcodec_parameters_to_context(ctx, codecParams) < 0)
        {
            logger.error("Error parameters to context");
            return;
        }

        if (avcodec_open2(ctx, codec, null) < 0)
        {
            logger.error("Error open video codec");
            //goto clean_codec_context;
            return;
        }

        AVFrame* frame = av_frame_alloc();

        // SwsContext* sws_ctx = sws_getContext(
        //     ctx.width,
        //     ctx.height,
        //     ctx.pix_fmt,
        //     windowWidth,
        //     windowHeight,
        //     AV_PIX_FMT_YUV420P,
        //     SWS_BILINEAR,
        //     null,
        //     null,
        //     null
        // );

        AVFrame* outFrame = av_frame_alloc();
        if (outFrame == null)
        {
            logger.error("Err frame");
        }

        //https://stackoverflow.com/questions/35678041/what-is-linesize-alignment-meaning
        int numBytes = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, windowWidth,
            windowHeight, 1);

        ubyte* scaleBuffer = cast(ubyte*) av_malloc(numBytes);

        int res = av_image_fill_arrays(cast(ubyte**) outFrame.data, outFrame.linesize.ptr, scaleBuffer, AV_PIX_FMT_YUV420P, windowWidth,
            windowHeight, 1);
        if (res < 0)
        {
            logger.error("Error fillint buffer");
        }

        AVFrame* resizedFrame = av_frame_alloc();
        resizedFrame.width = windowWidth;
        resizedFrame.height = windowHeight;
        resizedFrame.format = ctx.pix_fmt;
        av_frame_get_buffer(resizedFrame, 0);

        SwsContext* scaleContext = sws_getContext(
            ctx.width,
            ctx.height,
            ctx.pix_fmt,
            windowWidth,
            windowHeight,
            ctx.pix_fmt,
            SWS_BILINEAR,
            null,
            null,
            null
        );

        SwsContext* convertYUVContext = sws_getContext(
            windowWidth,
            windowHeight,
            ctx.pix_fmt,
            windowWidth,
            windowHeight,
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

            //int framenum = ctx.frame_number;
            //if ((framenum % 1000) == 0)
            //{
            // logger.infof("Frame %d (size=%d pts %d dts %d key_frame %d [ codec_picture_number %d, display_picture_number %d\n",
            //     framenum, frame.pkt_size, frame.pts, frame.pkt_dts, frame.key_frame,
            //     frame.coded_picture_number, frame.display_picture_number);
            //}

            sws_scale(scaleContext, frame.data.ptr,
                frame.linesize.ptr, 0, ctx.height,
                resizedFrame.data.ptr, resizedFrame.linesize.ptr);

            // auto srcFrame = av_frame_alloc();
            // scope (exit)
            // {
            //     av_frame_free(&srcFrame);
            // }
            // srcFrame.format = AV_PIX_FMT_YUV420P;
            // srcFrame.width = outFrame.width;
            // srcFrame.height = outFrame.height;
            // av_frame_get_buffer(srcFrame, 0); //linesize[0]=width

            // SwsContext* tmpSwsContext = sws_getContext(
            //     outFrame.width, outFrame.height, AV_PIX_FMT_YUV420P,
            //     srcFrame.width, srcFrame.height, AV_PIX_FMT_YUV420P,
            //     SWS_BILINEAR, null, null, null
            // );

            // scope (exit)
            // {
            //     sws_freeContext(tmpSwsContext);
            // }

            assert(resizedFrame.height > 0);
            assert(resizedFrame.height == windowHeight);
            assert(resizedFrame.width == windowWidth);

            sws_scale(convertYUVContext, resizedFrame.data.ptr, resizedFrame.linesize.ptr, 0, resizedFrame.height,
                outFrame.data.ptr, outFrame.linesize.ptr);

            assert(outFrame.width <= outFrame.linesize[0]);
            assert(outFrame.linesize[1] == (outFrame.linesize[0] / 2));
            assert(outFrame.linesize[2] == (outFrame.linesize[0] / 2));

            UVFrame uvFrame = UVFrame.newFrame(windowWidth, windowHeight, outFrame.linesize[0], outFrame.linesize[1], outFrame
                    .linesize[2]);

            double ptsSec = 0;
            enum ulong AV_NOPTS_VALUE = 0x8000000000000000;
            if (frame.pts == AV_NOPTS_VALUE)
            {
                ptsSec = frame.pts * av_q2d(videoTimeBase) * videoAvgRate.num / videoAvgRate.den;
            }
            else
            {
               ptsSec = frame.pts * av_q2d(videoTimeBase);
            }

            uvFrame.ptsSec = ptsSec;

            uvFrame.yPlane[] = outFrame.data[0][0 .. uvFrame.yPlane.length];
            uvFrame.uPlane[] = outFrame.data[1][0 .. uvFrame.uPlane.length];
            uvFrame.vPlane[] = outFrame.data[2][0 .. uvFrame.vPlane.length];

            UVFrame[1] frames = [uvFrame];
            const isWriteUvFrame = buffer.writeSync(frames);

            // import std;

            // debug writeln("Send uv frame to video buffer: ", isWriteUvFrame);

            // SDL_UpdateYUVTexture(texture, rect,
            //     srcFrame.data[0], srcFrame.linesize[0],
            //     srcFrame.data[1], srcFrame.linesize[1],
            //     srcFrame.data[2], srcFrame.linesize[2]);

            // time_t end = time(NULL);
            // double diffms = difftime(end, start) / 1000.0;
            // if (diffms < fpsrend)
            // {
            //     uint32_t diff = (uint32_t)((fpsrend - diffms) * 1000);
            //     printf("diffms: %f, delay time %d ms.\n", diffms, diff);
            //     SDL_Delay(diff);
            // }
        }
    }

}
