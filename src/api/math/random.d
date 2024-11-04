module api.math.random;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.math.geom2.vec2 : Vec2d;
import std.random : uniform, unpredictableSeed, StdRandom = Random;
import std.range.primitives;
import std.typecons : Nullable, Tuple;
import std.traits;

/**
 * Authors: initkfs
 */
class Random
{

    private
    {
        StdRandom rnd;
    }

    this(uint seed = unpredictableSeed)
    {
        rnd = StdRandom(seed);
    }

    void seed(uint newSeed) pure @safe
    {
        rnd.seed = newSeed;
    }

    T between(T)(T minValueInclusive, T maxValueInclusive) pure @safe
            if (isNumeric!T)
    {
        if (minValueInclusive == maxValueInclusive)
        {
            return minValueInclusive;
        }

        if (minValueInclusive > maxValueInclusive)
        {
            return T.init;
        }

        // https://issues.dlang.org/show_bug.cgi?id=15147
        T value = uniform!"[]"(minValueInclusive, maxValueInclusive, rnd);
        return value;
    }

    T betweenType(T)() pure @safe if (isNumeric!T)
    {
        return between!T(T.min, T.max);
    }

    double between0to1() pure @safe
    {
        return between!double(0, 1);
    }

    Vec2d betweenVec(Vec2d min, Vec2d max) pure @safe
    {
        const newX = between(min.x, max.x);
        const newY = between(min.y, max.y);
        return Vec2d(newX, newY);
    }

    Nullable!(Unqual!U) any(T : U[], U)(T container) pure @safe
    {
        Nullable!(Unqual!U) result;
        immutable containerLength = container.length;
        if (containerLength == 0)
        {
            return result;
        }

        if (containerLength == 1)
        {
            result = container[0];
            return result;
        }

        immutable size_t index = between!size_t(0, containerLength - 1);
        result = container[index];
        return result;
    }

    void shuffle(R)(R range) pure @safe if (isRandomAccessRange!R)
    {
        import std.random : randomShuffle;

        randomShuffle(range, rnd);
    }

    bool chanceHalf() pure @safe
    {
        return chance(0.5);
    }

    bool chance(double chance0to1) pure @safe
    {
        if (chance0to1 < 0 || chance0to1 > 1)
        {
            return 0;
        }

        immutable isChance = between0to1 <= chance0to1;
        return isChance;
    }

    double chanceAll(Tuple!(double, void delegate())[] chanceDelegates)
    {
        const double random0to1 = between0to1;
        double accumulator = 0;
        foreach (chanceDg; chanceDelegates)
        {
            const double chance = chanceDg[0];
            accumulator += chance;
            if (random0to1 <= accumulator)
            {
                auto delegateForRun = chanceDg[1];
                delegateForRun();
                break;
            }
        }
        return accumulator;
    }
}

unittest
{
    auto rnd = new Random;

    /*
     * between
     */
    assert(rnd.between(0, 0) == 0);
    assert(rnd.between(1, 0) == 0);

    auto zeroOrOne = rnd.between(0, 1);
    assert(zeroOrOne == 0 || zeroOrOne == 1);

    foreach (i; 0 .. 10)
    {
        auto result = rnd.between(-5, 5);
        assert(result >= -5 && result <= 5);
    }

    /*
     * between0to1
     */
    import std.math.operations : cmp;

    foreach (i; 0 .. 10)
    {
        auto res = rnd.between0to1;
        assert((cmp(res, 0) >= 0 && (cmp(res, 1.0) <= 1.0)));
    }

    /*
     * any
     */
    int[] nullArr;
    assert(rnd.any(nullArr).isNull);

    int[] oneArr = [1];
    auto oneArrRand = rnd.any(oneArr);
    assert(!oneArrRand.isNull);
    assert(oneArrRand.get == 1);

    int[] arr1 = [1, 2, 3];
    auto arr1Rand = rnd.any(arr1);
    assert(!arr1Rand.isNull);

    import std.algorithm : canFind;

    assert(arr1.canFind(arr1Rand));

    string abc = "abc";
    auto res = rnd.any(abc);
    assert(!res.isNull);
    assert(abc.canFind(res));

    /*
     * shuffle
     */
    int[] arrForShuffle = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    int[] arrShuffled = arrForShuffle.dup;
    rnd.shuffle(arrShuffled);
    assert(arrForShuffle != arrShuffled);

    import std.algorithm.sorting : sort;

    arrShuffled.sort;
    assert(arrForShuffle == arrShuffled);

    /*
     * chance
     */
    foreach (i; 0 .. 10)
    {
        auto res0 = rnd.chance(0);
        assert(!res0);

        auto res1 = rnd.chance(1);
        assert(res1);
    }
}

//See https://en.wikipedia.org/wiki/Mersenne_Twister
struct MersenneTwister
{
    private
    {
        enum : uint
        {
            n = 624,
            m = 397,
            w = 32,
            r = 31,
            UMASK = (0xffffffffu << r),
            LMASK = (0xffffffffu >> (w - r)),
            a = 0x9908b0df,
            u = 11,
            s = 7,
            t = 15,
            l = 18,
            b = 0x9d2c5680u,
            c = 0xefc60000u,
            f = 1812433253u
        }

        MersenneState state;
        uint seed;

        struct MersenneState
        {
            uint[n] stateArray;
            int stateIndex;

            uint[] slice() return pure nothrow @safe => stateArray[0 .. n];
        }
    }

    this(uint seed) pure @safe
    {
        if (seed == 0)
        {
            throw new Exception("Seed value must not be 0");
        }

        this.seed = seed;

        uint[] stateArray = state.slice;

        uint seedVal = seed;
        stateArray[0] = seedVal;
        foreach (uint i; 1 .. n)
        {
            seedVal = f * (seedVal ^ (seedVal >> (w - 2))) + i;
            stateArray[i] = seedVal;
        }
    }

    uint randu() nothrow @safe
    {
        uint[] stateArray = state.slice;

        int k = state.stateIndex;
        int j = k - (n - 1);
        if (j < 0)
        {
            j += n;
        }

        uint x = (stateArray[k] & UMASK) | (stateArray[j] & LMASK);

        uint xA = x >> 1;
        if (x & 1u)
        {
            xA ^= a;
        }

        j = k - (n - m);
        if (j < 0)
        {
            j += n;
        }

        x = stateArray[j] ^ xA;
        stateArray[k++] = x;

        if (k >= n)
        {
            k = 0;
        }

        state.stateIndex = k;

        uint y = x ^ (x >> u);
        y = y ^ ((y << s) & b);
        y = y ^ ((y << t) & c);

        const uint z = y ^ (y >> l);

        return z;
    }

}

unittest
{
    MersenneTwister mersen = MersenneTwister(12345);
    assert(mersen.randu == 3992670690);
    assert(mersen.randu == 3823185381);
    assert(mersen.randu == 1358822685);
    assert(mersen.randu == 561383553);
    assert(mersen.randu == 789925284);
    assert(mersen.randu == 170765737);
    assert(mersen.randu == 878579710);
    assert(mersen.randu == 3549516158);
    assert(mersen.randu == 2438360421);
    assert(mersen.randu == 2285257250);
    assert(mersen.randu == 2557845021);
    assert(mersen.randu == 4107320065);
    assert(mersen.randu == 4142558326);
    assert(mersen.randu == 1983958385);
    assert(mersen.randu == 2805374267);
    assert(mersen.randu == 3967425166);
    assert(mersen.randu == 3216529513);
    assert(mersen.randu == 1605979227);
    assert(mersen.randu == 2807061239);
    assert(mersen.randu == 665605494);
}

/** 
 * https://en.wikipedia.org/wiki/Xorshift
 */
struct Xorshift
{
    protected
    {
        ulong seed;
    }

    this(ulong seed)
    {
        assert(seed != 0);
        this.seed = seed;
    }

    ulong randu()
    {
        ulong x = seed;
        x ^= x << 7;
        x ^= x >> 9;
        return seed = x;
    }
}

/** 
 * https://en.wikipedia.org/wiki/Lehmer_random_number_generator
 */
struct LCG
{
    protected
    {
        uint seed;
    }

    enum
    {
        uint M = 0x7fffffff,
        uint A = 48271,
        uint Q = M / A, // 44488
        R = M % A // 3399
    }

    this(uint seed)
    {
        assert(seed != 0);
        this.seed = seed;
    }

    uint randu()
    {
        uint div = seed / Q; // max: M / Q = A = 48 271
        uint rem = seed % Q; // max: Q — 1 = 44 487
        uint s = rem * A; // max: 44,487 * 48,271 = 2,147,431,977 = 0x7fff3629
        uint t = div * R; // max: 48,271 * 3,399 = 164,073,129
        uint result = s - t;

        if (result < 0)
        {
            result += M;
        }

        return seed = result;
    }
}

uint fastBetween(Rng)(Rng rng, uint minInclusive, uint maxExclusive) {
    uint x = rng.randu;
    ulong m = x * cast(ulong)(maxExclusive - minInclusive);
    return (m >> 32) + minInclusive;
}