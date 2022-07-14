module deltotum.particles.emitter;

import deltotum.display.display_object : DisplayObject;
import deltotum.particles.particle : Particle;
import deltotum.math.vector2d : Vector2D;

import std.stdio;

/**
 * Authors: initkfs
 */
class Emitter : DisplayObject
{
    @property int lifetime = 200;
    @property int countPerFrame;
    @property Particle delegate() particleFactory;
    @property Vector2D* particleVelocity;
    @property Vector2D* particleAcceleration;
    @property double particleMass = 0;
    @property bool delegate(Particle) onParticleUpdate;

    private
    {
        //TODO pools implementation
        Particle[] particles;
    }

    this()
    {
        super();
        particleVelocity = new Vector2D;
        particleAcceleration = new Vector2D;
    }

    void emit()
    {
        auto particle = particleFactory();
        particles ~= particle;
        tuneParticle(particle);
        particle.isAlive = true;
    }

    protected void tuneParticle(Particle particle) @nogc nothrow pure @safe
    {
        particle.lifetime = lifetime;
        particle.x = x;
        particle.y = y;
        particle.mass = particleMass;
        particle.velocity.x = particleVelocity.x;
        particle.velocity.y = particleVelocity.y;
        particle.acceleration.x = particleAcceleration.x;
        particle.acceleration.y = particleAcceleration.y;
    }

    protected void resetParticle(Particle p) const @nogc nothrow pure @safe
    {
        p.lifetime = 0;
        p.age = 0;
        p.velocity.x = 0;
        p.velocity.y = 0;
        p.acceleration.x = 0;
        p.acceleration.y = 0;
        p.x = 0;
        p.y = 0;
    }

    override void drawContent()
    {
        foreach (Particle p; particles)
        {
            if (p.isAlive)
            {
                p.drawContent;
            }
        }
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

            if(!alive){
                p.isAlive = false;
                resetParticle(p);
                continue;
            }

            if (p.age >= p.lifetime)
            {
                p.isAlive = false;
                resetParticle(p);
                continue;
            }

            p.update(delta);
            p.age++;
            aliveCount++;
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
