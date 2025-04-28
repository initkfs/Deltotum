module api.dm.gui.controls.video.video_decoder;

import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.dm.gui.controls.video.base_player_worker : BasePlayerWorker;

import std.logger : Logger;

import cffmpeg;

/**
 * Authors: initkfs
 */
class VideoDecoder(size_t PacketBufferSize, size_t VideoBufferSize) : BasePlayerWorker
{
    AVCodec* codec;
    AVCodecParameters* codecParams;

    RingBuffer!(AVPacket*, PacketBufferSize)* packetQueue;
    RingBuffer!(ubyte, VideoBufferSize)* videoQueue;

    int windowWidth, windowHeight;

    this(Logger logger, AVCodec* codec, AVCodecParameters* codecParams, int windowWidth, int windowHeight)
    {
        super(logger);
        this.windowHeight = windowHeight;
        this.windowWidth = windowWidth;
        this.codec = codec;
        this.codecParams = codecParams;
    }

    override void run()
    {
        logger.trace("Run video decoder");
        // AVCodecContext* decoder_ctx1 = avcodec_alloc_context3(codec);
        // avcodec_open2(decoder_ctx1, codec, NULL);

        AVCodecContext* ctx = avcodec_alloc_context3(codec);

        if (avcodec_parameters_to_context(ctx, codecParams) < 0)
        {
            logger.error("vidCtx");
            return;
        }

        if (avcodec_open2(ctx, codec, null) < 0)
        {
            logger.error("vidCodec");
            //goto clean_codec_context;
            return;
        }

        AVFrame* frame = av_frame_alloc();

        SwsContext* sws_ctx = sws_getContext(
            ctx.width,
            ctx.height,
            ctx.pix_fmt,
            windowWidth,
            windowHeight,
            AV_PIX_FMT_YUV420P,
            SWS_BILINEAR,
            null,
            null,
            null
        );

        AVFrame* outFrame = av_frame_alloc();
        if (outFrame == null)
        {
            logger.error("Err frame");
        }

        //https://stackoverflow.com/questions/35678041/what-is-linesize-alignment-meaning
        int numBytes = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, windowWidth,
            windowHeight, 1);

        ubyte* scaleBuffer = cast(ubyte*) av_malloc(numBytes);

        int res = av_image_fill_arrays(cast(ubyte**) outFrame.data, cast(int*) outFrame.linesize, scaleBuffer, AV_PIX_FMT_YUV420P, windowWidth,
            windowHeight, 1);
        if (res < 0)
        {
            logger.error("Error fillint buffer");
        }

        while (true)
        {
            if (_end)
            {
                avcodec_send_packet(ctx, null);
                continue;
            }

            AVPacket* pkt;
            // packetQueue.read((buff) {
            //     if (buff.length >= 1)
            //     {
            //         pkt = buff[0];
            //         return 1;
            //     }
            // });

            //time_t start = time(NULL);
            //AVERROR_EOF, AVERROR(EAGAIN) == -11
            int isSend = avcodec_send_packet(ctx, pkt);
            if (isSend == FFERRTAG('E', 'O', 'F', ' '))
            {
                break;
            }

            if (isSend < 0 && isSend != AVERROR(EAGAIN))
            {
                return;
            }

            int isReceive = avcodec_receive_frame(ctx, frame);
            if (isReceive == AVERROR(EAGAIN) || isReceive < 0) //|| ret == AVERROR_EOF)
            {
                return;
            }

            //int framenum = ctx.frame_number;
            //if ((framenum % 1000) == 0)
            //{
            // logger.infof("Frame %d (size=%d pts %d dts %d key_frame %d [ codec_picture_number %d, display_picture_number %d\n",
            //     framenum, frame.pkt_size, frame.pts, frame.pkt_dts, frame.key_frame,
            //     frame.coded_picture_number, frame.display_picture_number);
            //}

            // sws_scale(sws_ctx, cast(const(ubyte*)*) frame.data,
            //     cast(const(int)*) frame.linesize, 0, ctx.height,
            //     cast(ubyte**) outFrame.data, cast(const(int*)) outFrame.linesize);

            // assert(outFrame.width <= outFrame.linesize[0]);
            // assert(outFrame.linesize[1] == (outFrame.linesize[0] / 2));
            // assert(outFrame.linesize[2] == (outFrame.linesize[0] / 2));

            // srcFrame = av_frame_alloc();
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
            //  swr_init(tmpSwsContext);
            // scope (exit)
            // {
            //     sws_freeContext(tmpSwsContext);
            // }

            // sws_scale(tmpSwsContext, outFrame.data, outFrame.linesize, 0, outFrame.height,
            //     srcFrame.data, srcFrame.linesize);

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
