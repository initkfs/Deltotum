module deltotum.core.apps.units.simple_unit;

import deltotum.core.apps.units.unitable : Unitable;
import deltotum.core.apps.units.states.illegal_unit_state_exception : IllegalUnitStateException;
import deltotum.core.apps.units.states.unit_state : UnitState;

/**
 * Authors: initkfs
 */
class SimpleUnit : Unitable
{
    private
    {
        UnitState _state = UnitState.none;
    }

    UnitState state() const nothrow pure @safe
    {
        return _state;
    }

    pragma(inline, true);
    bool isState(UnitState s) const nothrow pure @safe
    {
        return _state == s;
    }

    bool isNone() const nothrow pure @safe
    {
        return isState(UnitState.none);
    }

    bool isInitialized() const nothrow pure @safe
    {
        return isState(UnitState.initialize);
    }

    bool isCreated() const nothrow pure @safe
    {
        return isState(UnitState.create);
    }

    bool isRunning() const nothrow pure @safe
    {
        return isState(UnitState.run);
    }

    bool isStopped() const nothrow pure @safe
    {
        return isState(UnitState.stop);
    }

    bool isDisposed() const nothrow pure @safe
    {
        return isState(UnitState.dispose);
    }

    void initialize()
    {

        if (!isNone && !isDisposed)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot initialize component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.initialize;
    }

    void create()
    {
        if (!isNone && !isInitialized)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot create component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.create;
    }

    void run()
    {
        if (!isCreated && !isStopped)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot run component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.run;
    }

    void stop()
    {
        if (!isRunning)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot stop component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.stop;
    }

    void dispose()
    {
        //allow dispose without running
        if (!isStopped && !isInitialized && !isCreated)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot dispose component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.dispose;
    }

    unittest
    {
        import std.exception : assertThrown;

        class TestComponent : SimpleUnit
        {
        }

        auto component = new TestComponent();

        assertThrown(component.run);
        assertThrown(component.stop);
        assertThrown(component.dispose);

        component.initialize;
        assert(component.isInitialized);
        assertThrown(component.initialize);
        assertThrown(component.stop);

        component.dispose;
        assert(component.isDisposed);
        assertThrown(component.dispose);
        assertThrown(component.run);
        assertThrown(component.stop);

        component.initialize;
        assert(component.isInitialized);

        component.create;
        assert(component.isCreated);
        assertThrown(component.initialize);

        component.run;
        assert(component.isRunning);
        assertThrown(component.run);
        assertThrown(component.initialize);
        assertThrown(component.dispose);

        component.stop;
        assert(component.isStopped);
        assertThrown(component.stop);
        assertThrown(component.initialize);

        component.run;
        assert(component.isRunning);

        component.stop;
        assert(component.isStopped);

        component.dispose;
        assert(component.isDisposed);
    }
}
