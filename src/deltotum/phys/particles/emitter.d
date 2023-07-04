module deltotum.phys.particles.emitter;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.phys.particles.particle : Particle;
import deltotum.phys.particles.config.emitter_config : EmitterConfig;
import deltotum.core.configs.attributes.configurable : Configurable;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.random : Random;

import std.stdio;

/**
 * Authors: initkfs
 */
class Emitter : Sprite
{
    Particle delegate() particleFactory;
    bool delegate(Particle) onParticleUpdate;

    bool isActive;

    @Configurable
    int lifetime = 200;
    @Configurable
    int countPerFrame = 10;
    @Configurable
    Vector2d minVelocity;
    @Configurable
    Vector2d maxVelocity;
    @Configurable
    Vector2d minAcceleration;
    @Configurable
    Vector2d maxAcceleration;

    private
    {
        Particle[] particles;
        Random random;
        EmitterConfig emitterConfig;
    }

    this(bool isActive = false, EmitterConfig config = null)
    {
        random = new Random;
        this.isActive = isActive;
        if (config is null)
        {
            import deltotum.phys.particles.config.json_emitter_config : JsonEmitterConfig;

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

        if (!particle.isBuilt)
        {
            build(particle);
        }

        if (!particle.isInitialized)
        {
            particle.initialize;
        }

        if (!particle.isCreated)
        {
            particle.create;
        }

        if (!particle.parent)
        {
            add(particle);
        }

        particles ~= particle;
        initParticle(particle);
    }

    Vector2d particleInitPos()
    {
        if (width > 0 || height > 0)
        {
            const b = bounds;
            return Vector2d(b.middleX, b.middleY);
        }
        return Vector2d(x, y);
    }

    void initParticle(Particle particle)
    {
        particle.lifetime = lifetime;
        Vector2d pos = particleInitPos;
        if (particle.width > 0)
        {
            pos.x -= particle.width / 2;
        }

        if (particle.height > 0)
        {
            pos.y -= particle.height / 2;
        }
        particle.position = pos;
        particle.isLayoutManaged = false;
        // particle.isManaged = false;

        particle.velocity = random.randomBerweenVec(minVelocity, maxVelocity);
        particle.acceleration = random.randomBerweenVec(minAcceleration, maxAcceleration);

        if (!particle.physBody)
        {
            particle.isPhysicsEnabled = true;
        }

        particle.id = "particle";

        particle.isVisible = true;
        particle.isUpdatable = true;
        particle.isAlive = true;
    }

    protected void resetParticle(Particle p)
    {
        p.isVisible = false;
        p.isUpdatable = false;

        p.position = particleInitPos;

        p.lifetime = 0;
        p.age = 0;
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
                p.isAlive = false;
                resetParticle(p);
                continue;
            }

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
        foreach (p; particles)
        {
            if (revived == newParticlesCount)
            {
                break;
            }

            if (!p.isAlive)
            {
                initParticle(p);
                p.isAlive = true;
                revived++;
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
