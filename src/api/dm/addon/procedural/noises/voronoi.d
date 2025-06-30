module api.dm.addon.procedural.noises.voronoi;

import api.dm.addon.procedural.noises.sample_noise : SampleNoise;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.addon.procedural.noises.permutation_table : PermutationTable;

import Math = api.dm.math;

import std.random : unpredictableSeed;

public enum VoronoiDistance
{
    EUCLIDIAN,
    MANHATTAN,
    CHEBYSHEV
}

public enum VoronoiCombination
{
    D0,
    D1_D0,
    D2_D0
}

/**
 * Authors: initkfs
 *
 * Ported from https://github.com/Scrawk/Procedural-Noise
 * Copyright (c) 2017 Justin Hawkins, under MIT license https://github.com/Scrawk/Procedural-Noise/blob/master/LICENSE
 */
public class Voronoi : SampleNoise
{
    VoronoiDistance distance = VoronoiDistance.EUCLIDIAN;
    VoronoiCombination combination = VoronoiCombination.D1_D0;

    this(uint seed)
    {
        super(seed);
    }

    override float sample1D(float x)
    {
        //The 0.75 is to make the scale simliar to the other noise algorithms
        x = (x + offsetX) * frequency * 0.75f;

        int lastRandom, numberFeaturePoints;
        float randomDiffX = 0;
        float featurePointX = 0;
        int cubeX = 0;

        float[] distanceArray = [float.infinity, float.infinity, float
            .infinity];

        //1. Determine which cube the evaluation point is in
        int evalCubeX = cast(int) Math.floor(x);

        for (int i = -1; i < 2; ++i)
        {
            cubeX = evalCubeX + i;

            //2. Generate a reproducible random number generator for the cube
            lastRandom = perm[cubeX];

            //3. Determine how many feature points are in the cube
            numberFeaturePoints = probLookup(lastRandom * perm.inverse);

            //4. Randomly place the feature points in the cube
            for (int l = 0; l < numberFeaturePoints; ++l)
            {
                lastRandom = perm[lastRandom];
                randomDiffX = lastRandom * perm.inverse;

                lastRandom = perm[lastRandom];

                featurePointX = randomDiffX + cubeX;

                //5. Find the feature point closest to the evaluation point. 
                //This is done by inserting the distances to the feature points into a sorted list
                distanceArray = insert(distanceArray, distance1(x, featurePointX));
            }

            //6. Check the neighboring cubes to ensure their are no closer evaluation points.
            // This is done by repeating steps 1 through 5 above for each neighboring cube
        }

        return combine(distanceArray) * amplitude;
    }

    override float sample2D(float x, float y)
    {
        //The 0.75 is to make the scale simliar to the other noise algorithms
        x = (x + offsetX) * frequency * 0.75f;
        y = (y + offsetY) * frequency * 0.75f;

        int lastRandom, numberFeaturePoints;
        float randomDiffX = 0, randomDiffY = 0;
        float featurePointX = 0, featurePointY = 0;
        int cubeX, cubeY;

        float[] distanceArray = [float.infinity, float.infinity, float
            .infinity];

        //1. Determine which cube the evaluation point is in
        int evalCubeX = cast(int) Math.floor(x);
        int evalCubeY = cast(int) Math.floor(y);

        for (int i = -1; i < 2; ++i)
        {
            for (int j = -1; j < 2; ++j)
            {
                cubeX = evalCubeX + i;
                cubeY = evalCubeY + j;

                //2. Generate a reproducible random number generator for the cube
                lastRandom = perm[cubeX, cubeY];

                //3. Determine how many feature points are in the cube
                numberFeaturePoints = probLookup(lastRandom * perm.inverse);

                //4. Randomly place the feature points in the cube
                for (int l = 0; l < numberFeaturePoints; ++l)
                {
                    lastRandom = perm[lastRandom];
                    randomDiffX = lastRandom * perm.inverse;

                    lastRandom = perm[lastRandom];
                    randomDiffY = lastRandom * perm.inverse;

                    featurePointX = randomDiffX + cubeX;
                    featurePointY = randomDiffY + cubeY;

                    //5. Find the feature point closest to the evaluation point. 
                    //This is done by inserting the distances to the feature points into a sorted list
                    distanceArray = insert(distanceArray, distance2(x, y, featurePointX, featurePointY));
                }

                //6. Check the neighboring cubes to ensure their are no closer evaluation points.
                // This is done by repeating steps 1 through 5 above for each neighboring cube
            }
        }

        return combine(distanceArray) * amplitude;
    }

    override float sample3D(float x, float y, float z)
    {
        //The 0.75 is to make the scale simliar to the other noise algorithms
        x = (x + offsetX) * frequency * 0.75f;
        y = (y + offsetY) * frequency * 0.75f;
        z = (z + offsetZ) * frequency * 0.75f;

        int lastRandom, numberFeaturePoints;
        float randomDiffX = 0, randomDiffY = 0, randomDiffZ = 0;
        float featurePointX = 0, featurePointY = 0, featurePointZ = 0;
        int cubeX, cubeY, cubeZ;

        float[] distanceArray = [float.infinity, float.infinity, float
            .infinity];

        //1. Determine which cube the evaluation point is in
        int evalCubeX = cast(int) Math.floor(x);
        int evalCubeY = cast(int) Math.floor(y);
        int evalCubeZ = cast(int) Math.floor(z);

        for (int i = -1; i < 2; ++i)
        {
            for (int j = -1; j < 2; ++j)
            {
                for (int k = -1; k < 2; ++k)
                {
                    cubeX = evalCubeX + i;
                    cubeY = evalCubeY + j;
                    cubeZ = evalCubeZ + k;

                    //2. Generate a reproducible random number generator for the cube
                    lastRandom = perm[cubeX, cubeY, cubeZ];

                    //3. Determine how many feature points are in the cube
                    numberFeaturePoints = probLookup(lastRandom * perm.inverse);

                    //4. Randomly place the feature points in the cube
                    for (int l = 0; l < numberFeaturePoints; ++l)
                    {
                        lastRandom = perm[lastRandom];
                        randomDiffX = lastRandom * perm.inverse;

                        lastRandom = perm[lastRandom];
                        randomDiffY = lastRandom * perm.inverse;

                        lastRandom = perm[lastRandom];
                        randomDiffZ = lastRandom * perm.inverse;

                        featurePointX = randomDiffX + cubeX;
                        featurePointY = randomDiffY + cubeY;
                        featurePointZ = randomDiffZ + cubeZ;

                        //5. Find the feature point closest to the evaluation point. 
                        //This is done by inserting the distances to the feature points into a sorted list
                        distanceArray = insert(distanceArray, distance3(x, y, z, featurePointX, featurePointY, featurePointZ));
                    }

                    //6. Check the neighboring cubes to ensure their are no closer evaluation points.
                    // This is done by repeating steps 1 through 5 above for each neighboring cube
                }
            }
        }

        return combine(distanceArray) * amplitude;
    }

    private float distance1(float p1x, float p2x)
    {
        final switch (distance)
        {
            case VoronoiDistance.EUCLIDIAN:
                return (p1x - p2x) * (p1x - p2x);

            case VoronoiDistance.MANHATTAN:
                return Math.abs(p1x - p2x);

            case VoronoiDistance.CHEBYSHEV:
                return Math.abs(p1x - p2x);
        }

        return 0;
    }

    private float distance2(float p1x, float p1y, float p2x, float p2y)
    {
        final switch (distance)
        {
            case VoronoiDistance.EUCLIDIAN:
                return (p1x - p2x) * (p1x - p2x) + (p1y - p2y) * (p1y - p2y);

            case VoronoiDistance.MANHATTAN:
                return Math.abs(p1x - p2x) + Math.abs(p1y - p2y);

            case VoronoiDistance.CHEBYSHEV:
                return Math.max(Math.abs(p1x - p2x), Math.abs(p1y - p2y));
        }

        return 0;
    }

    private float distance3(float p1x, float p1y, float p1z, float p2x, float p2y, float p2z)
    {
        final switch (distance)
        {
            case VoronoiDistance.EUCLIDIAN:
                return (p1x - p2x) * (p1x - p2x) + (p1y - p2y) * (p1y - p2y) + (
                    p1z - p2z) * (p1z - p2z);

            case VoronoiDistance.MANHATTAN:
                return Math.abs(p1x - p2x) + Math.abs(p1y - p2y) + Math.abs(p1z - p2z);

            case VoronoiDistance.CHEBYSHEV:
                return Math.max(Math.max(Math.abs(p1x - p2x), Math.abs(p1y - p2y)), Math.abs(
                        p1z - p2z));
        }

        return 0;
    }

    private float combine(float[] arr)
    {
        final switch (combination)
        {
            case VoronoiCombination.D0:
                return arr[0];

            case VoronoiCombination.D1_D0:
                return arr[1] - arr[0];

            case VoronoiCombination.D2_D0:
                return arr[2] - arr[0];
        }

        return 0;
    }

    /// <summary>
    /// Given a uniformly distributed random number this function returns the number of feature points in a given cube.
    /// </summary>
    /// <param name="value">a uniformly distributed random number</param>
    /// <returns>The number of feature points in a cube.</returns>
    int probLookup(float value)
    {
        //Poisson Distribution
        if (value < 0.0915781944272058)
            return 1;
        if (value < 0.238103305510735)
            return 2;
        if (value < 0.433470120288774)
            return 3;
        if (value < 0.628836935299644)
            return 4;
        if (value < 0.785130387122075)
            return 5;
        if (value < 0.889326021747972)
            return 6;
        if (value < 0.948866384324819)
            return 7;
        if (value < 0.978636565613243)
            return 8;

        return 9;
    }

    /// <summary>
    /// Inserts value into array using insertion sort. If the value is greater than the largest value in the array
    /// it will not be added to the array.
    /// </summary>
    /// <param name="arr">The array to insert the value into.</param>
    /// <param name="value">The value to insert into the array.</param>
    float[] insert(float[] arr, float value)
    {
        float temp = 0;
        for (int i = 3 - 1; i >= 0; i--)
        {
            if (value > arr[i])
                break;
            temp = arr[i];
            arr[i] = value;
            if (i + 1 < 3)
                arr[i + 1] = temp;
        }

        return arr;
    }

}
