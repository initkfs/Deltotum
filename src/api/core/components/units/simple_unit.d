module api.core.components.units.simple_unit;

import api.core.components.units.unitable : Unitable;
import api.core.components.units.states.illegal_unit_state_exception : IllegalUnitStateException;
import api.core.components.units.states.unit_state : UnitState;

/**
 * Authors: initkfs
 */
class SimpleUnit : Unitable
{
    private
    {
        UnitState _state = UnitState.none;
    }

    this(UnitState initState = UnitState.none) pure @safe
    {
        _state = initState;
    }

    const nothrow pure @safe
    {
        UnitState state() => _state;
        bool isState(UnitState s) => _state == s;
        bool isNone() => isState(UnitState.none);
        bool isInitialized() => isState(UnitState.initialize);
        bool isCreated() => isState(UnitState.create);
        bool isRunning() => isState(UnitState.run);
        bool isPaused() => isState(UnitState.pause);
        bool isStopped() => isState(UnitState.stop);
        bool isDisposed() => isState(UnitState.dispose);
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

    void initialize(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.initialize;
        assert(unit.isInitialized, "Unit not initialized: " ~ unit.className);
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

    void create(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.create;
        assert(unit.isCreated, "Unit not created: " ~ unit.className);
    }

    void initCreate(SimpleUnit unit)
    {
        initialize(unit);
        create(unit);
    }

    void run()
    {
        if (!isCreated && !isStopped && !isPaused)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot run component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.run;
    }

    void run(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.run;
        assert(unit.isRunning, "Unit not running: " ~ unit.className);
    }

    void initCreateRun(SimpleUnit unit)
    {
        initialize(unit);
        create(unit);
        run(unit);
    }

    void pause()
    {
        if (!isRunning)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot pause component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.pause;
    }

    void pause(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.pause;
        assert(unit.isPaused, "Unit not paused: " ~ unit.className);
    }

    void stop()
    {
        if (!isRunning && !isPaused)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot stop component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.stop;
    }

    void stop(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.stop;
        assert(unit.isStopped, "Unit not stopped: " ~ unit.className);
    }

    void dispose()
    {
        //allow dispose without running
        if (!isStopped && !isInitialized && !isCreated && !isPaused)
        {
            import std.format : format;

            throw new IllegalUnitStateException(format("Cannot dispose component '%s' with state: %s",
                    className, _state));
        }

        _state = UnitState.dispose;
    }

    void dispose(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.dispose;
        assert(unit.isDisposed, "Unit not disposed: " ~ unit.className);
    }

    void stopDispose(SimpleUnit unit)
    {
        stop(unit);
        dispose(unit);
    }

    void stopDisposeSafe(SimpleUnit unit)
    {
        assert(unit);
        if (unit.isRunning)
        {
            stop(unit);
        }
        if (!unit.isDisposed)
        {
            dispose(unit);
        }
    }

    unittest
    {
        import std.exception : assertThrown;

        class ImmComponent : SimpleUnit
        {
            this(UnitState state) immutable
            {
                super(state);
            }
        }

        //Test immutable
        auto immcomp = new immutable ImmComponent(UnitState.run);
        assert(immcomp.isRunning);

        const immcomp2 = new const ImmComponent(UnitState.stop);
        assert(immcomp2.isStopped);

        class TestComponent : SimpleUnit
        {
        }

        //Test mutable
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

        component.pause;
        assert(component.isPaused);
        assertThrown(component.create);
        assertThrown(component.initialize);
        assertThrown(component.dispose);

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
