module deltotum.maths.statistics.statistic;

double variance(double[] values) @safe
in(values.length > 1)
{
    import std.algorithm.iteration : mean;

    if(values.length <= 1){
        return double.nan;
    }

    immutable size_t length = values.length;
    immutable double valMean = mean(values);
    double result = 0;
    foreach (i; 0 .. length)
    {
        result += (values[i] - valMean) * (values[i] - valMean);
    }
    //or /length?
    return result / (length - 1);
}

//σ = √D[X]
double stddev(double[] values) @safe
in(values.length > 1)
{
    import Math = deltotum.maths.math;

    if(values.length <= 1){
        return double.nan;
    }

    immutable double varianceVals = variance(values);
    return Math.sqrt(varianceVals);
}

//Variance
unittest
{
    import std.math.operations : isClose;

    double[] vals1 = [600, 470, 170, 430, 300];
    double varianceVals1 = variance(vals1);
    assert(isClose(varianceVals1, 27_130));
}

//Standard Deviation
unittest
{
    import std.math.operations : isClose;

    double[] vals1 = [600, 470, 170, 430, 300];
    double stddevVals = stddev(vals1);
    assert(isClose(stddevVals, 164.7118696391));
}