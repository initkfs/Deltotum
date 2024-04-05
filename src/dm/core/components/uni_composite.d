module dm.core.components.uni_composite;

import dm.core.components.uni_component : UniComponent;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
class UniComposite(C : UniComponent) : C
{
    private
    {
        C[] _units;
    }

    void buildChild(C component)
    {
        buildFromParent(component, this);
        addUnit(component);
    }

    void buildChild(C[] components)
    {
        foreach (component; components)
        {
            buildChild(component);
        }
    }

    void buildInitChild(C component)
    {
        buildInit(component);
        addUnit(component);
    }

    void buildInitRunChild(C component)
    {
        buildInitChild(component);
        run(component);
    }

    bool addUnit(C unit)
    {
        import std.exception : enforce;

        enforce(unit, "Unit must not be null");

        if (hasUnit(unit))
        {
            return false;
        }
        _units ~= unit;
        return true;
    }

    bool hasUnit(C unit) const
    {
        import std.exception : enforce;

        enforce(unit, "Unit must not be null");

        import std.algorithm.searching : canFind;

        return _units.canFind(unit);
    }

    bool removeUnit(C unit)
    {
        import std.exception : enforce;

        enforce(unit, "Unit must not be null");

        import std.algorithm.mutation : remove;
        import std.algorithm.searching : countUntil;

        immutable removePos = _units.countUntil(unit);
        if (removePos == -1)
        {
            return false;
        }
        _units = _units.remove(removePos);
        return true;
    }

    inout(C[]) units() inout nothrow pure @safe
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

    auto composite = new UniComposite!UniComponent;
    auto component1 = new UniComponent;
    auto component3 = new UniComponent;

    assertThrown(composite.addUnit(null));

    assert(composite.addUnit(component1));
    assert(!composite.addUnit(component1));
    assert(composite.hasUnit(component1));
    assert(composite.units.length == 1);

    auto component2 = new UniComponent;
    assert(composite.addUnit(component2));
    assert(composite.hasUnit(component2));
    assert(composite.units.length == 2);

    assert(!composite.hasUnit(component3));
    assert(!composite.removeUnit(component3));

    assertThrown(composite.removeUnit(null));
    assert(composite.removeUnit(component1));
    assert(!composite.hasUnit(component1));
    assert(!composite.removeUnit(component1));
    assert(composite.units.length == 1);

    assert(composite.removeUnit(component2));
    assert(!composite.hasUnit(component2));
    assert(!composite.removeUnit(component2));
    assert(composite.units.length == 0);
}
