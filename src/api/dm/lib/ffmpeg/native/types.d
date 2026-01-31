module api.dm.lib.ffmpeg.native.types;
/**
 * Authors: initkfs
 */

import std.stdint;

struct AVFilterInOut
{
    char* name;
    AVFilterContext* filter_ctx;
    int pad_idx;
    AVFilterInOut* next;
}

enum AV_OPT_FLAG_FILTERING_PARAM = (1 << 16);

struct SwsFilter;
struct SwrContext;

//avcodec

struct AVCodec;

alias AVCodecID = int;

struct AVPacket
{
    AVBufferRef* buf;
    int64_t pts;
    int64_t dts;
    uint8_t* data;
    int size;
    int stream_index;
    int flags;
    AVPacketSideData* side_data;
    int side_data_elems;
    int64_t duration;
    int64_t pos;
    void* opaque;
    AVBufferRef* opaque_ref;
    AVRational time_base;
}

struct AVPacketSideData
{
    uint8_t* data;
    size_t size;
    AVPacketSideDataType type;
}

struct AVCodecParameters
{
    AVMediaType codec_type;
    AVCodecID codec_id;
    uint32_t codec_tag;
    uint8_t* extradata;
    int extradata_size;
    AVPacketSideData* coded_side_data;
    int nb_coded_side_data;
    int format;
    int64_t bit_rate;
    int bits_per_coded_sample;
    int bits_per_raw_sample;
    int profile;
    int level;
    int width;
    int height;
    AVRational sample_aspect_ratio;
    AVRational framerate;
    AVFieldOrder field_order;
    AVColorRange color_range;
    AVColorPrimaries color_primaries;
    AVColorTransferCharacteristic color_trc;
    AVColorSpace color_space;
    AVChromaLocation chroma_location;
    int video_delay;
    AVChannelLayout ch_layout;
    int sample_rate;
    int block_align;
    int frame_size;
    int initial_padding;
    int trailing_padding;
    int seek_preroll;
    AVAlphaMode alpha_mode;
}

enum AVAlphaMode
{
    AVALPHA_MODE_UNSPECIFIED,
    AVALPHA_MODE_PREMULTIPLIED,
    AVALPHA_MODE_STRAIGHT,
    AVALPHA_MODE_NB,
}

struct AVChannelLayout
{
    AVChannelOrder order;
    int nb_channels;
    union
    {
        uint64_t mask;
        AVChannelCustom* map;
    }

    void* opaque;
}

struct AVChannelCustom;

enum AVChannelOrder
{
    AV_CHANNEL_ORDER_UNSPEC,
    AV_CHANNEL_ORDER_NATIVE,
    AV_CHANNEL_ORDER_CUSTOM,
    AV_CHANNEL_ORDER_AMBISONIC,
    FF_CHANNEL_ORDER_NB
}

enum AVChromaLocation
{
    AVCHROMA_LOC_UNSPECIFIED = 0,
    AVCHROMA_LOC_LEFT = 1, ///< MPEG-2/4 4:2:0, H.264 default for 4:2:0
    AVCHROMA_LOC_CENTER = 2, ///< MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
    AVCHROMA_LOC_TOPLEFT = 3, ///< ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
    AVCHROMA_LOC_TOP = 4,
    AVCHROMA_LOC_BOTTOMLEFT = 5,
    AVCHROMA_LOC_BOTTOM = 6,
    AVCHROMA_LOC_NB ///< Not part of ABI
}

enum AVColorPrimaries
{
    AVCOL_PRI_RESERVED0 = 0,
    AVCOL_PRI_BT709 = 1, ///< also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP 177 Annex B
    AVCOL_PRI_UNSPECIFIED = 2,
    AVCOL_PRI_RESERVED = 3,
    AVCOL_PRI_BT470M = 4, ///< also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)

    AVCOL_PRI_BT470BG = 5, ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
    AVCOL_PRI_SMPTE170M = 6, ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
    AVCOL_PRI_SMPTE240M = 7, ///< identical to above, also called "SMPTE C" even though it uses D65
    AVCOL_PRI_FILM = 8, ///< colour filters using Illuminant C
    AVCOL_PRI_BT2020 = 9, ///< ITU-R BT2020
    AVCOL_PRI_SMPTE428 = 10, ///< SMPTE ST 428-1 (CIE 1931 XYZ)
    AVCOL_PRI_SMPTEST428_1 = AVCOL_PRI_SMPTE428,
    AVCOL_PRI_SMPTE431 = 11, ///< SMPTE ST 431-2 (2011) / DCI P3
    AVCOL_PRI_SMPTE432 = 12, ///< SMPTE ST 432-1 (2010) / P3 D65 / Display P3
    AVCOL_PRI_EBU3213 = 22, ///< EBU Tech. 3213-E (nothing there) / one of JEDEC P22 group phosphors
    AVCOL_PRI_JEDEC_P22 = AVCOL_PRI_EBU3213,
    AVCOL_PRI_NB ///< Not part of ABI
}

enum AVColorTransferCharacteristic
{
    AVCOL_TRC_RESERVED0 = 0,
    AVCOL_TRC_BT709 = 1, ///< also ITU-R BT1361
    AVCOL_TRC_UNSPECIFIED = 2,
    AVCOL_TRC_RESERVED = 3,
    AVCOL_TRC_GAMMA22 = 4, ///< also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
    AVCOL_TRC_GAMMA28 = 5, ///< also ITU-R BT470BG
    AVCOL_TRC_SMPTE170M = 6, ///< also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
    AVCOL_TRC_SMPTE240M = 7,
    AVCOL_TRC_LINEAR = 8, ///< "Linear transfer characteristics"
    AVCOL_TRC_LOG = 9, ///< "Logarithmic transfer characteristic (100:1 range)"
    AVCOL_TRC_LOG_SQRT = 10, ///< "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
    AVCOL_TRC_IEC61966_2_4 = 11, ///< IEC 61966-2-4
    AVCOL_TRC_BT1361_ECG = 12, ///< ITU-R BT1361 Extended Colour Gamut
    AVCOL_TRC_IEC61966_2_1 = 13, ///< IEC 61966-2-1 (sRGB or sYCC)
    AVCOL_TRC_BT2020_10 = 14, ///< ITU-R BT2020 for 10-bit system
    AVCOL_TRC_BT2020_12 = 15, ///< ITU-R BT2020 for 12-bit system
    AVCOL_TRC_SMPTE2084 = 16, ///< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
    AVCOL_TRC_SMPTEST2084 = AVCOL_TRC_SMPTE2084,
    AVCOL_TRC_SMPTE428 = 17, ///< SMPTE ST 428-1
    AVCOL_TRC_SMPTEST428_1 = AVCOL_TRC_SMPTE428,
    AVCOL_TRC_ARIB_STD_B67 = 18, ///< ARIB STD-B67, known as "Hybrid log-gamma"
    AVCOL_TRC_NB ///< Not part of ABI
}

enum AVColorSpace
{
    AVCOL_SPC_RGB = 0, ///< order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB), YZX and ST 428-1
    AVCOL_SPC_BT709 = 1, ///< also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / derived in SMPTE RP 177 Annex B
    AVCOL_SPC_UNSPECIFIED = 2,
    AVCOL_SPC_RESERVED = 3, ///< reserved for future use by ITU-T and ISO/IEC just like 15-255 are
    AVCOL_SPC_FCC = 4, ///< FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
    AVCOL_SPC_BT470BG = 5, ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
    AVCOL_SPC_SMPTE170M = 6, ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC / functionally identical to above
    AVCOL_SPC_SMPTE240M = 7, ///< derived from 170M primaries and D65 white point, 170M is derived from BT470 System M's primaries
    AVCOL_SPC_YCGCO = 8, ///< used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
    AVCOL_SPC_YCOCG = AVCOL_SPC_YCGCO,
    AVCOL_SPC_BT2020_NCL = 9, ///< ITU-R BT2020 non-constant luminance system
    AVCOL_SPC_BT2020_CL = 10, ///< ITU-R BT2020 constant luminance system
    AVCOL_SPC_SMPTE2085 = 11, ///< SMPTE 2085, Y'D'zD'x
    AVCOL_SPC_CHROMA_DERIVED_NCL = 12, ///< Chromaticity-derived non-constant luminance system
    AVCOL_SPC_CHROMA_DERIVED_CL = 13, ///< Chromaticity-derived constant luminance system
    AVCOL_SPC_ICTCP = 14, ///< ITU-R BT.2100-0, ICtCp
    AVCOL_SPC_IPT_C2 = 15, ///< SMPTE ST 2128, IPT-C2
    AVCOL_SPC_YCGCO_RE = 16, ///< YCgCo-R, even addition of bits
    AVCOL_SPC_YCGCO_RO = 17, ///< YCgCo-R, odd addition of bits
    AVCOL_SPC_NB ///< Not part of ABI
}

enum AVColorRange
{
    AVCOL_RANGE_UNSPECIFIED = 0,
    AVCOL_RANGE_MPEG = 1,
    AVCOL_RANGE_JPEG = 2,
    AVCOL_RANGE_NB
}

enum AVFieldOrder
{
    AV_FIELD_UNKNOWN,
    AV_FIELD_PROGRESSIVE,
    AV_FIELD_TT, ///< Top coded_first, top displayed first
    AV_FIELD_BB, ///< Bottom coded first, bottom displayed first
    AV_FIELD_TB, ///< Top coded first, bottom displayed first
    AV_FIELD_BT, ///< Bottom coded first, top displayed first
}

enum AVMediaType
{
    AVMEDIA_TYPE_UNKNOWN = -1,
    AVMEDIA_TYPE_VIDEO,
    AVMEDIA_TYPE_AUDIO,
    AVMEDIA_TYPE_DATA,
    AVMEDIA_TYPE_SUBTITLE,
    AVMEDIA_TYPE_ATTACHMENT,
    AVMEDIA_TYPE_NB
}

enum AVPacketSideDataType
{
    AV_PKT_DATA_PALETTE,
    AV_PKT_DATA_NEW_EXTRADATA,
    AV_PKT_DATA_PARAM_CHANGE,
    AV_PKT_DATA_H263_MB_INFO,
    AV_PKT_DATA_REPLAYGAIN,
    AV_PKT_DATA_DISPLAYMATRIX,
    AV_PKT_DATA_STEREO3D,
    AV_PKT_DATA_AUDIO_SERVICE_TYPE,
    AV_PKT_DATA_QUALITY_STATS,
    AV_PKT_DATA_FALLBACK_TRACK,
    AV_PKT_DATA_CPB_PROPERTIES,
    AV_PKT_DATA_SKIP_SAMPLES,
    AV_PKT_DATA_JP_DUALMONO,
    AV_PKT_DATA_STRINGS_METADATA,
    AV_PKT_DATA_SUBTITLE_POSITION,
    AV_PKT_DATA_MATROSKA_BLOCKADDITIONAL,
    AV_PKT_DATA_WEBVTT_IDENTIFIER,
    AV_PKT_DATA_WEBVTT_SETTINGS,
    AV_PKT_DATA_METADATA_UPDATE,
    AV_PKT_DATA_MPEGTS_STREAM_ID,
    AV_PKT_DATA_MASTERING_DISPLAY_METADATA,
    AV_PKT_DATA_SPHERICAL,
    AV_PKT_DATA_CONTENT_LIGHT_LEVEL,
    AV_PKT_DATA_A53_CC,
    AV_PKT_DATA_ENCRYPTION_INIT_INFO,
    AV_PKT_DATA_ENCRYPTION_INFO,
    AV_PKT_DATA_AFD,
    AV_PKT_DATA_PRFT,
    AV_PKT_DATA_ICC_PROFILE,
    AV_PKT_DATA_DOVI_CONF,
    AV_PKT_DATA_S12M_TIMECODE,
    AV_PKT_DATA_DYNAMIC_HDR10_PLUS,
    AV_PKT_DATA_IAMF_MIX_GAIN_PARAM,
    AV_PKT_DATA_IAMF_DEMIXING_INFO_PARAM,
    AV_PKT_DATA_IAMF_RECON_GAIN_INFO_PARAM,
    AV_PKT_DATA_AMBIENT_VIEWING_ENVIRONMENT,
    AV_PKT_DATA_FRAME_CROPPING,
    AV_PKT_DATA_LCEVC,
    AV_PKT_DATA_NB
}

//buffer
struct AVBufferRef
{
    AVBuffer* buffer;
    uint8_t* data;
    size_t size;
}

struct AVBuffer;

//rational.h
struct AVRational
{
    int num;
    int den;
}

enum AVPictureType
{
    AV_PICTURE_TYPE_NONE = 0, ///< Undefined
    AV_PICTURE_TYPE_I, ///< Intra
    AV_PICTURE_TYPE_P, ///< Predicted
    AV_PICTURE_TYPE_B, ///< Bi-dir predicted
    AV_PICTURE_TYPE_S, ///< S(GMC)-VOP MPEG-4
    AV_PICTURE_TYPE_SI, ///< Switching Intra
    AV_PICTURE_TYPE_SP, ///< Switching Predicted
    AV_PICTURE_TYPE_BI, ///< BI type
}

struct AVFrameSideData;

//frame.h
enum AV_NUM_DATA_POINTERS = 8;
struct AVFrame {
    ubyte*[AV_NUM_DATA_POINTERS] data;
    int[AV_NUM_DATA_POINTERS] linesize;
    ubyte** extended_data;
    int width, height;
    int nb_samples;
    int format;
    AVPictureType pict_type;
    AVRational sample_aspect_ratio;
    long pts;
    long pkt_dts;
    AVRational time_base;
    int quality;
    void* opaque;
    int repeat_pict;
    int sample_rate;
    AVBufferRef*[AV_NUM_DATA_POINTERS] buf;
    AVBufferRef** extended_buf;
    int nb_extended_buf;
    AVFrameSideData** side_data;
    int nb_side_data;
    int flags;
    AVColorRange color_range;
    AVColorPrimaries color_primaries;
    AVColorTransferCharacteristic color_trc;
    AVColorSpace colorspace;
    AVChromaLocation chroma_location;
    long best_effort_timestamp;
    AVDictionary* metadata;
    int decode_error_flags;
    AVBufferRef* hw_frames_ctx;
    AVBufferRef* opaque_ref;
    size_t crop_top;
    size_t crop_bottom;
    size_t crop_left;
    size_t crop_right;
    void* private_ref;
    AVChannelLayout ch_layout;
    long duration;
}

int FFERRTAG(char a, char b, char c, char d)
{
    return (-cast(int) MKTAG(a, b, c, d));
}

int MKTAG(char a, char b, char c, char d)
{
    return ((a) | ((b) << 8) | ((c) << 16) | (cast(uint)(d) << 24));
}

int AVERROR(int err) => -err;

struct AVFilter;
struct AVFilterContext;

enum AVSampleFormat
{
    AV_SAMPLE_FMT_NONE = -1,
    AV_SAMPLE_FMT_U8, ///< unsigned 8 bits
    AV_SAMPLE_FMT_S16, ///< signed 16 bits
    AV_SAMPLE_FMT_S32, ///< signed 32 bits
    AV_SAMPLE_FMT_FLT, ///< float
    AV_SAMPLE_FMT_DBL, ///< double

    AV_SAMPLE_FMT_U8P, ///< unsigned 8 bits, planar
    AV_SAMPLE_FMT_S16P, ///< signed 16 bits, planar
    AV_SAMPLE_FMT_S32P, ///< signed 32 bits, planar
    AV_SAMPLE_FMT_FLTP, ///< float, planar
    AV_SAMPLE_FMT_DBLP, ///< double, planar
    AV_SAMPLE_FMT_S64, ///< signed 64 bits
    AV_SAMPLE_FMT_S64P, ///< signed 64 bits, planar

    AV_SAMPLE_FMT_NB ///< Number of sample formats. DO NOT USE if linking dynamically
}

enum AV_OPT_SEARCH_CHILDREN = (1 << 0);

struct AVDictionary;
struct AVFilterGraph;

enum AVPixelFormat
{
    AV_PIX_FMT_NONE = -1,
    AV_PIX_FMT_YUV420P, ///< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    AV_PIX_FMT_YUYV422, ///< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    AV_PIX_FMT_RGB24, ///< packed RGB 8:8:8, 24bpp, RGBRGB...
    AV_PIX_FMT_BGR24, ///< packed RGB 8:8:8, 24bpp, BGRBGR...
    AV_PIX_FMT_YUV422P, ///< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    AV_PIX_FMT_YUV444P, ///< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    AV_PIX_FMT_YUV410P, ///< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    AV_PIX_FMT_YUV411P, ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    AV_PIX_FMT_GRAY8, ///<        Y        ,  8bpp
    AV_PIX_FMT_MONOWHITE, ///<        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
    AV_PIX_FMT_MONOBLACK, ///<        Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
    AV_PIX_FMT_PAL8, ///< 8 bits with AV_PIX_FMT_RGB32 palette
    AV_PIX_FMT_YUVJ420P, ///< planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
    AV_PIX_FMT_YUVJ422P, ///< planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
    AV_PIX_FMT_YUVJ444P, ///< planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
    AV_PIX_FMT_UYVY422, ///< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    AV_PIX_FMT_UYYVYY411, ///< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    AV_PIX_FMT_BGR8, ///< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    AV_PIX_FMT_BGR4, ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    AV_PIX_FMT_BGR4_BYTE, ///< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    AV_PIX_FMT_RGB8, ///< packed RGB 3:3:2,  8bpp, (msb)3R 3G 2B(lsb)
    AV_PIX_FMT_RGB4, ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    AV_PIX_FMT_RGB4_BYTE, ///< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    AV_PIX_FMT_NV12, ///< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    AV_PIX_FMT_NV21, ///< as above, but U and V bytes are swapped

    AV_PIX_FMT_ARGB, ///< packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
    AV_PIX_FMT_RGBA, ///< packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
    AV_PIX_FMT_ABGR, ///< packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
    AV_PIX_FMT_BGRA, ///< packed BGRA 8:8:8:8, 32bpp, BGRABGRA...

    AV_PIX_FMT_GRAY16BE, ///<        Y        , 16bpp, big-endian
    AV_PIX_FMT_GRAY16LE, ///<        Y        , 16bpp, little-endian
    AV_PIX_FMT_YUV440P, ///< planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
    AV_PIX_FMT_YUVJ440P, ///< planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
    AV_PIX_FMT_YUVA420P, ///< planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
    AV_PIX_FMT_RGB48BE, ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
    AV_PIX_FMT_RGB48LE, ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian

    AV_PIX_FMT_RGB565BE, ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
    AV_PIX_FMT_RGB565LE, ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
    AV_PIX_FMT_RGB555BE, ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
    AV_PIX_FMT_RGB555LE, ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined

    AV_PIX_FMT_BGR565BE, ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
    AV_PIX_FMT_BGR565LE, ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
    AV_PIX_FMT_BGR555BE, ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
    AV_PIX_FMT_BGR555LE, ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined

    /**
     *  Hardware acceleration through VA-API, data[3] contains a
     *  VASurfaceID.
     */
    AV_PIX_FMT_VAAPI,

    AV_PIX_FMT_YUV420P16LE, ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    AV_PIX_FMT_YUV420P16BE, ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    AV_PIX_FMT_YUV422P16LE, ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    AV_PIX_FMT_YUV422P16BE, ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    AV_PIX_FMT_YUV444P16LE, ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    AV_PIX_FMT_YUV444P16BE, ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    AV_PIX_FMT_DXVA2_VLD, ///< HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer

    AV_PIX_FMT_RGB444LE, ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
    AV_PIX_FMT_RGB444BE, ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
    AV_PIX_FMT_BGR444LE, ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
    AV_PIX_FMT_BGR444BE, ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
    AV_PIX_FMT_YA8, ///< 8 bits gray, 8 bits alpha

    AV_PIX_FMT_Y400A = AV_PIX_FMT_YA8, ///< alias for AV_PIX_FMT_YA8
    AV_PIX_FMT_GRAY8A = AV_PIX_FMT_YA8, ///< alias for AV_PIX_FMT_YA8

    AV_PIX_FMT_BGR48BE, ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
    AV_PIX_FMT_BGR48LE, ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian

    /**
     * The following 12 formats have the disadvantage of needing 1 format for each bit depth.
     * Notice that each 9/10 bits sample is stored in 16 bits with extra padding.
     * If you want to support multiple bit depths, then using AV_PIX_FMT_YUV420P16* with the bpp stored separately is better.
     */
    AV_PIX_FMT_YUV420P9BE, ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    AV_PIX_FMT_YUV420P9LE, ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    AV_PIX_FMT_YUV420P10BE, ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    AV_PIX_FMT_YUV420P10LE, ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    AV_PIX_FMT_YUV422P10BE, ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    AV_PIX_FMT_YUV422P10LE, ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    AV_PIX_FMT_YUV444P9BE, ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    AV_PIX_FMT_YUV444P9LE, ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    AV_PIX_FMT_YUV444P10BE, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    AV_PIX_FMT_YUV444P10LE, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    AV_PIX_FMT_YUV422P9BE, ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    AV_PIX_FMT_YUV422P9LE, ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    AV_PIX_FMT_GBRP, ///< planar GBR 4:4:4 24bpp
    AV_PIX_FMT_GBR24P = AV_PIX_FMT_GBRP, // alias for #AV_PIX_FMT_GBRP
    AV_PIX_FMT_GBRP9BE, ///< planar GBR 4:4:4 27bpp, big-endian
    AV_PIX_FMT_GBRP9LE, ///< planar GBR 4:4:4 27bpp, little-endian
    AV_PIX_FMT_GBRP10BE, ///< planar GBR 4:4:4 30bpp, big-endian
    AV_PIX_FMT_GBRP10LE, ///< planar GBR 4:4:4 30bpp, little-endian
    AV_PIX_FMT_GBRP16BE, ///< planar GBR 4:4:4 48bpp, big-endian
    AV_PIX_FMT_GBRP16LE, ///< planar GBR 4:4:4 48bpp, little-endian
    AV_PIX_FMT_YUVA422P, ///< planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
    AV_PIX_FMT_YUVA444P, ///< planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
    AV_PIX_FMT_YUVA420P9BE, ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
    AV_PIX_FMT_YUVA420P9LE, ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
    AV_PIX_FMT_YUVA422P9BE, ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
    AV_PIX_FMT_YUVA422P9LE, ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
    AV_PIX_FMT_YUVA444P9BE, ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
    AV_PIX_FMT_YUVA444P9LE, ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    AV_PIX_FMT_YUVA420P10BE, ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    AV_PIX_FMT_YUVA420P10LE, ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    AV_PIX_FMT_YUVA422P10BE, ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    AV_PIX_FMT_YUVA422P10LE, ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    AV_PIX_FMT_YUVA444P10BE, ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    AV_PIX_FMT_YUVA444P10LE, ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
    AV_PIX_FMT_YUVA420P16BE, ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    AV_PIX_FMT_YUVA420P16LE, ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    AV_PIX_FMT_YUVA422P16BE, ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    AV_PIX_FMT_YUVA422P16LE, ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    AV_PIX_FMT_YUVA444P16BE, ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    AV_PIX_FMT_YUVA444P16LE, ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)

    AV_PIX_FMT_VDPAU, ///< HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface

    AV_PIX_FMT_XYZ12LE, ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
    AV_PIX_FMT_XYZ12BE, ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
    AV_PIX_FMT_NV16, ///< interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    AV_PIX_FMT_NV20LE, ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    AV_PIX_FMT_NV20BE, ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian

    AV_PIX_FMT_RGBA64BE, ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
    AV_PIX_FMT_RGBA64LE, ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
    AV_PIX_FMT_BGRA64BE, ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
    AV_PIX_FMT_BGRA64LE, ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian

    AV_PIX_FMT_YVYU422, ///< packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb

    AV_PIX_FMT_YA16BE, ///< 16 bits gray, 16 bits alpha (big-endian)
    AV_PIX_FMT_YA16LE, ///< 16 bits gray, 16 bits alpha (little-endian)

    AV_PIX_FMT_GBRAP, ///< planar GBRA 4:4:4:4 32bpp
    AV_PIX_FMT_GBRAP16BE, ///< planar GBRA 4:4:4:4 64bpp, big-endian
    AV_PIX_FMT_GBRAP16LE, ///< planar GBRA 4:4:4:4 64bpp, little-endian
    /**
     * HW acceleration through QSV, data[3] contains a pointer to the
     * mfxFrameSurface1 structure.
     *
     * Before FFmpeg 5.0:
     * mfxFrameSurface1.Data.MemId contains a pointer when importing
     * the following frames as QSV frames:
     *
     * VAAPI:
     * mfxFrameSurface1.Data.MemId contains a pointer to VASurfaceID
     *
     * DXVA2:
     * mfxFrameSurface1.Data.MemId contains a pointer to IDirect3DSurface9
     *
     * FFmpeg 5.0 and above:
     * mfxFrameSurface1.Data.MemId contains a pointer to the mfxHDLPair
     * structure when importing the following frames as QSV frames:
     *
     * VAAPI:
     * mfxHDLPair.first contains a VASurfaceID pointer.
     * mfxHDLPair.second is always MFX_INFINITE.
     *
     * DXVA2:
     * mfxHDLPair.first contains IDirect3DSurface9 pointer.
     * mfxHDLPair.second is always MFX_INFINITE.
     *
     * D3D11:
     * mfxHDLPair.first contains a ID3D11Texture2D pointer.
     * mfxHDLPair.second contains the texture array index of the frame if the
     * ID3D11Texture2D is an array texture, or always MFX_INFINITE if it is a
     * normal texture.
     */
    AV_PIX_FMT_QSV,
    /**
     * HW acceleration though MMAL, data[3] contains a pointer to the
     * MMAL_BUFFER_HEADER_T structure.
     */
    AV_PIX_FMT_MMAL,

    AV_PIX_FMT_D3D11VA_VLD, ///< HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer

    /**
     * HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
     * exactly as for system memory frames.
     */
    AV_PIX_FMT_CUDA,

    AV_PIX_FMT_0RGB, ///< packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
    AV_PIX_FMT_RGB0, ///< packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
    AV_PIX_FMT_0BGR, ///< packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
    AV_PIX_FMT_BGR0, ///< packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined

    AV_PIX_FMT_YUV420P12BE, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    AV_PIX_FMT_YUV420P12LE, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    AV_PIX_FMT_YUV420P14BE, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    AV_PIX_FMT_YUV420P14LE, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    AV_PIX_FMT_YUV422P12BE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    AV_PIX_FMT_YUV422P12LE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    AV_PIX_FMT_YUV422P14BE, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    AV_PIX_FMT_YUV422P14LE, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    AV_PIX_FMT_YUV444P12BE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    AV_PIX_FMT_YUV444P12LE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    AV_PIX_FMT_YUV444P14BE, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    AV_PIX_FMT_YUV444P14LE, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    AV_PIX_FMT_GBRP12BE, ///< planar GBR 4:4:4 36bpp, big-endian
    AV_PIX_FMT_GBRP12LE, ///< planar GBR 4:4:4 36bpp, little-endian
    AV_PIX_FMT_GBRP14BE, ///< planar GBR 4:4:4 42bpp, big-endian
    AV_PIX_FMT_GBRP14LE, ///< planar GBR 4:4:4 42bpp, little-endian
    AV_PIX_FMT_YUVJ411P, ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range

    AV_PIX_FMT_BAYER_BGGR8, ///< bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
    AV_PIX_FMT_BAYER_RGGB8, ///< bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
    AV_PIX_FMT_BAYER_GBRG8, ///< bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
    AV_PIX_FMT_BAYER_GRBG8, ///< bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
    AV_PIX_FMT_BAYER_BGGR16LE, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
    AV_PIX_FMT_BAYER_BGGR16BE, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
    AV_PIX_FMT_BAYER_RGGB16LE, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
    AV_PIX_FMT_BAYER_RGGB16BE, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
    AV_PIX_FMT_BAYER_GBRG16LE, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
    AV_PIX_FMT_BAYER_GBRG16BE, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
    AV_PIX_FMT_BAYER_GRBG16LE, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
    AV_PIX_FMT_BAYER_GRBG16BE, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian

    AV_PIX_FMT_YUV440P10LE, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    AV_PIX_FMT_YUV440P10BE, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    AV_PIX_FMT_YUV440P12LE, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    AV_PIX_FMT_YUV440P12BE, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    AV_PIX_FMT_AYUV64LE, ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    AV_PIX_FMT_AYUV64BE, ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian

    AV_PIX_FMT_VIDEOTOOLBOX, ///< hardware decoding through Videotoolbox

    AV_PIX_FMT_P010LE, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
    AV_PIX_FMT_P010BE, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian

    AV_PIX_FMT_GBRAP12BE, ///< planar GBR 4:4:4:4 48bpp, big-endian
    AV_PIX_FMT_GBRAP12LE, ///< planar GBR 4:4:4:4 48bpp, little-endian

    AV_PIX_FMT_GBRAP10BE, ///< planar GBR 4:4:4:4 40bpp, big-endian
    AV_PIX_FMT_GBRAP10LE, ///< planar GBR 4:4:4:4 40bpp, little-endian

    AV_PIX_FMT_MEDIACODEC, ///< hardware decoding through MediaCodec

    AV_PIX_FMT_GRAY12BE, ///<        Y        , 12bpp, big-endian
    AV_PIX_FMT_GRAY12LE, ///<        Y        , 12bpp, little-endian
    AV_PIX_FMT_GRAY10BE, ///<        Y        , 10bpp, big-endian
    AV_PIX_FMT_GRAY10LE, ///<        Y        , 10bpp, little-endian

    AV_PIX_FMT_P016LE, ///< like NV12, with 16bpp per component, little-endian
    AV_PIX_FMT_P016BE, ///< like NV12, with 16bpp per component, big-endian

    /**
     * Hardware surfaces for Direct3D11.
     *
     * This is preferred over the legacy AV_PIX_FMT_D3D11VA_VLD. The new D3D11
     * hwaccel API and filtering support AV_PIX_FMT_D3D11 only.
     *
     * data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
     * texture array index of the frame as intptr_t if the ID3D11Texture2D is
     * an array texture (or always 0 if it's a normal texture).
     */
    AV_PIX_FMT_D3D11,

    AV_PIX_FMT_GRAY9BE, ///<        Y        , 9bpp, big-endian
    AV_PIX_FMT_GRAY9LE, ///<        Y        , 9bpp, little-endian

    AV_PIX_FMT_GBRPF32BE, ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
    AV_PIX_FMT_GBRPF32LE, ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
    AV_PIX_FMT_GBRAPF32BE, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
    AV_PIX_FMT_GBRAPF32LE, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian

    /**
     * DRM-managed buffers exposed through PRIME buffer sharing.
     *
     * data[0] points to an AVDRMFrameDescriptor.
     */
    AV_PIX_FMT_DRM_PRIME,
    /**
     * Hardware surfaces for OpenCL.
     *
     * data[i] contain 2D image objects (typed in C as cl_mem, used
     * in OpenCL as image2d_t) for each plane of the surface.
     */
    AV_PIX_FMT_OPENCL,

    AV_PIX_FMT_GRAY14BE, ///<        Y        , 14bpp, big-endian
    AV_PIX_FMT_GRAY14LE, ///<        Y        , 14bpp, little-endian

    AV_PIX_FMT_GRAYF32BE, ///< IEEE-754 single precision Y, 32bpp, big-endian
    AV_PIX_FMT_GRAYF32LE, ///< IEEE-754 single precision Y, 32bpp, little-endian

    AV_PIX_FMT_YUVA422P12BE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
    AV_PIX_FMT_YUVA422P12LE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
    AV_PIX_FMT_YUVA444P12BE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
    AV_PIX_FMT_YUVA444P12LE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian

    AV_PIX_FMT_NV24, ///< planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    AV_PIX_FMT_NV42, ///< as above, but U and V bytes are swapped

    /**
     * Vulkan hardware images.
     *
     * data[0] points to an AVVkFrame
     */
    AV_PIX_FMT_VULKAN,

    AV_PIX_FMT_Y210BE, ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
    AV_PIX_FMT_Y210LE, ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian

    AV_PIX_FMT_X2RGB10LE, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
    AV_PIX_FMT_X2RGB10BE, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
    AV_PIX_FMT_X2BGR10LE, ///< packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), little-endian, X=unused/undefined
    AV_PIX_FMT_X2BGR10BE, ///< packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), big-endian, X=unused/undefined

    AV_PIX_FMT_P210BE, ///< interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, big-endian
    AV_PIX_FMT_P210LE, ///< interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, little-endian

    AV_PIX_FMT_P410BE, ///< interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, big-endian
    AV_PIX_FMT_P410LE, ///< interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, little-endian

    AV_PIX_FMT_P216BE, ///< interleaved chroma YUV 4:2:2, 32bpp, big-endian
    AV_PIX_FMT_P216LE, ///< interleaved chroma YUV 4:2:2, 32bpp, little-endian

    AV_PIX_FMT_P416BE, ///< interleaved chroma YUV 4:4:4, 48bpp, big-endian
    AV_PIX_FMT_P416LE, ///< interleaved chroma YUV 4:4:4, 48bpp, little-endian

    AV_PIX_FMT_VUYA, ///< packed VUYA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), VUYAVUYA...

    AV_PIX_FMT_RGBAF16BE, ///< IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., big-endian
    AV_PIX_FMT_RGBAF16LE, ///< IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., little-endian

    AV_PIX_FMT_VUYX, ///< packed VUYX 4:4:4:4, 32bpp, Variant of VUYA where alpha channel is left undefined

    AV_PIX_FMT_P012LE, ///< like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, little-endian
    AV_PIX_FMT_P012BE, ///< like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, big-endian

    AV_PIX_FMT_Y212BE, ///< packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, big-endian
    AV_PIX_FMT_Y212LE, ///< packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, little-endian

    AV_PIX_FMT_XV30BE, ///< packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), big-endian, variant of Y410 where alpha channel is left undefined
    AV_PIX_FMT_XV30LE, ///< packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), little-endian, variant of Y410 where alpha channel is left undefined

    AV_PIX_FMT_XV36BE, ///< packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, big-endian, variant of Y412 where alpha channel is left undefined
    AV_PIX_FMT_XV36LE, ///< packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, little-endian, variant of Y412 where alpha channel is left undefined

    AV_PIX_FMT_RGBF32BE, ///< IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., big-endian
    AV_PIX_FMT_RGBF32LE, ///< IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., little-endian

    AV_PIX_FMT_RGBAF32BE, ///< IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
    AV_PIX_FMT_RGBAF32LE, ///< IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian

    AV_PIX_FMT_P212BE, ///< interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, big-endian
    AV_PIX_FMT_P212LE, ///< interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, little-endian

    AV_PIX_FMT_P412BE, ///< interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, big-endian
    AV_PIX_FMT_P412LE, ///< interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, little-endian

    AV_PIX_FMT_GBRAP14BE, ///< planar GBR 4:4:4:4 56bpp, big-endian
    AV_PIX_FMT_GBRAP14LE, ///< planar GBR 4:4:4:4 56bpp, little-endian

    /**
     * Hardware surfaces for Direct3D 12.
     *
     * data[0] points to an AVD3D12VAFrame
     */
    AV_PIX_FMT_D3D12,

    AV_PIX_FMT_AYUV, ///< packed AYUV 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), AYUVAYUV...

    AV_PIX_FMT_UYVA, ///< packed UYVA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), UYVAUYVA...

    AV_PIX_FMT_VYU444, ///< packed VYU 4:4:4, 24bpp (1 Cr & Cb sample per 1x1 Y), VYUVYU...

    AV_PIX_FMT_V30XBE, ///< packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), big-endian
    AV_PIX_FMT_V30XLE, ///< packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), little-endian

    AV_PIX_FMT_RGBF16BE, ///< IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., big-endian
    AV_PIX_FMT_RGBF16LE, ///< IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., little-endian

    AV_PIX_FMT_RGBA128BE, ///< packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
    AV_PIX_FMT_RGBA128LE, ///< packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian

    AV_PIX_FMT_RGB96BE, ///< packed RGBA 32:32:32, 96bpp, RGBRGB..., big-endian
    AV_PIX_FMT_RGB96LE, ///< packed RGBA 32:32:32, 96bpp, RGBRGB..., little-endian

    AV_PIX_FMT_Y216BE, ///< packed YUV 4:2:2 like YUYV422, 32bpp, big-endian
    AV_PIX_FMT_Y216LE, ///< packed YUV 4:2:2 like YUYV422, 32bpp, little-endian

    AV_PIX_FMT_XV48BE, ///< packed XVYU 4:4:4, 64bpp, big-endian, variant of Y416 where alpha channel is left undefined
    AV_PIX_FMT_XV48LE, ///< packed XVYU 4:4:4, 64bpp, little-endian, variant of Y416 where alpha channel is left undefined

    AV_PIX_FMT_GBRPF16BE, ///< IEEE-754 half precision planer GBR 4:4:4, 48bpp, big-endian
    AV_PIX_FMT_GBRPF16LE, ///< IEEE-754 half precision planer GBR 4:4:4, 48bpp, little-endian
    AV_PIX_FMT_GBRAPF16BE, ///< IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, big-endian
    AV_PIX_FMT_GBRAPF16LE, ///< IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, little-endian

    AV_PIX_FMT_GRAYF16BE, ///< IEEE-754 half precision Y, 16bpp, big-endian
    AV_PIX_FMT_GRAYF16LE, ///< IEEE-754 half precision Y, 16bpp, little-endian

    /**
     * HW acceleration through AMF. data[0] contain AMFSurface pointer
     */
    AV_PIX_FMT_AMF_SURFACE,

    AV_PIX_FMT_GRAY32BE, ///<         Y        , 32bpp, big-endian
    AV_PIX_FMT_GRAY32LE, ///<         Y        , 32bpp, little-endian

    AV_PIX_FMT_YAF32BE, ///< IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, big-endian
    AV_PIX_FMT_YAF32LE, ///< IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, little-endian

    AV_PIX_FMT_YAF16BE, ///< IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, big-endian
    AV_PIX_FMT_YAF16LE, ///< IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, little-endian

    AV_PIX_FMT_GBRAP32BE, ///< planar GBRA 4:4:4:4 128bpp, big-endian
    AV_PIX_FMT_GBRAP32LE, ///< planar GBRA 4:4:4:4 128bpp, little-endian

    AV_PIX_FMT_NB ///< number of pixel formats, DO NOT USE THIS if you want to link with shared libav* because the number of formats might differ between versions
}

struct AVCodecInternal;

struct AVCodecContext
{
    const AVClass* av_class;
    int log_level_offset;
    AVMediaType codec_type; /* see AVMEDIA_TYPE_xxx */
    AVCodec* codec;
    AVCodecID codec_id; /* see AV_CODEC_ID_xxx */
    uint codec_tag;
    void* priv_data;
    AVCodecInternal* internal;
    void* opaque;
    int64_t bit_rate;
    int flags;
    int flags2;
    uint8_t* extradata;
    int extradata_size;
    AVRational time_base;
    AVRational pkt_timebase;
    AVRational framerate;
    int delay;
    int width, height;
    int coded_width, coded_height;
    AVRational sample_aspect_ratio;
    AVPixelFormat pix_fmt;
    AVPixelFormat sw_pix_fmt;
}

struct AVClass;

enum SwsDither
{
    SWS_DITHER_NONE = 0, /* disable dithering */
    SWS_DITHER_AUTO, /* auto-select from preset */
    SWS_DITHER_BAYER, /* ordered dither matrix */
    SWS_DITHER_ED, /* error diffusion */
    SWS_DITHER_A_DITHER, /* arithmetic addition */
    SWS_DITHER_X_DITHER, /* arithmetic xor */
    SWS_DITHER_NB, /* not part of the ABI */



}

enum SwsAlphaBlend
{
    SWS_ALPHA_BLEND_NONE = 0,
    SWS_ALPHA_BLEND_UNIFORM,
    SWS_ALPHA_BLEND_CHECKERBOARD,
    SWS_ALPHA_BLEND_NB, /* not part of the ABI */



}

enum SwsFlags
{
    /**
     * Scaler selection options. Only one may be active at a time.
     */
    SWS_FAST_BILINEAR = 1 << 0, ///< fast bilinear filtering
    SWS_BILINEAR = 1 << 1, ///< bilinear filtering
    SWS_BICUBIC = 1 << 2, ///< 2-tap cubic B-spline
    SWS_X = 1 << 3, ///< experimental
    SWS_POINT = 1 << 4, ///< nearest neighbor
    SWS_AREA = 1 << 5, ///< area averaging
    SWS_BICUBLIN = 1 << 6, ///< bicubic luma, bilinear chroma
    SWS_GAUSS = 1 << 7, ///< gaussian approximation
    SWS_SINC = 1 << 8, ///< unwindowed sinc
    SWS_LANCZOS = 1 << 9, ///< 3-tap sinc/sinc
    SWS_SPLINE = 1 << 10, ///< cubic Keys spline

    /**
     * Return an error on underspecified conversions. Without this flag,
     * unspecified fields are defaulted to sensible values.
     */
    SWS_STRICT = 1 << 11,

    /**
     * Emit verbose log of scaling parameters.
     */
    SWS_PRINT_INFO = 1 << 12,

    /**
     * Perform full chroma upsampling when upscaling to RGB.
     *
     * For example, when converting 50x50 yuv420p to 100x100 rgba, setting this flag
     * will scale the chroma plane from 25x25 to 100x100 (4:4:4), and then convert
     * the 100x100 yuv444p image to rgba in the final output step.
     *
     * Without this flag, the chroma plane is instead scaled to 50x100 (4:2:2),
     * with a single chroma sample being re-used for both of the horizontally
     * adjacent RGBA output pixels.
     */
    SWS_FULL_CHR_H_INT = 1 << 13,

    /**
     * Perform full chroma interpolation when downscaling RGB sources.
     *
     * For example, when converting a 100x100 rgba source to 50x50 yuv444p, setting
     * this flag will generate a 100x100 (4:4:4) chroma plane, which is then
     * downscaled to the required 50x50.
     *
     * Without this flag, the chroma plane is instead generated at 50x100 (dropping
     * every other pixel), before then being downscaled to the required 50x50
     * resolution.
     */
    SWS_FULL_CHR_H_INP = 1 << 14,

    /**
     * Force bit-exact output. This will prevent the use of platform-specific
     * optimizations that may lead to slight difference in rounding, in favor
     * of always maintaining exact bit output compatibility with the reference
     * C code.
     *
     * Note: It is recommended to set both of these flags simultaneously.
     */
    SWS_ACCURATE_RND = 1 << 18,
    SWS_BITEXACT = 1 << 19,

    /**
     * Deprecated flags.
     */
    SWS_DIRECT_BGR = 1 << 15, ///< This flag has no effect
    SWS_ERROR_DIFFUSION = 1 << 23, ///< Set `SwsContext.dither` instead
}

struct SwsContext
{
    const AVClass* av_class;
    void* opaque;
    uint flags;
    double[2] scaler_params;
    int threads;
    SwsDither dither;
    SwsAlphaBlend alpha_blend;
    int gamma_flag;
    int src_w, src_h; ///< Width and height of the source frame
    int dst_w, dst_h; ///< Width and height of the destination frame
    int src_format; ///< Source pixel format
    int dst_format; ///< Destination pixel format
    int src_range; ///< Source is full range
    int dst_range; ///< Destination is full range
    int src_v_chr_pos; ///< Source vertical chroma position in luma grid / 256
    int src_h_chr_pos; ///< Source horizontal chroma position
    int dst_v_chr_pos; ///< Destination vertical chroma position
    int dst_h_chr_pos; ///< Destination horizontal chroma position
    int intent;
}

enum
{

    /**
     * Do not check for format changes.
     */
    AV_BUFFERSRC_FLAG_NO_CHECK_FORMAT = 1,

    /**
     * Immediately push the frame to the output.
     */
    AV_BUFFERSRC_FLAG_PUSH = 4,

    /**
     * Keep a reference to the frame.
     * If the frame if reference-counted, create a new reference; otherwise
     * copy the frame data.
     */
    AV_BUFFERSRC_FLAG_KEEP_REF = 8,

}

struct AVIOContext;
struct AVStreamGroup;
struct AVChapter;
struct AVProgram;
struct AVInputFormat;
struct AVOutputFormat;
struct AVIOInterruptCB;
struct av_format_control_message;

enum AVDurationEstimationMethod
{
    AVFMT_DURATION_FROM_PTS, ///< Duration accurately estimated from PTSes
    AVFMT_DURATION_FROM_STREAM, ///< Duration estimated from a stream with a known duration
    AVFMT_DURATION_FROM_BITRATE ///< Duration estimated from bitrate (less accurate)
}

struct AVFormatContext
{
    AVClass* av_class;
    AVInputFormat* iformat;
    AVOutputFormat* oformat;
    void* priv_data;
    AVIOContext* pb;
    int ctx_flags;
    uint nb_streams;
    AVStream** streams;
    uint nb_stream_groups;
    AVStreamGroup** stream_groups;
    uint nb_chapters;
    AVChapter** chapters;
    char* url;
    int64_t start_time;
    int64_t duration;
    int64_t bit_rate;
    uint packet_size;
    int max_delay;
    int flags;
    int64_t probesize;
    int64_t max_analyze_duration;
    const uint8_t* key;
    int keylen;
    uint nb_programs;
    AVProgram** programs;
    AVCodecID video_codec_id;
    AVCodecID audio_codec_id;
    AVCodecID subtitle_codec_id;
    AVCodecID data_codec_id;
    AVDictionary* metadata;
    int64_t start_time_realtime;
    int fps_probe_size;
    int error_recognition;
    AVIOInterruptCB* interrupt_callback;
    int _debug;
    int max_streams;
    uint max_index_size;
    uint max_picture_buffer;
    int64_t max_interleave_delta;
    int max_ts_probe;
    int max_chunk_duration;
    int max_chunk_size;
    int max_probe_packets;
    int strict_std_compliance;
    int event_flags;
    int avoid_negative_ts;
    int audio_preload;
    int use_wallclock_as_timestamps;
    int skip_estimate_duration_from_pts;
    int avio_flags;
    AVDurationEstimationMethod duration_estimation_method;
    uint correct_ts_overflow;
    int seek2any;
    int flush_packets;
    int probe_score;
    int format_probesize;
    char* codec_whitelist;
    char* format_whitelist;
    char* protocol_whitelist;
    char* protocol_blacklist;
    int io_repositioned;
    AVCodec* video_codec;
    AVCodec* audio_codec;
    AVCodec* subtitle_codec;
    AVCodec* data_codec;
    int metadata_header_padding;
    void* opaque;
    //av_format_control_message control_message_cb;
    av_format_control_message* control_message_cb;
    int64_t output_ts_offset;
    uint8_t* dump_separator;
    //TODO callbacks alias
    void* io_open;
    void* io_close;
    int64_t duration_probesize;
}

enum AV_LOG_SKIP_REPEATED = 1;
enum AV_LOG_PRINT_LEVEL = 2;
enum AV_LOG_ERROR = 16;

struct AVStream
{
    const AVClass* av_class;
    int index; /**< stream index in AVFormatContext */
    int id;
    AVCodecParameters* codecpar;
    void* priv_data;
    AVRational time_base;
    int64_t start_time;
    int64_t duration;
    int64_t nb_frames; ///< number of frames in this stream if known or 0
    int disposition;
    AVDiscard discard; ///< Selects which packets can be discarded at will and do not need to be demuxed.
    AVRational sample_aspect_ratio;
    AVDictionary* metadata;
    AVRational avg_frame_rate;
    AVPacket attached_pic;
    int event_flags;
    AVRational r_frame_rate;
    int pts_wrap_bits;
}

enum AVDiscard
{
    AVDISCARD_NONE = -16, ///< discard nothing
    AVDISCARD_DEFAULT = 0, ///< discard useless packets like 0 size packets in avi
    AVDISCARD_NONREF = 8, ///< discard all non reference
    AVDISCARD_BIDIR = 16, ///< discard all bidirectional frames
    AVDISCARD_NONINTRA = 24, ///< discard all non intra frames
    AVDISCARD_NONKEY = 32, ///< discard all frames except keyframes
    AVDISCARD_ALL = 48, ///< discard all
}
