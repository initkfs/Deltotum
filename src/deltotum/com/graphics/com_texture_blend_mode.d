module deltotum.com.graphics.com_texture_blend_mode;

/**
 * Authors: initkfs
 */
enum ComTextureBlendMode
{
    none,
    /*
    alpha blending
    dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
    dstA = srcA + (dstA * (1-srcA))
    */
    blend,
    /*
    additive blending
    dstRGB = (srcRGB * srcA) + dstRGB
    dstA = dstA
    */
    add,
    /*
    color modulate
    dstRGB = srcRGB * dstRGB
    dstA = dstA
    */
    mod,
    /*
    color multiply
    dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA))
    dstA = (srcA * dstA) + (dstA * (1-srcA))
    */
    mul,
}
