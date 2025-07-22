module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;
import api.subs.ele.circuit;
import api.subs.ele.components;

import api.math.graphs.graph;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;

/**
 * Authors: initkfs
 */
class Simulator : Container
{
    Circuit circuit;

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        circuit = new Circuit;
        addCreate(circuit);
        circuit.toCenter;

        auto battery = new VoltageSource(12.0, "V1 12V");
        auto resistor = new Resistor(100, "R1 100");
        auto resistor2 = new Resistor(100, "R2 100");
        auto ground = new Ground;

        auto resistor11 = new Resistor(50, "R11 50");
        auto resistor21 = new Resistor(25, "R22 25");

        circuit.addCreateItem(battery);
        circuit.addCreateItem(resistor);
        circuit.addCreateItem(resistor2);

        circuit.addCreateItem(resistor11);
        circuit.addCreateItem(resistor21);

        circuit.addCreateItem(ground);

        auto wire1 = new Wire(battery.p, resistor.p, battery, resistor);
        auto wire2 = new Wire(resistor.n, resistor2.p, resistor, resistor2);
        
        auto wire21 = new Wire(resistor.p, resistor11.p, resistor, resistor11);
        auto wire31 = new Wire(resistor11.n, resistor21.p, resistor11, resistor21);
        auto wire41 = new Wire(resistor21.n, resistor2.n, resistor21, resistor2);
        
        auto wire3 = new Wire(resistor2.n, ground.p, resistor2, ground);
        auto wire4 = new Wire(ground.p, battery.n, ground, battery);

        circuit.addCreateItem(wire1);
        circuit.addCreateItem(wire2);

        circuit.addCreateItem(wire21);
        circuit.addCreateItem(wire31);
        circuit.addCreateItem(wire41);

        circuit.addCreateItem(wire3);
        circuit.addCreateItem(wire4);

        //circuit.onPointerPress ~= (ref e) { circuit.alignComponents; };

        /*foreach (node; nodes) {
        assert(node.pins.map!(p => p.current).sum.approxEqual(0.0));
        }*/
        //assert(abs(GND.pin.currentIn - battery.currentOut) < 1e-9);


    }

}
