module deltotum.particles.emitter;

import deltotum.display.display_object : DisplayObject;
import deltotum.particles.particle : Particle;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.random : Random;

import std.stdio;

/**
 * Authors: initkfs
 */
class Emitter : DisplayObject
{
    @property int lifetime = 200;
    @property int countPerFrame = 10;
    @property Particle delegate() particleFactory;
    @property double particleMass = 0;
    @property bool delegate(Particle) onParticleUpdate;
    @property double minVelocityX = 0;
    @property double maxVelocityX = 0;
    @property double minVelocityY = 0;
    @property double maxVelocityY = 0;
    @property double minAccelerationX = 0;
    @property double maxAccelerationX = 0;
    @property double minAccelerationY = 0;
    @property double maxAccelerationY = 0;
    @property bool isActive;

    private
    {
        //TODO pools implementation
        Particle[] particles;
        @property Random random;
    }

    this(bool isActive = true)
    {
        super();
        //TODO seed, etc
        random = Random(42);
        this.isActive = isActive;
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

        if(!particle.isCreated){
            particle.create;
        }

        particle.create;
        particles ~= particle;
        tuneParticle(particle);
        particle.isAlive = true;
        add(particle);
    }

    protected void tuneParticle(Particle particle) pure @safe
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

    protected void resetParticle(Particle p) const @nogc nothrow pure @safe
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
                p.isAlive = false;
                p.isUpdatable = false;
                p.isVisible = false;
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
                    p.isAlive = true;
                    p.isUpdatable = true;
                    p.isVisible = true;
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
}
