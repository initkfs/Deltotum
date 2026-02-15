module api.dm.addon.media.video.gui.audio_decoder;

import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;
import api.core.utils.queues.ring_buffer : RingBuffer;
import api.dm.addon.media.video.gui.base_media_worker : BaseMediaWorker;
import api.core.utils.container_result : ContainerResult;

import std.logger : Logger;
import std.string : toStringz, fromStringz;

import api.dm.lib.ffmpeg.native;

import core.stdc.errno: EAGAIN;

struct AudioDecoderContext
{
    AVCodec* codec;
    AVCodecParameters* codecParams;
    ComAudioSpec audioOutSpec;
}

/**
 * Authors: initkfs
 */
class AudioDecoder(size_t PacketBufferSize, size_t AudioBufferSize) : BaseMediaWorker
{
    protected
    {
        AudioDecoderContext context;

        RingBuffer!(AVPacket*, PacketBufferSize)* packetQueue;
        RingBuffer!(ubyte, AudioBufferSize)* buffer;
    }

    ComAudioSpec srcSpec;

    this(
        Logger logger,
        AudioDecoderContext context,
        typeof(packetQueue) audioPacketQueue,
        typeof(buffer) audioBuffer)
    {
        super(logger);

        assert(context.codec);
        assert(context.codecParams);
        assert(context.audioOutSpec.freqHz > 0);

        this.context = context;

        assert(audioPacketQueue);
        this.packetQueue = audioPacketQueue;

        assert(audioBuffer);
        this.buffer = audioBuffer;
    }

    override void run()
    {
        try
        {
            version (EnableTrace)
            {
                logger.trace("Run audio decoder");
            }

            AVCodecContext* ctx = avcodec_alloc_context3(context.codec);
            if (!ctx)
            {
                logger.error("Audio context is null");
                return;
            }

            scope (exit)
            {
                avcodec_free_context(&ctx);
            }

            const isToCtx = avcodec_parameters_to_context(ctx, context.codecParams);
            if (isToCtx < 0)
            {
                logger.error("Error parameters to context in audio decoder: ", errorText(isToCtx));
                return;
            }

            const isOpenCodec = avcodec_open2(ctx, context.codec, null);
            if (isOpenCodec < 0)
            {
                logger.error("Error open video codec: ", errorText(isOpenCodec));
                return;
            }

            AVSampleFormat srcFormat = cast(AVSampleFormat) context.codecParams.format;
            AVSampleFormat destFormat = av_get_packed_sample_fmt(srcFormat);

            srcSpec = ComAudioSpec.init;
            //TODO check cast av_get_sample_fmt_name((enum AVSampleFormat)codecpar->format) == NULL
            srcSpec.format = fromLibFormat(destFormat);
            srcSpec.freqHz = context.codecParams.sample_rate;
            srcSpec.channels = context.codecParams.ch_layout.nb_channels;

            bool isPlanar = av_sample_fmt_is_planar(cast(AVSampleFormat) context.codecParams.format) == 1;

            logger.infof("Audio decoder for stream, codec: %s. src:%s(planar:%s), dst%s", audioParams(
                    context.codecParams), srcSpec, isPlanar, context.audioOutSpec);

            SwrContext* audioConvertContext;

            if (srcFormat != destFormat)
            {
                int isAllocSoundConvert = swr_alloc_set_opts2(
                    &audioConvertContext,

                    &context.codecParams.ch_layout,
                    destFormat,
                    context.codecParams.sample_rate,

                    &context.codecParams.ch_layout,
                    srcFormat,
                    context.codecParams.sample_rate,

                    0,
                    null
                );

                if (isAllocSoundConvert < 0)
                {
                    logger.error("Error allocating audio context: ", errorText(
                            isAllocSoundConvert));
                    return;
                }

                assert(audioConvertContext);

                const isInitSw = swr_init(audioConvertContext);
                if (isInitSw < 0)
                {
                    logger.error("Error audio converter context: ", errorText(isInitSw));
                    return;
                }
            }

            scope (exit)
            {
                if (audioConvertContext)
                {
                    swr_free(&audioConvertContext);
                }
            }

            version (EnableTrace)
            {
                logger.trace("Start audio decoder loop");
            }

            AVFrame* frame = av_frame_alloc();
            if (!frame)
            {
                logger.error("Error allocation audio frame");
                return;
            }
            version (EnableTrace)
            {
                logger.trace("Start audiodecoder loop");
            }

            while (true)
            {
                if (packetQueue.isEmpty)
                {
                    waitInLoop;
                    //import std;

                    //debug writeln("Packet audio queue is empty. Continue");
                    continue;
                }

                if (buffer.isFull)
                {
                    waitInLoop;
                    //import std;

                    //debug writeln("Audio buffer is full. Continue");
                    continue;
                }

                AVPacket* pkt;
                try
                {
                    packetQueue.mutex.lock;

                    const isPacketRead = packetQueue.peek(pkt);
                    if (isPacketRead != ContainerResult.success)
                    {
                        logger.error("Error peek audio packet from queue: ", isPacketRead);
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
                        logger.error("EOF in audio decoder, break");
                        break;
                    }

                    if (isSend < 0 && isSend != AVERROR(EAGAIN))
                    {
                        //TODO drop packet?
                        packetQueue.removeStrict;
                        av_packet_free(&pkt);
                        logger.error("Error sending packet in audio decoder: ", errorText(
                                isSend));
                        continue;
                    }

                    const isReceive = avcodec_receive_frame(ctx, frame);
                    if (isReceive == AVERROR(EAGAIN))
                    {
                        continue;
                    }

                    if (isReceive < 0)
                    {
                        logger.error("Error receiving frame in audio decoder: ", errorText(
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

                if (frame.nb_samples == 0)
                {
                    logger.error("Received audio frame with 0 samples");
                    continue;
                }

                ubyte* audioBuff;

                int audioBuffSize = av_samples_alloc(&audioBuff,
                    null,
                    frame.ch_layout.nb_channels,
                    frame.nb_samples,
                    destFormat,
                    0
                );

                if (audioBuffSize < 0)
                {
                    logger.error("Error allocating audio frame buffer: ", errorText(
                            audioBuffSize));
                    continue;
                }

                scope (exit)
                {
                    if (audioBuff)
                    {
                        import core.stdc.stdlib: free;
                        
                        free(audioBuff);
                    }
                }

                if (audioConvertContext)
                {
                    auto isConvert = swr_convert(
                        audioConvertContext,
                        &audioBuff,
                        frame.nb_samples,
                        frame.data.ptr,
                        frame.nb_samples
                    );

                    if (isConvert < 0)
                    {
                        logger.error("Error converting audio buffer", errorText(isConvert));
                        continue;
                    }
                }
                else
                {
                    size_t dataSize = frame.nb_samples * frame.ch_layout.nb_channels * av_get_bytes_per_sample(
                        destFormat);
                    if (dataSize != audioBuffSize)
                    {
                        logger.error("Audiobuffer size %s, but audio data size %s, is planar: %s", audioBuffSize, dataSize, isPlanar);
                        continue;
                    }
                    audioBuff[0 .. audioBuffSize] = frame.data[0][0 .. dataSize];
                }

                size_t writeBytes = audioBuffSize;

                const isWrite = buffer.writeSync(audioBuff[0 .. audioBuffSize]);

                if (isWrite != ContainerResult.success)
                {
                    debug {
                        import std.stdio: writefln;
                        writefln(
                        "Write to audio buffer %s bytes: %s, cap %s, source bytes %s, full %s, packet queue: %s", writeBytes, isWrite, buffer
                            .capacity, audioBuffSize, buffer.isFull, packetQueue.size);
                    }
                }
            }

            av_frame_free(&frame);
            version (EnableTrace)
            {
                logger.trace("Audio decoder finished work");
            }
        }
        catch (Exception e)
        {
            logger.error("Exception in audio decoder: ", e);
        }
        catch (Throwable th)
        {
            logger.error("Error in audio decoder: ", th);
            throw th;
        }
    }

    ComAudioFormat fromLibFormat(AVSampleFormat libFormat)
    {
        ComAudioFormat format;
        switch (libFormat) with (AVSampleFormat)
        {
            //TODO planar swr_convert, AV_SAMPLE_FMT_S32P, AV_SAMPLE_FMT_S16P
            case AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P:
                format = ComAudioFormat.s32;
                break;
            case AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P:
                format = ComAudioFormat.s16;
                break;
            case AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP:
                format = ComAudioFormat.f32;
                break;
            default:
                break;
        }
        return format;
    }

    AVSampleFormat toLibFormat(ComAudioFormat format)
    {
        //TODO default
        AVSampleFormat libFormat = AVSampleFormat.AV_SAMPLE_FMT_S16;
        switch (format) with (ComAudioFormat)
        {
            //TODO planar swr_convert, AV_SAMPLE_FMT_S32P, AV_SAMPLE_FMT_S16P
            case s16:
                libFormat = AVSampleFormat.AV_SAMPLE_FMT_S16;
                break;
            case s32:
                libFormat = AVSampleFormat.AV_SAMPLE_FMT_S32;
                break;
            case f32:
                libFormat = AVSampleFormat.AV_SAMPLE_FMT_FLT;
                break;
            default:
                break;
        }
        return libFormat;
    }

    protected string audioParams(AVCodecParameters* codecpar)
    {
        import std.format : format;
        import std.string : fromStringz;

        char[255] buff = 0;
        int buffLen = av_channel_layout_describe(&codecpar.ch_layout, buff.ptr, buff.length);

        return format("Format: %s(%s), rate:%dHz, chans:%d, %s",
            av_get_sample_fmt_name(cast(AVSampleFormat) codecpar.format)
                .fromStringz,
            av_sample_fmt_is_planar(cast(AVSampleFormat) codecpar.format) ? "planar" : "packed",
            codecpar.sample_rate,
            codecpar.ch_layout.nb_channels,
            buffLen > 0 ? buff[0 .. buffLen] : "unknown"
        );
    }
}
