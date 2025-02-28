module api.core.components.units.simple_unit;

import api.core.components.units.unitable : Unitable;
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

    bool isThrowInvalidState = true;
    bool isThrowInvalidChangeState = true;

    void delegate(SimpleUnit, UnitState) onInvalidNewState;
    void delegate(SimpleUnit, UnitState) onInvalidChangeNewState;

    this(UnitState initState = UnitState.none) pure @safe
    {
        _state = initState;
    }

    bool isTriggerListeners = true;

    void delegate()[] onInitialize;
    void delegate()[] onCreate;
    void delegate()[] onRun;
    void delegate()[] onPause;
    void delegate()[] onStop;
    void delegate()[] onDispose;

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
            if (onInvalidNewState)
            {
                onInvalidNewState(this, UnitState.initialize);
            }

            if (isThrowInvalidState)
            {
                import std.format : format;

                throw new Exception(format("Cannot initialize component '%s' with state: %s",
                        className, _state));
            }
        }

        _state = UnitState.initialize;

        triggerListeners(onInitialize);
    }

    protected void triggerListeners(ref void delegate()[] listeners)
    {
        if (listeners.length > 0 && isTriggerListeners)
        {
            foreach (dg; listeners)
            {
                assert(dg);
                dg();
            }
        }
    }

    void initialize(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.initialize;
        if (!unit.isInitialized)
        {
            if (onInvalidChangeNewState)
            {
                onInvalidChangeNewState(unit, UnitState.initialize);
            }

            if (isThrowInvalidChangeState)
            {
                throw new Exception("Unit not initialized: " ~ unit.className);
            }
        }
    }

    void create()
    {
        if (!isNone && !isInitialized)
        {
            if (onInvalidNewState)
            {
                onInvalidNewState(this, UnitState.create);
            }

            if (isThrowInvalidState)
            {
                import std.format : format;

                throw new Exception(format("Cannot create component '%s' with state: %s",
                        className, _state));
            }
        }

        _state = UnitState.create;

        triggerListeners(onCreate);
    }

    void create(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.create;
        if (!unit.isCreated)
        {
            if (onInvalidChangeNewState)
            {
                onInvalidChangeNewState(unit, UnitState.create);
            }

            if (isThrowInvalidChangeState)
            {
                throw new Exception("Unit not created: " ~ unit.className);
            }
        }
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
            if (onInvalidNewState)
            {
                onInvalidNewState(this, UnitState.run);
            }

            if (isThrowInvalidState)
            {
                import std.format : format;

                throw new Exception(format("Cannot run component '%s' with state: %s",
                        className, _state));
            }
        }

        _state = UnitState.run;

        triggerListeners(onRun);
    }

    void run(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.run;
        if (!unit.isRunning)
        {
            if (onInvalidChangeNewState)
            {
                onInvalidChangeNewState(unit, UnitState.run);
            }

            if (isThrowInvalidChangeState)
            {
                throw new Exception("Unit not running: " ~ unit.className);
            }
        }
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
            if (onInvalidNewState)
            {
                onInvalidNewState(this, UnitState.pause);
            }

            if (isThrowInvalidState)
            {
                import std.format : format;

                throw new Exception(format("Cannot pause component '%s' with state: %s",
                        className, _state));
            }
        }

        _state = UnitState.pause;

        triggerListeners(onPause);
    }

    void pause(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.pause;
        if (!unit.isPaused)
        {
            if (onInvalidChangeNewState)
            {
                onInvalidChangeNewState(unit, UnitState.pause);
            }

            if (isThrowInvalidChangeState)
            {
                throw new Exception("Unit not paused: " ~ unit.className);
            }

        }
    }

    void stop()
    {
        if (!isRunning && !isPaused)
        {
            if (onInvalidNewState)
            {
                onInvalidNewState(this, UnitState.stop);
            }

            if (isThrowInvalidState)
            {
                import std.format : format;

                throw new Exception(format("Cannot stop component '%s' with state: %s",
                        className, _state));
            }
        }

        _state = UnitState.stop;

        triggerListeners(onStop);
    }

    void stop(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.stop;
        if (!unit.isStopped)
        {
            if (onInvalidChangeNewState)
            {
                onInvalidChangeNewState(unit, UnitState.stop);
            }

            if (isThrowInvalidChangeState)
            {
                throw new Exception("Unit not stopped: " ~ unit.className);
            }
        }
    }

    void dispose()
    {
        //allow dispose without running
        if (!isStopped && !isInitialized && !isCreated && !isPaused)
        {
            if (onInvalidNewState)
            {
                onInvalidNewState(this, UnitState.dispose);
            }

            if (isThrowInvalidState)
            {
                import std.format : format;

                throw new Exception(format("Cannot dispose component '%s' with state: %s",
                        className, _state));
            }
        }

        _state = UnitState.dispose;

        triggerListeners(onDispose);

        onInitialize = null;
        onCreate = null;
        onRun = null;
        onStop = null;
        onPause = null;
        onDispose = null;
    }

    void dispose(SimpleUnit unit)
    {
        assert(unit, "Unit must not be null");
        assert(unit !is this, "Unit must not be this");

        unit.dispose;
        if (!unit.isDisposed)
        {
            if (onInvalidChangeNewState)
            {
                onInvalidChangeNewState(unit, UnitState.dispose);
            }

            if (isThrowInvalidChangeState)
            {
                throw new Exception("Unit not disposed: " ~ unit.className);
            }
        }
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

    import api.core.utils.arrays : drop;

    bool removeOnInitialize(void delegate() dg) => drop(onInitialize, dg);
    bool removeOnCreate(void delegate() dg) => drop(onCreate, dg);
    bool removeOnRun(void delegate() dg) => drop(onRun, dg);
    bool removeOnPause(void delegate() dg) => drop(onPause, dg);
    bool removeOnStop(void delegate() dg) => drop(onStop, dg);
    bool removeOnDispose(void delegate() dg) => drop(onDispose, dg);

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
        //assertThrown(component.dispose);

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
