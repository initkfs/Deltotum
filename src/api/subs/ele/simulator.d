module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;
import api.subs.ele.circuit;
import api.subs.ele.components;

import api.dm.gui.controls.switches.buttons.button : Button;

import api.math.graphs.graph;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;

import api.dm.lib.libxml.native;

/**
 * Authors: initkfs
 */
class Simulator : Container
{
    Circuit circuit;

    Button loadButton;
    Button saveButton;

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.hbox : HBox;

        auto panel = new HBox;

        loadButton = new Button("Load");
        saveButton = new Button("Save");

        circuit = new Circuit;
        addCreate(circuit);
        circuit.toCenter;

        addCreate(panel);
        panel.addCreate([loadButton, saveButton]);

        auto battery = new VoltageSource(12.0, "V1");
        auto resistor = new Resistor(100, "R1");
        auto resistor2 = new Resistor(100, "R2");

        auto resistor11 = new Resistor(50, "R11");
        auto resistor21 = new Resistor(25, "R22");

        circuit.addCreateItem(battery);
        circuit.addCreateItem(resistor);
        circuit.addCreateItem(resistor2);

        circuit.addCreateItem(resistor11);
        circuit.addCreateItem(resistor21);

        auto wire1 = new WirePP(battery, resistor);
        auto wire2 = new WireNP(resistor, resistor2);

        auto wire21 = new WirePP(resistor, resistor11);
        auto wire31 = new WireNP(resistor11, resistor21);
        auto wire41 = new WireNN(resistor21, resistor2);

        auto wire3 = new WireNN(resistor2, battery);

        circuit.addCreateItem(wire1);
        circuit.addCreateItem(wire2);

        circuit.addCreateItem(wire21);
        circuit.addCreateItem(wire31);
        circuit.addCreateItem(wire41);

        circuit.addCreateItem(wire3);

        //circuit.onPointerPress ~= (ref e) { circuit.alignComponents; };

        /*foreach (node; nodes) {
        assert(node.pins.map!(p => p.current).sum.approxEqual(0.0));
        }*/
        //assert(abs(GND.pin.currentIn - battery.currentOut) < 1e-9);

        saveButton.onAction ~= (ref e) {
            auto userDir = context.app.userDir;
            auto file = userDir ~ "/test2.svg";
            save(file);
        };

        loadButton.onAction ~= (ref e) {
            auto userDir = context.app.userDir;
            auto file = userDir ~ "/test2.svg";
            load(file);
        };
    }

    void load(string path)
    {
        import std.string : toStringz;
        import std.conv : to;
        import std.format : format;

        import Math = api.math;

        import std : readText;

        auto text = readText(path);

        circuit.removeAll;

        xmlDoc* docPtr = xmlReadMemory(text.toStringz, cast(int) text.length, null, null, xmlParserOption
                .XML_PARSE_NOERROR | xmlParserOption
                .XML_PARSE_NOWARNING);

        assert(docPtr);

        xmlNode* root = xmlDocGetRootElement(docPtr);
        assert(root);

        xmlNode* node = root;
        while (node)
        {
            xmlNode* child = xmlFirstElementChild(node);
            while (child)
            {
                auto typeAttr = xmlGetProp(child, "data-type".toXmlStr);

                if (typeAttr)
                {
                    auto type = typeAttr.fromXmlStr;
                    switch (type)
                    {
                        case "resistor":
                            auto resValueAttr = xmlGetProp(child, "data-resistance".toXmlStr);
                            assert(resValueAttr);
                            double resistance = resValueAttr.fromXmlStr.to!double;
                            //xmlFree(resValueAttr);
                            //" data-x="591.908" data-y="223.919" data-width="50" data-height="80"

                            auto res = new Resistor(resistance);

                            auto wValueAttr = xmlGetProp(child, "data-width".toXmlStr);
                            assert(wValueAttr);
                            res.width = wValueAttr.fromXmlStr.to!double;

                            auto hValueAttr = xmlGetProp(child, "data-height".toXmlStr);
                            assert(hValueAttr);
                            res.height = hValueAttr.fromXmlStr.to!double;

                            circuit.addCreateItem(res);

                            auto xValueAttr = xmlGetProp(child, "data-x".toXmlStr);
                            assert(xValueAttr);
                            res.x = xValueAttr.fromXmlStr.to!double;

                            auto yValueAttr = xmlGetProp(child, "data-y".toXmlStr);
                            assert(yValueAttr);
                            res.y = yValueAttr.fromXmlStr.to!double;

                            break;
                        default:
                            break;
                    }
                }

                child = xmlNextElementSibling(child);
            }

            node = xmlNextElementSibling(node);
        }

        xmlFreeDoc(docPtr);
    }

    void save(string path)
    {
        import std.string : toStringz;
        import std.conv : to;
        import std.format : format;

        import Math = api.math;

        xmlDoc* doc = xmlNewDoc("1.0".toXmlStr);

        xmlNode* root = xmlNewNode(null, "svg".toXmlStr);

        xmlDocSetRootElement(doc, root);

        const windowWidth = window.width;
        const windowHeight = window.height;

        xmlNewProp(root, "width".toXmlStr, windowWidth.to!string.toXmlStr);
        xmlNewProp(root, "height".toXmlStr, windowHeight.to!string.toXmlStr);
        xmlNewProp(root, "xmlns".toXmlStr, "http://www.w3.org/2000/svg".toXmlStr);

        foreach (item; circuit.children)
        {
            xmlNode* elemNode;

            if (auto element = cast(Element) item)
            {
                if (auto resistor = cast(Resistor) element)
                {
                    auto svgText = resistor.createSVG;
                    if (svgText.length == 0)
                    {
                        elemNode = xmlNewChild(root, null, "rect".toXmlStr, null);
                    }
                    else
                    {
                        import std.string : toStringz;

                        xmlDoc* drawSvgPtr = xmlReadMemory(
                            svgText.toStringz,
                            cast(int) svgText.length,
                            null,
                            null,
                            xmlParserOption.XML_PARSE_NOERROR | xmlParserOption.XML_PARSE_NOWARNING
                        );

                        scope (exit)
                        {
                            if (drawSvgPtr)
                            {
                                xmlFreeDoc(drawSvgPtr);
                            }
                        }

                        if (drawSvgPtr)
                        {
                            auto rootNode = xmlDocGetRootElement(drawSvgPtr);
                            if (rootNode)
                            {
                                auto firstChild = xmlFirstElementChild(rootNode);
                                //xmlNode* copy = xmlCopyNode(svgRoot, 1); // 1 = deep copy
                                //xmlAddChild(elemNode, copy);
                                if (firstChild)
                                {
                                    elemNode = xmlCopyNode(firstChild, 1);
                                    xmlAddChild(root, elemNode);

                                    const offset = resistor.content.pos;

                                    //TODO with xmlAttr structure
                                    xmlSetProp(elemNode, "transform".toXmlStr, format("translate(%d, %d)", cast(
                                            int) (offset.x), cast(int) (offset.y)).toXmlStr);

                                    import api.dm.kit.sprites2d.sprite2d : Sprite2d;

                                    if (auto sprite = cast(Sprite2d) item)
                                    {
                                        const x = sprite.x;
                                        const y = sprite.y;

                                        xmlNewProp(elemNode, "data-x".toXmlStr, x
                                                .to!string.toXmlStr);
                                        xmlNewProp(elemNode, "data-y".toXmlStr, y
                                                .to!string.toXmlStr);
                                    }

                                    if (elemNode)
                                    {
                                        const bounds = element.boundsRect;
                                        xmlNewProp(elemNode, "data-width".toXmlStr, bounds
                                                .width.to!string.toXmlStr);
                                        xmlNewProp(elemNode, "data-height".toXmlStr, bounds
                                                .height.to!string.toXmlStr);
                                    }
                                }
                            }
                        }
                    }

                    xmlNewProp(elemNode, "data-type".toXmlStr, "resistor".toXmlStr);
                    xmlNewProp(elemNode, "data-resistance".toXmlStr, resistor
                            .resistance.to!string.toXmlStr);
                }
            }
            else if (auto wire = cast(Wire) item)
            {
                elemNode = xmlNewChild(root, null, "line".toXmlStr, null);
                auto src = wire.src;
                auto dst = wire.dst;

                auto x1 = wire.startLine.x;
                auto y1 = wire.startLine.y;

                auto x2 = wire.endLine.x;
                auto y2 = wire.endLine.y;

                xmlNewProp(elemNode, "data-src".toXmlStr, src.elementId.toXmlStr);
                xmlNewProp(elemNode, "data-dst".toXmlStr, dst.elementId.toXmlStr);

                xmlNewProp(elemNode, "x1".toXmlStr, x1.to!string.toXmlStr);
                xmlNewProp(elemNode, "y1".toXmlStr, y1.to!string.toXmlStr);
                xmlNewProp(elemNode, "x2".toXmlStr, x2.to!string.toXmlStr);
                xmlNewProp(elemNode, "y2".toXmlStr, y2.to!string.toXmlStr);

                xmlNewProp(elemNode, "stroke".toXmlStr, "red".toXmlStr);
                xmlNewProp(elemNode, "stroke-width".toXmlStr, "2".toXmlStr);

                string fromPin, toPin;
                if (cast(WirePP) wire)
                {
                    fromPin = "p";
                    toPin = "p";
                }
                else if (cast(WireNN) wire)
                {
                    fromPin = "n";
                    toPin = "n";
                }
                else if (cast(WirePN) wire)
                {
                    fromPin = "p";
                    toPin = "n";
                }
                else if (cast(WireNP) wire)
                {
                    fromPin = "n";
                    toPin = "p";
                }

                xmlNewProp(elemNode, "data-from".toXmlStr, fromPin.toXmlStr);
                xmlNewProp(elemNode, "data-to".toXmlStr, toPin.toXmlStr);
            }

            if (!elemNode)
            {
                continue;
            }

        }

        xmlSaveCtxt* saveCtx = xmlSaveToFilename(
            (path).toStringz,
            "UTF-8",
            xmlSaveOption.XML_SAVE_FORMAT | xmlSaveOption.XML_SAVE_NO_DECL
        );

        assert(saveCtx);
        scope (exit)
        {
            xmlSaveClose(saveCtx);
        }

        if (xmlSaveDoc(saveCtx, doc) != 0)
        {
            throw new Exception("Error to saving");
        }

        xmlFreeDoc(doc);
    }

    string getLastError()
    {
        xmlError* errorPtr = xmlGetLastError();
        if (!errorPtr)
        {
            return "Error is empty";
        }

        import std.format : format;
        import std.string : fromStringz;

        return format("File: %s, line: %s. Message: %s", errorPtr.file.fromStringz, errorPtr.line, errorPtr
                .message.fromStringz);
    }

}
