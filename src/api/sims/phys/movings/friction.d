module api.sims.phys.movings.friction;

/**
 * Authors: initkfs
 */
 enum SimpleFriction : float {

    ice = 0.99f,            // Very slippery
    air = 0.997f,           // Almost no friction in air
    normal = 0.94f,         // Default ground
    sticky = 0.88f,         // Mud, honey
    wall = 0.0f,            // Complete stop
    
    metal = 0.97f,
    wood = 0.95f,
    stone = 0.93f,
    dirt = 0.91f,
    grass = 0.89f,
    sand = 0.87f,
    mud = 0.84f,
    water = 0.80f           // Swimming/drag effect
}

enum GameFriction : float {

    // Platformer values
    playerOnIce = 0.99f,        // Player sliding on ice
    playerOnAir = 0.997f,       // Air friction (minimal)
    playerOnGround = 0.93f,     // Normal ground friction
    
    // Racing game values
    tireDryAsphalt = 0.96f,     // Racing tires on dry track
    tireWetAsphalt = 0.92f,     // Racing tires on wet track
    tireGrass = 0.88f,          // Off-road on grass
    tireSand = 0.84f,           // Off-road on sand
    tireIce = 0.70f,            // Extreme slide on ice
    
    // Puzzle/Arcade values
    pinballBumper = 0.85f,      // Pinball bumper bounce
    pinballFlipper = 0.90f,     // Pinball flipper surface
    puzzleIceBlock = 0.98f,     // Ice block sliding
    puzzleStoneBlock = 0.95f,   // Stone block sliding
    
    // Special effects
    waterDrag = 0.89f,          // Moving through water
    oilSlick = 0.97f,           // Slippery oil spill
    magneticPull = 0.60f,       // Magnetic attraction
    blackHole = 0.40f           // Extreme gravitational pull
}

enum FrictionMaterial : float {
    // Super slippery (almost frictionless)
    ice = 0.995f,           // Ice, wet ice
    teflon = 0.99f,         // Teflon on teflon
    airHockey = 0.985f,     // Air hockey table
    
    // Slippery
    wetMarble = 0.98f,      // Wet marble, soap
    marble = 0.975f,        // Polished marble, glass
    metal = 0.97f,          // Steel on steel (oiled)
    
    // Normal
    hardwood = 0.965f,      // Polished wood floor
    linoleum = 0.96f,       // Linoleum, vinyl
    asphalt = 0.955f,       // Dry asphalt road
    concrete = 0.95f,       // Smooth concrete
    
    // High friction
    rubber = 0.94f,         // Rubber on dry concrete
    carpet = 0.93f,         // Medium pile carpet
    grass = 0.92f,          // Dry grass field
    sand = 0.90f,           // Loose dry sand
    
    // Very high friction
    mud = 0.87f,            // Wet mud, clay
    gravel = 0.85f,         // Loose gravel
    velcro = 0.80f,         // Velcro-like surface
    
    // Extreme (almost instant stop)
    glue = 0.70f,           // Like sticky surface
    staticf = 0.50f,         // Magnetic attraction effect
    wall = 0.0f             // Instant stop (collision)
}