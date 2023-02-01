module deltotum.core.applications.components.components.uni.uni_composite;

import deltotum.core.applications.components.uni.uni_component : UniComponent;

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

    protected bool addUnit(UniComponent unit)
    {
        if (unit is null || hasUnit(unit))
        {
            return false;
        }
        _units ~= unit;
        return true;
    }

    bool hasUnit(UniComponent unit)
    {
        if (unit is null)
        {
            return false;
        }

        import std.algorithm.searching : canFind;

        return _units.canFind(unit);
    }

    public bool removeUnit(UniComponent unit)
    {
        if (unit is null || !hasUnit(unit))
        {
            return false;
        }
        import std.algorithm.mutation : remove;
        import std.algorithm.searching : countUntil;

        immutable ptrdiff_t removePos = _units.countUntil(unit);
        if (removePos == -1)
        {
            return false;
        }
        _units = _units.remove(removePos);
        return true;
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
    auto component3 = new UniComponent;

    assert(!composite.addUnit(null));

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

    assert(!composite.removeUnit(null));
    assert(composite.removeUnit(component1));
    assert(!composite.hasUnit(component1));
    assert(!composite.removeUnit(component1));
    assert(composite.units.length == 1);

    assert(composite.removeUnit(component2));
    assert(!composite.hasUnit(component2));
    assert(!composite.removeUnit(component2));
    assert(composite.units.length == 0);
}
