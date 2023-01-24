module deltotum.application.components.components.uni.uni_composite;

import deltotum.application.components.uni.uni_component : UniComponent;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
class UniComposite : UniComponent
{
    private UniComponent[] _units;

    void buildChildComponent(UniComponent component)
    {
        buildFromParent(component, this);
        addUnit(component);
    }

    void buildChildComponents(UniComponent[] components)
    {
        foreach (UniComponent component; components)
        {
            buildChildComponent(component);
        }
    }

    protected void addUnit(UniComponent unit)
    {
        if (hasUnit(unit))
        {
            throw new Exception("Unit already exists: " ~ unit.toString);
        }
        _units ~= unit;
    }

    bool hasUnit(UniComponent unit)
    {
        enforce(unit !is null, "Unit must not be null");
        import std.algorithm.searching : canFind;

        return _units.canFind(unit);
    }

    public void removeUnit(UniComponent unit)
    {
        if (!hasUnit(unit))
        {
            throw new Exception("Unable to remove unit, unit not found: " ~ unit.toString);
        }
        import std.algorithm.mutation : remove;
        import std.algorithm.searching : countUntil;

        _units = _units.remove(_units.countUntil(unit));
    }

    bool removeUnitIfPresent(UniComponent unit)
    {
        if (unit !is null && hasUnit(unit))
        {
            removeUnit(unit);
            return true;
        }

        return false;
    }

    const(UniComponent[]) units() const @nogc nothrow pure @safe
    {
        return _units;
    }

    void clear()
    {
        _units = [];
    }
}

unittest
{
    import std.exception : assertThrown;

    auto composite = new UniComposite;
    auto component1 = new UniComponent;

    composite.addUnit(component1);
    assert(composite.hasUnit(component1));
    assert(composite.units.length == 1);

    assertThrown(composite.addUnit(component1));

    auto component2 = new UniComponent;
    composite.addUnit(component2);
    assert(composite.hasUnit(component2));
    assert(composite.units.length == 2);

    assert(composite.removeUnitIfPresent(component1));
    assert(!composite.hasUnit(component1));
    assert(!composite.removeUnitIfPresent(component1));
    assert(composite.units.length == 1);

    assert(composite.removeUnitIfPresent(component2));
    assert(!composite.hasUnit(component2));
    assert(!composite.removeUnitIfPresent(component2));
    assert(composite.units.length == 0);
}
