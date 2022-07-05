module deltotum.application.components.components.uni.uni_composite;

import deltotum.application.components.uni.uni_component : UniComponent;

import std.exception : enforce;

/**
 * Authors: initkfs
 */
class UniComposite : UniComponent
{
    private UniComponent[] _units = [];

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

        //TODO short api
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

    //TODO copy
    @property UniComponent[] units()
    {
        return _units;
    }

    void clear()
    {
        _units = [];
    }
}
