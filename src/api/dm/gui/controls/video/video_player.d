module api.dm.gui.controls.video.video_player;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import core.sync.mutex : Mutex;
import core.sync.condition : Condition;

import cffmpeg;
import csdl;

/**
 * Authors: initkfs
 */
class VideoPlayer : Control
{

    this()
    {
        initSize(300, 200);
        isDrawBounds = true;
    }

    Texture2d texture;

    AVFormatContext* pFormatCtx;
    AVPacket* packet;
    AVCodecContext* vidCtx, audCtx;
    AVFrame* vframe, aframe, outFrame;
    double fpsrendering = 0.0;
    AVCodec* vidCodec, audCodec;
    AVCodecParameters* vidpar, audpar;

    SDL_AudioDeviceID auddev;

    int swidth, sheight;
    SDL_Rect rect;

    int vidId = -1, audId = -1;

    SwsContext* sws_ctx;

    ubyte* scaleBuffer;

    override void create()
    {
        super.create;

        import std;

        char* file = cast(char*) "/home/user/sdl-music/sw.wmv".toStringz;

        //sdl part

        pFormatCtx = avformat_alloc_context();

        if (avformat_open_input(&pFormatCtx, file, null, null) != 0)
        {
            logger.error("Error ffmpeg file");
            return;
        }

        av_dump_format(pFormatCtx, 0, file, 0);

        if (avformat_find_stream_info(pFormatCtx, null) < 0)
        {
            logger.error("Cannot find stream info. Quitting.");
            return;
        }

        bool foundVideo = false, foundAudio = false;

        for (int i = 0; i < pFormatCtx.nb_streams; i++)
        {
            AVCodecParameters* localparam = pFormatCtx.streams[i].codecpar;
            AVCodec* localcodec = avcodec_find_decoder(localparam.codec_id);
            if (localparam.codec_type == AVMEDIA_TYPE_VIDEO && !foundVideo)
            {
                vidCodec = localcodec;
                vidpar = localparam;
                vidId = i;
                AVRational rational = pFormatCtx.streams[i].avg_frame_rate;
                fpsrendering = 1.0 / (cast(double) rational.num / cast(double)(rational.den));
                foundVideo = true;
            }
            else if (localparam.codec_type == AVMEDIA_TYPE_AUDIO && !foundAudio)
            {
                audCodec = localcodec;
                audpar = localparam;
                audId = i;
                foundAudio = true;
            }
            if (foundVideo && foundAudio)
            {
                break;
            }
        }

        vidCtx = avcodec_alloc_context3(vidCodec);
        audCtx = avcodec_alloc_context3(audCodec);
        if (avcodec_parameters_to_context(vidCtx, vidpar) < 0)
        {
            logger.error("vidCtx");
            return;
        }

        if (avcodec_parameters_to_context(audCtx, audpar) < 0)
        {
            logger.error("audCtx");
            return;
        }

        if (avcodec_open2(vidCtx, vidCodec, null) < 0)
        {
            logger.error("vidCtx");
            //goto clean_codec_context;
            return;
        }

        if (avcodec_open2(audCtx, audCodec, null) < 0)
        {
            logger.error("audCtx");
            //goto clean_codec_context;
            return;
        }

        vframe = av_frame_alloc();
        aframe = av_frame_alloc();

        //data_size + AV_INPUT_BUFFER_PADDING_SIZE
        packet = av_packet_alloc();

        swidth = vidpar.width;
        sheight = vidpar.height;

        rect.x = 0;
        rect.y = 0;
        rect.w = swidth;
        rect.h = sheight;

        texture = new Texture2d(width, height);
        addCreate(texture);
        texture.createMutYV;

        sws_ctx = sws_getContext(
            vidCtx.width,
            vidCtx.height,
            vidCtx.pix_fmt,
            cast(int) texture.width,
            cast(int) texture.height,
            AV_PIX_FMT_YUV420P,
            SWS_BILINEAR,
            null,
            null,
            null
        );

        outFrame = av_frame_alloc();
        if (outFrame == null)
        {
            logger.error("Err frame");
        }

        // ubyte* buffer = null;
        int numBytes;
        //https://stackoverflow.com/questions/35678041/what-is-linesize-alignment-meaning
        numBytes = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, cast(int) texture.width,
            cast(int) texture.height, 1);

        scaleBuffer = cast(ubyte*) av_malloc(numBytes);

        int res = av_image_fill_arrays(cast(ubyte**) outFrame.data, cast(int*) outFrame.linesize, scaleBuffer, AV_PIX_FMT_YUV420P, cast(
                int) texture.width,
            cast(int) texture.height, 1);
        if (res < 0)
        {
            logger.error("Error fillint buffer");
        }

        auddev = cast(SDL_AudioDeviceID) media.audioOut.id;

    }

    override void update(double dt)
    {
        super.update(dt);

        if (av_read_frame(pFormatCtx, packet) >= 0)
        {
            if (packet.stream_index == vidId)
            {
                import api.dm.com.com_native_ptr : ComNativePtr;

                ComNativePtr ptr;

                auto isRes = texture.nativeTexture.nativePtr(ptr);

                display(vidCtx, packet, vframe, &rect,
                    cast(SDL_Texture*) ptr.ptr, fpsrendering);

            }
            else if (packet.stream_index == audId)
            {
                playaudio(audCtx, packet, aframe, auddev);

            }

            av_packet_unref(packet);
        }
    }

    void display(AVCodecContext* ctx, AVPacket* pkt, AVFrame* frame, SDL_Rect* rect,
        SDL_Texture* texture, double fpsrend)
    {
        //time_t start = time(NULL);
        //AVERROR_EOF, AVERROR(EAGAIN) == -11
        int isSend = avcodec_send_packet(ctx, pkt);
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

        sws_scale(sws_ctx, cast(const(ubyte*)*) frame.data,
            cast(const(int)*) frame.linesize, 0, vidCtx.height,
            cast(ubyte**) outFrame.data, cast(const(int*)) outFrame.linesize);

        AVFrame* srcFrame = outFrame;

        assert(outFrame.width <= outFrame.linesize[0]);
        assert(outFrame.linesize[1] == (outFrame.linesize[0] / 2));
        assert(outFrame.linesize[2] == (outFrame.linesize[0] / 2));

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
        // scope (exit)
        // {
        //     sws_freeContext(tmpSwsContext);
        // }

        // sws_scale(tmpSwsContext, outFrame.data, outFrame.linesize, 0, outFrame.height,
        //     srcFrame.data, srcFrame.linesize);

        SDL_UpdateYUVTexture(texture, rect,
            srcFrame.data[0], srcFrame.linesize[0],
            srcFrame.data[1], srcFrame.linesize[1],
            srcFrame.data[2], srcFrame.linesize[2]);

        // time_t end = time(NULL);
        // double diffms = difftime(end, start) / 1000.0;
        // if (diffms < fpsrend)
        // {
        //     uint32_t diff = (uint32_t)((fpsrend - diffms) * 1000);
        //     printf("diffms: %f, delay time %d ms.\n", diffms, diff);
        //     SDL_Delay(diff);
        // }
    }

    void playaudio(AVCodecContext* ctx, AVPacket* pkt, AVFrame* frame,
        SDL_AudioDeviceID auddev)
    {
        // if (avcodec_send_packet(ctx, pkt) < 0)
        // {
        //     logger.error("send packet");
        //     return;
        // }
        // if (avcodec_receive_frame(ctx, frame) < 0)
        // {
        //     logger.error("receive frame");
        //     return;
        // }

        // int size;

        // AVChannelLayout chLayout = ctx.ch_layout;

        // int bufsize = av_samples_get_buffer_size(&size, chLayout.nb_channels,
        //     frame.nb_samples, ctx.sample_fmt, 0);
        // bool isplanar = av_sample_fmt_is_planar(ctx.sample_fmt) == 1;
        // for (int ch = 0; ch < chLayout.nb_channels; ch++)
        // {
        //     if (!isplanar)
        //     {
        //         if (SDL_QueueAudio(auddev, frame.data[ch], frame.linesize[ch]) < 0)
        //         {
        //             logger.error("playaudio");
        //             return;
        //         }
        //     }
        //     else
        //     {
        //         if (SDL_QueueAudio(auddev, frame.data[0] + size * ch, size) < 0)
        //         {
        //             logger.error("playaudio 2");
        //             return;
        //         }
        //     }
        // }
    }

    //AVCodecParameters* pCodecParams = null;
    //AVCodecContext* pCodecCtx = null;
    //avcodec_free_context

    // int videoStream = -1;
    // for (i = 0; i < pFormatCtx.nb_streams; i++)
    //     if (pFormatCtx.streams[i].codecpar.codec_type == AVMEDIA_TYPE_VIDEO)
    //     {
    //         videoStream = i;
    //         break;
    //     }

    // if (videoStream == -1)
    // {
    //     logger.error("Not found video stream");
    // }

    // pCodecParams = pFormatCtx.streams[videoStream].codecpar;

    // AVCodec* pCodec = null;

    // pCodec = avcodec_find_decoder(pCodecParams.codec_id);
    // if (!pCodec)
    // {
    //     logger.error("Unsupported codec.");
    //     return;
    // }

    // pCodecCtx = avcodec_alloc_context3(pCodec);

    // if (avcodec_parameters_to_context(pCodecCtx, pCodecParams) < 0)
    // {
    //     logger.error("Couldn't copy codec context");
    //     return;
    // }

    // if (avcodec_open2(pCodecCtx, pCodec, null) != 0)
    // {
    //     logger.error("Could not open codec");
    //     return;
    // }

    // SwsContext* sws_ctx = sws_getContext(
    //     pCodecCtx.width,
    //     pCodecCtx.height,
    //     pCodecCtx.pix_fmt,
    //     pCodecCtx.width,
    //     pCodecCtx.height,
    //     AV_PIX_FMT_YUV420P,
    //     SWS_BILINEAR,
    //     null,
    //     null,
    //     null
    // );

    // yPlaneSz = pCodecCtx.width * pCodecCtx.height;
    // uvPlaneSz = pCodecCtx.width * pCodecCtx.height / 4;
    // yPlane = cast(ubyte*) malloc(yPlaneSz);
    // uPlane = cast(ubyte*) malloc(uvPlaneSz);
    // vPlane = cast(ubyte*) malloc(uvPlaneSz);

    // uvPitch = pCodecCtx.width / 2;

    // AVPacket packet;

    // while (av_read_frame(pFormatCtx, &packet) >= 0)
    // {
    //     if (packet.stream_index == videoStream)
    //     {
    //         auto isSend = avcodec_send_packet(pCodecCtx, &packet);
    //         if (isSend != 0)
    //         {
    //             throw new Exception("Err send frame");
    //         }

    //         auto isReceive = avcodec_receive_frame(pCodecCtx, pFrame);
    //         if (isReceive != 0)
    //         {
    //             throw new Exception("Err rec framce");
    //         }

    //         sws_scale(sws_ctx, cast(const(ubyte*)*) pFrame.data,
    //             cast(const(int)*) pFrame.linesize, 0, pCodecCtx.height,
    //             cast(ubyte**) pFrameRGB.data, cast(const(int*)) pFrameRGB.linesize);

    //     }

    //     //av_free_packet(&packet);
    //     av_packet_unref(&packet);
    // }

    // AVFrame* pFrame = av_frame_alloc();

    // auto pFrameRGB = av_frame_alloc();
    // if (pFrameRGB == null)
    // {
    //     logger.error("Err frame");
    // }

    // ubyte* buffer = null;
    // int numBytes;
    // //https://stackoverflow.com/questions/35678041/what-is-linesize-alignment-meaning
    // numBytes = av_image_get_buffer_size(AV_PIX_FMT_RGB24, pCodecCtx.width,
    //     pCodecCtx.height, 1);

    // buffer = cast(ubyte*) av_malloc(numBytes * ubyte.sizeof);

    // int res = av_image_fill_arrays(cast(ubyte**) pFrame.data, cast(int*) pFrame.linesize, buffer, AV_PIX_FMT_RGB24, pCodecCtx
    //         .width, pCodecCtx.height, 1);
    // if (res < 0)
    // {
    //     logger.error("Error fillint buffer");
    // }

    //av_free(buffer);
    //av_free(pFrameRGB);
    //av_free(pFrame);

    // avcodec_free_context(&pCodecCtx);
    // avformat_close_input(&pFormatCtx);

    // void readFrame(AVCodecContext* pCodecCtx, int videoStream, AVFrame* pFrame, AVFrame* pFrameRGB)
    // {
    //     SwsContext* sws_ctx = null;

    //     AVPacket packet;

    //     sws_ctx = sws_getContext(
    //         pCodecCtx.width,
    //         pCodecCtx.height,
    //         pCodecCtx.pix_fmt,
    //         pCodecCtx.width,
    //         pCodecCtx.height,
    //         AV_PIX_FMT_RGB24,
    //         SWS_BILINEAR,
    //         null,
    //         null,
    //         null
    //     );

    //     int i = 0;

    //     while (av_read_frame(pFormatCtx, &packet) >= 0)
    //     {
    //         if (packet.stream_index == videoStream)
    //         {
    //             auto isSend = avcodec_send_packet(pCodecCtx, &packet);
    //             if (isSend != 0)
    //             {
    //                 throw new Exception("Err send frame");
    //             }

    //             auto isReceive = avcodec_receive_frame(pCodecCtx, pFrame);
    //             if (isReceive != 0)
    //             {
    //                 throw new Exception("Err rec framce");
    //             }

    //             sws_scale(sws_ctx, cast(const(ubyte*)*) pFrame.data,
    //                 cast(const(int)*) pFrame.linesize, 0, pCodecCtx.height,
    //                 cast(ubyte**) pFrameRGB.data, cast(const(int*)) pFrameRGB.linesize);

    //         }

    //         //av_free_packet(&packet);
    //         av_packet_unref(&packet);
    //     }
    // }

}
