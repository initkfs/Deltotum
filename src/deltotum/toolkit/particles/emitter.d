module deltotum.toolkit.particles.emitter;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.particles.particle : Particle;
import deltotum.toolkit.particles.config.emitter_config : EmitterConfig;
import deltotum.core.configs.attributes.configurable : Configurable;
import deltotum.maths.vector2d : Vector2d;
import deltotum.maths.random : Random;

import std.stdio;

/**
 * Authors: initkfs
 */
class Emitter : DisplayObject
{
    Particle delegate() particleFactory;
    bool delegate(Particle) onParticleUpdate;

    bool isActive;

    @Configurable
    int lifetime = 200;
    @Configurable
    int countPerFrame = 10;
    @Configurable
    double particleMass = 0;
    @Configurable
    double minVelocityX = 0;
    @Configurable
    double maxVelocityX = 0;
    @Configurable
    double minVelocityY = 0;
    @Configurable
    double maxVelocityY = 0;
    @Configurable
    double minAccelerationX = 0;
    @Configurable
    double maxAccelerationX = 0;
    @Configurable
    double minAccelerationY = 0;
    @Configurable
    double maxAccelerationY = 0;

    private
    {
        //TODO pools implementation
        Particle[] particles;
        Random random;
        EmitterConfig emitterConfig;
    }

    this(bool isActive = true, EmitterConfig config = null)
    {
        super();
        //TODO seed, etc
        random = new Random;
        this.isActive = isActive;
        if (config is null)
        {
            import deltotum.toolkit.particles.config.json_emitter_config : JsonEmitterConfig;

            emitterConfig = new JsonEmitterConfig;
        }
    }

    void emit()
    {
        if (particleFactory is null)
        {
            return;
        }

        auto particle = particleFactory();
        particle.isManaged = false;
        if (!particle.isBuilt)
        {
            build(particle);
        }

        if (!particle.isCreated)
        {
            particle.create;
        }

        particle.create;
        particles ~= particle;
        tuneParticle(particle);
        particle.alive(true);
        add(particle);
    }

    protected void tuneParticle(Particle particle)
    {
        particle.lifetime = lifetime;
        particle.x = x;
        particle.y = y;
        particle.mass = particleMass;

        if (minVelocityX != maxVelocityY)
        {
            particle.velocity.x = random.randomBetween(minVelocityX, maxVelocityX);
        }
        else
        {
            particle.velocity.x = minVelocityX;
        }

        if (minVelocityY != maxVelocityY)
        {
            particle.velocity.y = random.randomBetween(minVelocityY, maxVelocityY);
        }
        else
        {
            particle.velocity.y = minVelocityY;
        }

        if (minAccelerationX != maxAccelerationX)
        {
            particle.acceleration.x = random.randomBetween(minAccelerationX, maxAccelerationX);
        }
        else
        {
            particle.acceleration.x = minAccelerationX;
        }

        if (minAccelerationY != maxAccelerationY)
        {
            particle.acceleration.y = random.randomBetween(minAccelerationY, maxAccelerationY);
        }
        else
        {
            particle.acceleration.y = minAccelerationY;
        }
    }

    protected void resetParticle(Particle p) const
    {
        p.lifetime = 0;
        p.age = 0;
        p.velocity.x = 0;
        p.velocity.y = 0;
        p.acceleration.x = 0;
        p.acceleration.y = 0;
        p.angle = 0;
        p.x = 0;
        p.y = 0;
    }

    override bool draw()
    {
        bool redraw;
        foreach (Particle p; particles)
        {
            if (p.isAlive)
            {
                p.draw;
                if (!redraw)
                {
                    redraw = true;
                }
            }
        }
        return redraw;
    }

    override void update(double delta)
    {
        super.update(delta);

        int aliveCount = 0;
        foreach (Particle p; particles)
        {
            if (!p.isAlive)
            {
                continue;
            }

            bool alive = true;
            if (onParticleUpdate !is null)
            {
                alive = onParticleUpdate(p);
            }

            if (!alive || p.age >= p.lifetime)
            {
                p.alive(false);
                resetParticle(p);
                continue;
            }

            //p.update(delta);
            p.age++;
            aliveCount++;
        }

        if (!isActive)
        {
            return;
        }

        int newParticlesCount = 0;
        if (aliveCount < countPerFrame)
        {
            newParticlesCount = countPerFrame - aliveCount;
        }

        if (newParticlesCount <= 0)
        {
            return;
        }

        int revived;
        if (particles.length > 0 && aliveCount < particles.length)
        {
            foreach (p; particles)
            {
                if (revived == newParticlesCount)
                {
                    break;
                }

                if (!p.isAlive)
                {
                    tuneParticle(p);
                    p.alive(true);
                    revived++;
                }
            }
        }

        int newParticles = newParticlesCount - revived;
        if (newParticles > 0)
        {
            foreach (i; 0 .. newParticles)
            {
                emit;
            }
        }
    }

    string toConfig()
    {
        return emitterConfig.toConfig(this);
    }

    bool applyConfig(string config)
    {
        return emitterConfig.applyConfig(this, config);
    }
}
