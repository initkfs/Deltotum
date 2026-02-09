module api.dm.lib.libjpeg.native.types;
/**
 * Authors: initkfs
 */

alias tjhandle = void*;

enum TJSAMP
{
    /**
   * 4:4:4 chrominance subsampling (no chrominance subsampling).  The JPEG or
   * YUV image will contain one chrominance component for every pixel in the
   * source image.
   */
    TJSAMP_444 = 0,
    /**
   * 4:2:2 chrominance subsampling.  The JPEG or YUV image will contain one
   * chrominance component for every 2x1 block of pixels in the source image.
   */
    TJSAMP_422,
    /**
   * 4:2:0 chrominance subsampling.  The JPEG or YUV image will contain one
   * chrominance component for every 2x2 block of pixels in the source image.
   */
    TJSAMP_420,
    /**
   * Grayscale.  The JPEG or YUV image will contain no chrominance components.
   */
    TJSAMP_GRAY,
    /**
   * 4:4:0 chrominance subsampling.  The JPEG or YUV image will contain one
   * chrominance component for every 1x2 block of pixels in the source image.
   *
   * @note 4:4:0 subsampling is not fully accelerated in libjpeg-turbo.
   */
    TJSAMP_440,
    /**
   * 4:1:1 chrominance subsampling.  The JPEG or YUV image will contain one
   * chrominance component for every 4x1 block of pixels in the source image.
   * JPEG images compressed with 4:1:1 subsampling will be almost exactly the
   * same size as those compressed with 4:2:0 subsampling, and in the
   * aggregate, both subsampling methods produce approximately the same
   * perceptual quality.  However, 4:1:1 is better able to reproduce sharp
   * horizontal features.
   *
   * @note 4:1:1 subsampling is not fully accelerated in libjpeg-turbo.
   */
    TJSAMP_411
}

enum TJFLAG_FASTDCT = 2048;
enum TJFLAG_ACCURATEDCT = 4096;

enum TJPF
{
    /**
   * RGB pixel format.  The red, green, and blue components in the image are
   * stored in 3-byte pixels in the order R, G, B from lowest to highest byte
   * address within each pixel.
   */
    TJPF_RGB = 0,
    /**
   * BGR pixel format.  The red, green, and blue components in the image are
   * stored in 3-byte pixels in the order B, G, R from lowest to highest byte
   * address within each pixel.
   */
    TJPF_BGR,
    /**
   * RGBX pixel format.  The red, green, and blue components in the image are
   * stored in 4-byte pixels in the order R, G, B from lowest to highest byte
   * address within each pixel.  The X component is ignored when compressing
   * and undefined when decompressing.
   */
    TJPF_RGBX,
    /**
   * BGRX pixel format.  The red, green, and blue components in the image are
   * stored in 4-byte pixels in the order B, G, R from lowest to highest byte
   * address within each pixel.  The X component is ignored when compressing
   * and undefined when decompressing.
   */
    TJPF_BGRX,
    /**
   * XBGR pixel format.  The red, green, and blue components in the image are
   * stored in 4-byte pixels in the order R, G, B from highest to lowest byte
   * address within each pixel.  The X component is ignored when compressing
   * and undefined when decompressing.
   */
    TJPF_XBGR,
    /**
   * XRGB pixel format.  The red, green, and blue components in the image are
   * stored in 4-byte pixels in the order B, G, R from highest to lowest byte
   * address within each pixel.  The X component is ignored when compressing
   * and undefined when decompressing.
   */
    TJPF_XRGB,
    /**
   * Grayscale pixel format.  Each 1-byte pixel represents a luminance
   * (brightness) level from 0 to 255.
   */
    TJPF_GRAY,
    /**
   * RGBA pixel format.  This is the same as @ref TJPF_RGBX, except that when
   * decompressing, the X component is guaranteed to be 0xFF, which can be
   * interpreted as an opaque alpha channel.
   */
    TJPF_RGBA,
    /**
   * BGRA pixel format.  This is the same as @ref TJPF_BGRX, except that when
   * decompressing, the X component is guaranteed to be 0xFF, which can be
   * interpreted as an opaque alpha channel.
   */
    TJPF_BGRA,
    /**
   * ABGR pixel format.  This is the same as @ref TJPF_XBGR, except that when
   * decompressing, the X component is guaranteed to be 0xFF, which can be
   * interpreted as an opaque alpha channel.
   */
    TJPF_ABGR,
    /**
   * ARGB pixel format.  This is the same as @ref TJPF_XRGB, except that when
   * decompressing, the X component is guaranteed to be 0xFF, which can be
   * interpreted as an opaque alpha channel.
   */
    TJPF_ARGB,
    /**
   * CMYK pixel format.  Unlike RGB, which is an additive color model used
   * primarily for display, CMYK (Cyan/Magenta/Yellow/Key) is a subtractive
   * color model used primarily for printing.  In the CMYK color model, the
   * value of each color component typically corresponds to an amount of cyan,
   * magenta, yellow, or black ink that is applied to a white background.  In
   * order to convert between CMYK and RGB, it is necessary to use a color
   * management system (CMS.)  A CMS will attempt to map colors within the
   * printer's gamut to perceptually similar colors in the display's gamut and
   * vice versa, but the mapping is typically not 1:1 or reversible, nor can it
   * be defined with a simple formula.  Thus, such a conversion is out of scope
   * for a codec library.  However, the TurboJPEG API allows for compressing
   * CMYK pixels into a YCCK JPEG image (see #TJCS_YCCK) and decompressing YCCK
   * JPEG images into CMYK pixels.
   */
    TJPF_CMYK,
    /**
   * Unknown pixel format.  Currently this is only used by #tjLoadImage().
   */
    TJPF_UNKNOWN = -1
}
