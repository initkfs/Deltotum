module api.subs.ele.components.pin;

struct Pin
{
    double voltage = 0;
    double currentIn = 0;
    double currentOut = 0;

    double eqvCurrentIn = 0;
    double eqvCurrentOut = 0;

    double currentInMa() => currentMa(currentIn);
    double currentOutMa() => currentMa(currentOut);
    double eqvCurrentInMa() => currentMa(eqvCurrentIn);

    void current(double inValue, double outValue)
    {
        currentIn = inValue;
        currentOut = outValue;
    }

    double currentMa(double currentA) => currentA * 1000;
}