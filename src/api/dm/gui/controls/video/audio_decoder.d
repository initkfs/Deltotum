module api.dm.gui.controls.video.audio_decoder;

import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioFormat;
import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import api.dm.gui.controls.video.base_player_worker : BasePlayerWorker;
import api.core.utils.structs.container_result : ContainerResult;

import core.thread.osthread : Thread;
import std.logger : Logger;
import std.string : toStringz, fromStringz;

import cffmpeg;

/**
 * Authors: initkfs
 */
class AudioDecoder(size_t PacketBufferSize, size_t AudioBufferSize) : BasePlayerWorker
{
    protected
    {
        RingBuffer!(AVPacket*, PacketBufferSize)* packetQueue;

        AVCodec* codec;
        AVCodecParameters* codecParams;
        ComAudioSpec audioOut;
    }

    RingBuffer!(ubyte, AudioBufferSize)* buffer;

    ComAudioSpec srcSpec;

    this(Logger logger, AVCodec* codec, AVCodecParameters* codecParams, ComAudioSpec audioOut, typeof(
            packetQueue) newPacketQueue, typeof(
            buffer) newbuffer)
    {
        super(logger);
        this.packetQueue = newPacketQueue;
        this.buffer = newbuffer;
        this.codecParams = codecParams;
        this.audioOut = audioOut;
        this.codec = codec;
    }

    override void run()
    {
        logger.trace("Run audio decoder");

        AVCodecContext* ctx = avcodec_alloc_context3(codec);

        if (avcodec_parameters_to_context(ctx, codecParams) < 0)
        {
            logger.error("Error convert audio params to context");
            return;
        }

        if (avcodec_open2(ctx, codec, null) < 0)
        {
            logger.error("Error open audio codec");
            return;
        }

        auto audioSampeFormat = codecParams.format;
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

        srcSpec.freqHz = codecParams.sample_rate;
        srcSpec.channels = codecParams.ch_layout.nb_channels;

        logger.tracef("Audio decoder for stream, codec: %s. src:%s, dst%s", audioParams(
                codecParams), srcSpec, audioOut);
        // if (onAudioStream)
        // {
        //     onAudioStream(srcSpec, outSpec);
        // }

        SwrContext* audioConvertContext;

        //if (av_sample_fmt_is_planar(cast(AVSampleFormat) codecParams.format))
        //{
        //sws_getContext
        int isAllocSoundConvert = swr_alloc_set_opts2(
            &audioConvertContext,
            &codecParams.ch_layout,
            AV_SAMPLE_FMT_FLT,
            audioOut.freqHz,
            &codecParams.ch_layout,
            cast(AVSampleFormat) codecParams.format,
            codecParams.sample_rate,
            0,
            null
        );

        if (isAllocSoundConvert != 0)
        {
            logger.error("Error allocating sound converter");
            return;
        }

        assert(audioConvertContext);

        swr_init(audioConvertContext);
        // if (swr_init(audioConvertContext))
        // {
        //     logger.error("Error sound converter context");
        //     return;
        // }
        //}

        logger.trace("Start audio decoder loop");

        AVFrame* frame = av_frame_alloc();

        while (true)
        {
            // if (_end)
            // {
            //     avcodec_send_packet(ctx, null);
            //     continue;
            // }

            if (packetQueue.isEmpty)
            {
                //import std;

                //debug writeln("Packet audio queue is empty. Continue");
                continue;
            }

            if (buffer.isFull)
            {
                import std;

                debug writeln("Audio buffer is full. Continue");
                continue;
            }

            AVPacket* pkt;
            const isRead = packetQueue.readSync(pkt);

            if (isRead != ContainerResult.success)
            {
                packetQueue.mutex.lock;
                scope (exit)
                {
                    packetQueue.mutex.unlock;
                }
                logger.errorf("Error read audio packet from queue with size %s: %s, ri %s, wi: %s", packetQueue.size, isRead, packetQueue
                        .readIndex, packetQueue.writeIndex);
                continue;
            }

            if (!pkt)
            {
                logger.error("Audio packet is null");
                continue;
            }

            scope (exit)
            {
                if (pkt)
                {
                    av_packet_free(&pkt);
                }
            }

            const sret = avcodec_send_packet(ctx, pkt);
            if (sret == FFERRTAG('E', 'O', 'F', ' '))
            {
                logger.trace("Detect EOF in audio decoder, break");
                break;
            }

            if (sret < 0)
            {
                char[256] buff = 0;
                av_strerror(sret, buff.ptr, buff.length);
                logger.error("Error send audio packet: ", buff.fromStringz);
                continue;
            }

            if (avcodec_receive_frame(ctx, frame) < 0)
            {
                logger.error("Error receive audio frame");
                continue;
            }

            if (frame.nb_samples == 0)
            {
                import std;

                writeln("0 samples");
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

            auto audioBuffSize = av_samples_get_buffer_size(
                null,
                frame.ch_layout.nb_channels,
                frame.nb_samples,
                AV_SAMPLE_FMT_FLT,
                0
            );

            if (audioBuffSize < 0)
            {
                import std;

                writeln("Error invalid buffer size");
                continue;
            }

            if (audioBuffSize == 0)
            {
                import std;

                writeln("Buff is 0");
                continue;
            }

            ubyte* audioBuff = cast(ubyte*) malloc(audioBuffSize);
            assert(audioBuff);

            // int audioBuffSize = av_samples_alloc(&audioBuff,
            //     null,
            //     frame.ch_layout.nb_channels,
            //     targetSamples,
            //     AV_SAMPLE_FMT_S16,
            //     0
            // );

            scope (exit)
            {
                // if (audioBuff)
                // {
                //     free(audioBuff);
                // }
            }

            // if (audioBuffSize <= 0)
            // {
            //     logger.error("Audio buffer allocating error");
            //     continue;
            // }

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
                import std;

                writeln("Error convert audio data");
                continue;
            }

            size_t writeBytes = audioBuffSize;
            // if (buffer.capacity < writeBytes)
            // {
            //     writeBytes = buffer.capacity;
            // }

            // buffer.mutex.lock;
            // scope (exit)
            // {
            //     buffer.mutex.unlock;
            // }

            try
            {
                assert(buffer);
                const isWrite = buffer.writeSync(audioBuff[0 .. audioBuffSize]);

                if (isWrite != ContainerResult.success)
                {
                import std;

                debug writefln(
                    "Write to audio buffer %s bytes: %s, cap %s, source bytes %s, full %s, packet queue: %s", writeBytes, isWrite, buffer
                        .capacity, audioBuffSize, buffer.isFull, packetQueue.size);
                }
            }
            catch (Throwable e)
            {
                import std;
                stderr.writeln(e.toString);
            }

            //av_frame_unref(frame);
        }

        av_frame_free(&frame);

        logger.trace("Audio decoder end");
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
