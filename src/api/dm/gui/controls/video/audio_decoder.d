module api.dm.gui.controls.video.audio_decoder;

import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;
import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.dm.gui.controls.video.base_media_worker : BaseMediaWorker;
import api.core.utils.structs.container_result : ContainerResult;

import std.logger : Logger;
import std.string : toStringz, fromStringz;

import cffmpeg;

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
            logger.trace("Run audio decoder");

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

            srcSpec = ComAudioSpec.init;

            auto audioSampeFormat = context.codecParams.format;
            switch (audioSampeFormat) with (AVSampleFormat)
            {
                //TODO planar swr_convert, AV_SAMPLE_FMT_S32P, AV_SAMPLE_FMT_S16P
                case AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P:
                    srcSpec.format = ComAudioFormat.s32;
                    break;
                case AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P:
                    srcSpec.format = ComAudioFormat.s16;
                    break;
                case AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP:
                    srcSpec.format = ComAudioFormat.f32;
                    break;
                default:
                    break;
            }

            //TODO check cast av_get_sample_fmt_name((enum AVSampleFormat)codecpar->format) == NULL

            srcSpec.freqHz = context.codecParams.sample_rate;
            srcSpec.channels = context.codecParams.ch_layout.nb_channels;

            logger.tracef("Audio decoder for stream, codec: %s. src:%s, dst%s", audioParams(
                    context.codecParams), srcSpec, context.audioOutSpec);

            SwrContext* audioConvertContext;

            //if (av_sample_fmt_is_planar(cast(AVSampleFormat) codecParams.format))
            //{
            //sws_getContext
            int isAllocSoundConvert = swr_alloc_set_opts2(
                &audioConvertContext,
                &context.codecParams.ch_layout,
                AV_SAMPLE_FMT_FLT,
                context.audioOutSpec.freqHz,
                &context.codecParams.ch_layout,
                cast(AVSampleFormat) context.codecParams.format,
                context.codecParams.sample_rate,
                0,
                null
            );

            if (isAllocSoundConvert != 0)
            {
                logger.error("Error allocating sound converter: ", errorText(isAllocSoundConvert));
                return;
            }

            assert(audioConvertContext);

            const isInitSw = swr_init(audioConvertContext);
            if (isInitSw < 0)
            {
                logger.error("Error audio converter context: ", errorText(isInitSw));
                return;
            }

            logger.trace("Start audio decoder loop");

            AVFrame* frame = av_frame_alloc();
            if (!frame)
            {
                logger.error("Error allocation audio frame");
                return;
            }

            logger.trace("Start audiodecoder loop");

            while (true)
            {
                if (packetQueue.isEmpty)
                {
                    //import std;

                    //debug writeln("Packet audio queue is empty. Continue");
                    continue;
                }

                if (buffer.isFull)
                {
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
                        logger.error("Error sending packet in audio decoder: ", errorText(isSend));
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

                // if (frame.format == AV_SAMPLE_FMT_S16 &&
                //     frame.ch_layout.nb_channels == 2 &&
                //     frame.ample_rate == 44100)
                // {
                //     int dataSize = frame.nb_samples.frame.ch_layout.nb_channels * short.sizeof;
                //     auto isErr = audioStream.putData(frame.data[0], dataSize);
                //     return;
                // }

                ubyte* audioBuff;

                int audioBuffSize = av_samples_alloc(&audioBuff,
                    null,
                    frame.ch_layout.nb_channels,
                    frame.nb_samples,
                    AV_SAMPLE_FMT_FLT,
                    0
                );

                if (audioBuffSize < 0)
                {
                    logger.error("Error allocating audio frame buffer: ", errorText(audioBuffSize));
                    continue;
                }

                scope (exit)
                {
                    if (audioBuff)
                    {
                        free(audioBuff);
                    }
                }

                // //if (audioConvertContext)
                // //{
                // //targetFrame = av_frame_alloc();
                // //swr_convert_frame(audioConvertContext, targetFrame, frame);
                // //isDestroy = true;
                auto isConvert = swr_convert(
                    audioConvertContext,
                    &audioBuff,
                    audioBuffSize,
                    frame.data.ptr,
                    frame.nb_samples
                );
                // //}
                if (isConvert < 0)
                {
                    logger.error("Error converting audio buffer", errorText(isConvert));
                    continue;
                }

                size_t writeBytes = audioBuffSize;

                const isWrite = buffer.writeSync(audioBuff[0 .. audioBuffSize]);

                if (isWrite != ContainerResult.success)
                {
                    import std;

                    debug writefln(
                        "Write to audio buffer %s bytes: %s, cap %s, source bytes %s, full %s, packet queue: %s", writeBytes, isWrite, buffer
                            .capacity, audioBuffSize, buffer.isFull, packetQueue.size);
                }
            }

            av_frame_free(&frame);

            logger.trace("Audio decoder finished work");
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
