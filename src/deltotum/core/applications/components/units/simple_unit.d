module deltotum.core.applications.components.units.simple_unit;

import deltotum.core.applications.components.units.unitable : Unitable;
import deltotum.core.applications.components.units.states.illegal_unit_state_exception : IllegalUnitStateException;
import deltotum.core.applications.components.units.states.unit_state : UnitState;

/**
 * Authors: initkfs
 */
class SimpleUnit : Unitable
{
    private
    {
        UnitState _state = UnitState.none;
    }

    UnitState state() @safe pure nothrow const
    {
        return _state;
    }

    bool isState(UnitState s) @safe pure nothrow const
    {
        return _state == s;
    }

    bool isNone() @safe pure nothrow const
    {
        return isState(UnitState.none);
    }

    bool isInitialized() @safe pure nothrow const
    {
        return isState(UnitState.initialize);
    }

    bool isRunning() @safe pure nothrow const
    {
        return isState(UnitState.run);
    }

    bool isStopped() @safe pure nothrow const
    {
        return isState(UnitState.stop);
    }

    bool isDisposed() @safe pure nothrow const
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

    void run()
    {
        if (!isInitialized && !isStopped)
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
        if (!isStopped && !isInitialized)
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
