module deltotum.phys.particles.config.emitter_config;

import deltotum.phys.particles.emitter : Emitter;

/**
 * Authors: initkfs
 */
abstract class EmitterConfig
{
    abstract string toConfig(Emitter emitter);

    abstract bool applyConfig(Emitter emitter, string config);

}
