module api.dm.kit.graphics.canvases.effects.canvas_effects;

import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

void glowNeon(GraphicCanvas canvas, RGBA neonColor, float glowRadius = 20.0f, size_t steps = 12, float alphaFactor = 0.15, float coreBaseLevel = 0.9, float coreColorScale = 0.1, float colorWidth = 2.5)
{
    canvas.save;
    canvas.lineJoin = GraphicCanvas.LineJoin.round;
    canvas.lineEnd = GraphicCanvas.LineEnd.round;

    RGBA layerColor = neonColor;

    foreach_reverse (i; 1 .. steps + 1)
    {
        const factor = cast(float) i / steps;
        layerColor.a = (1.0f - factor) * alphaFactor;
        canvas.color = layerColor;
        canvas.lineWidth = factor * glowRadius;
        canvas.strokePreserve;
    }

    RGBA coreColor = RGBA.fromColorNorm(
        coreBaseLevel + neonColor.rNorm * coreColorScale,
        coreBaseLevel + neonColor.gNorm * coreColorScale,
        coreBaseLevel + neonColor.bNorm * coreColorScale,
        1.0f
    );

    canvas.color = coreColor;
    canvas.lineWidth = colorWidth;
    canvas.strokePreserve;
    canvas.restore;
}
