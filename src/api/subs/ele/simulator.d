module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;
import api.subs.ele.circuit;
import api.subs.ele.components;

import api.dm.gui.controls.switches.buttons.button : Button;

import api.math.graphs.graph;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.geom2.vec2 : Vec2d;

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

        // auto battery = new VoltageSource(12.0, "V1");
        // auto resistor = new Resistor(100, "R1");
        // auto resistor2 = new Resistor(100, "R2");

        // auto resistor11 = new Resistor(50, "R11");
        // auto resistor21 = new Resistor(25, "R22");

        // circuit.addCreateItem(battery);
        // circuit.addCreateItem(resistor);
        // circuit.addCreateItem(resistor2);

        // circuit.addCreateItem(resistor11);
        // circuit.addCreateItem(resistor21);

        // auto wire1 = new WirePP(battery, resistor);
        // auto wire2 = new WireNP(resistor, resistor2);

        // auto wire21 = new WirePP(resistor, resistor11);
        // auto wire31 = new WireNP(resistor11, resistor21);
        // auto wire41 = new WireNN(resistor21, resistor2);

        // auto wire3 = new WireNN(resistor2, battery);

        // circuit.addCreateItem(wire1);
        // circuit.addCreateItem(wire2);

        // circuit.addCreateItem(wire21);
        // circuit.addCreateItem(wire31);
        // circuit.addCreateItem(wire41);

        // circuit.addCreateItem(wire3);

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
            load(file, circuit);
        };

        auto userDir = context.app.userDir;
        auto file = userDir ~ "/test2.svg";
        load(file, circuit);
    }

    void load(string path, Circuit circuit)
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
        scope (exit)
        {
            xmlFreeDoc(docPtr);
        }

        xmlNode* root = xmlDocGetRootElement(docPtr);
        assert(root);

        xmlNode* node = root;
        while (node)
        {
            xmlNode* child = xmlFirstElementChild(node);
            while (child)
            {
                string id;

                auto idAttr = xmlGetProp(child, "data-id".toXmlStr);
                if (idAttr)
                {
                    id = idAttr.fromXmlStr.idup;
                    xmlFreeF(idAttr);
                }

                auto typeAttr = xmlGetProp(child, "data-type".toXmlStr);
                if (!typeAttr)
                {
                    throw new Exception("Not found type: " ~ dump(docPtr, child));
                }

                scope (exit)
                {
                    xmlFreeF(typeAttr);
                }

                import api.dm.kit.sprites2d.sprite2d : Sprite2d;

                BaseComponent spriteNode;

                if (typeAttr)
                {
                    auto type = typeAttr.fromXmlStr;
                    switch (type)
                    {
                        case "resistor":
                            auto resValueAttr = xmlGetProp(child, "data-resistance".toXmlStr);
                            assert(resValueAttr);
                            double resistance = resValueAttr.fromXmlStr.to!double;
                            scope (exit)
                            {
                                xmlFreeF(resValueAttr);
                            }

                            spriteNode = new Resistor(resistance, id);
                            break;
                        case "capacitor":
                            auto valueAttr = xmlGetProp(child, "data-capacitance".toXmlStr);
                            assert(valueAttr);
                            double cap = valueAttr.fromXmlStr.to!double;
                            scope (exit)
                            {
                                xmlFreeF(valueAttr);
                            }

                            spriteNode = new Capacitor(cap, id);
                            break;
                        case "voltage-source":
                            auto valueAttr = xmlGetProp(child, "data-voltage".toXmlStr);
                            assert(valueAttr);
                            scope (exit)
                            {
                                xmlFreeF(valueAttr);
                            }

                            double voltage = valueAttr.fromXmlStr.to!double;

                            spriteNode = new VoltageSource(voltage, id);
                            break;

                        case "wire":
                            auto dataSrcAttr = xmlGetProp(child, "data-src".toXmlStr);
                            assert(dataSrcAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataSrcAttr);
                            }

                            auto srcId = dataSrcAttr.fromXmlStr;
                            BaseTwoPinElement src = cast(BaseTwoPinElement) circuit.findItemUnsafe(
                                srcId);
                            if (!src)
                            {
                                throw new Exception("Source not found for wire: " ~ dump(docPtr, child));
                            }

                            auto dataDstAttr = xmlGetProp(child, "data-dst".toXmlStr);
                            assert(dataDstAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataDstAttr);
                            }

                            auto dstId = dataDstAttr.fromXmlStr;
                            BaseTwoPinElement dst = cast(BaseTwoPinElement) circuit.findItemUnsafe(
                                dstId);
                            if (!dst)
                            {
                                throw new Exception("Dest not found for wire: " ~ dump(docPtr, child));
                            }

                            auto dataPinFromAttr = xmlGetProp(child, "data-pin-from".toXmlStr);
                            assert(dataPinFromAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataPinFromAttr);
                            }

                            auto sourcePinType = dataPinFromAttr.fromXmlStr;

                            auto dataPinToAttr = xmlGetProp(child, "data-pin-to".toXmlStr);
                            assert(dataPinToAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataPinToAttr);
                            }

                            auto destPinType = dataPinToAttr.fromXmlStr;

                            if (sourcePinType == "n" && destPinType == "n")
                            {
                                spriteNode = new WireNN(src, dst);
                            }
                            else if (sourcePinType == "p" && destPinType == "n")
                            {
                                spriteNode = new WirePN(src, dst);
                            }
                            else if (sourcePinType == "n" && destPinType == "p")
                            {
                                spriteNode = new WireNP(src, dst);
                            }
                            else if (sourcePinType == "p" && destPinType == "p")
                            {
                                spriteNode = new WirePP(src, dst);
                            }
                            else
                            {
                                import std.format : format;

                                throw new Exception(format("Not supported wire pins: %s, %s", sourcePinType, destPinType));
                            }
                            break;
                        default:
                            break;
                    }
                }

                if (auto comp = cast(BaseElement) spriteNode)
                {
                    auto wValueAttr = xmlGetProp(child, "data-width".toXmlStr);
                    if (wValueAttr)
                    {
                        spriteNode.width = wValueAttr.fromXmlStr.to!double;
                        xmlFreeF(wValueAttr);
                    }

                    auto hValueAttr = xmlGetProp(child, "data-height".toXmlStr);
                    if (hValueAttr)
                    {
                        spriteNode.height = hValueAttr.fromXmlStr.to!double;
                        xmlFreeF(hValueAttr);
                    }
                }

                circuit.addCreateItem(spriteNode);

                if (auto comp = cast(BaseElement) spriteNode)
                {
                    auto xValueAttr = xmlGetProp(child, "data-x".toXmlStr);
                    if (xValueAttr)
                    {
                        spriteNode.x = xValueAttr.fromXmlStr.to!double;
                        xmlFreeF(xValueAttr);
                    }

                    auto yValueAttr = xmlGetProp(child, "data-y".toXmlStr);
                    if (yValueAttr)
                    {
                        spriteNode.y = yValueAttr.fromXmlStr.to!double;
                        xmlFreeF(yValueAttr);
                    }
                }

                child = xmlNextElementSibling(child);
            }

            node = xmlNextElementSibling(node);
        }
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

        import std.format : format;

        string colorStr = graphic.screenColor.toWebHex;
        //style="background-color: black;"
        xmlNewProp(root, "style".toXmlStr, format("background-color: %s;", colorStr).toXmlStr);

        foreach (item; circuit.children)
        {
            xmlNode* elemNode;

            if (auto element = cast(BaseElement) item)
            {
                Vec2d translateOffset = Vec2d.zero;
                if (element.content)
                {
                    translateOffset = element.content.pos;
                }

                auto svgText = element.createSVG;
                if (svgText.length > 0)
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

                                xmlSetProp(elemNode, "transform".toXmlStr, format("translate(%d, %d)",
                                        cast(int) translateOffset.x, cast(int) translateOffset.y)
                                        .toXmlStr);

                            }
                        }
                    }
                }

                if (!elemNode)
                {
                    elemNode = xmlNewChild(root, null, "rect".toXmlStr, null);
                }

                if (auto resistor = cast(Resistor) element)
                {
                    xmlNewProp(elemNode, "data-type".toXmlStr, "resistor".toXmlStr);
                    xmlNewProp(elemNode, "data-resistance".toXmlStr, resistor
                            .resistance.to!string.toXmlStr);
                }
                else if (auto voltageSource = cast(VoltageSource) element)
                {
                    xmlNewProp(elemNode, "data-type".toXmlStr, "voltage-source".toXmlStr);
                    xmlNewProp(elemNode, "data-voltage".toXmlStr, voltageSource
                            .voltage.to!string.toXmlStr);
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
            else if (auto wire = cast(Wire) item)
            {
                elemNode = xmlNewChild(root, null, "line".toXmlStr, null);
                auto src = wire.src;
                auto dst = wire.dst;

                auto x1 = wire.startLine.x;
                auto y1 = wire.startLine.y;

                auto x2 = wire.endLine.x;
                auto y2 = wire.endLine.y;

                xmlNewProp(elemNode, "data-type".toXmlStr, "wire".toXmlStr);

                xmlNewProp(elemNode, "data-src".toXmlStr, src.id.toXmlStr);
                xmlNewProp(elemNode, "data-dst".toXmlStr, dst.id.toXmlStr);

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

                xmlNewProp(elemNode, "data-pin-from".toXmlStr, fromPin.toXmlStr);
                xmlNewProp(elemNode, "data-pin-to".toXmlStr, toPin.toXmlStr);
            }

            if (!elemNode)
            {
                continue;
            }

            import api.dm.kit.sprites2d.sprite2d : Sprite2d;

            if (auto sprite = cast(Sprite2d) item)
            {
                const x = sprite.x;
                const y = sprite.y;

                xmlNewProp(elemNode, "data-x".toXmlStr, x
                        .to!string.toXmlStr);
                xmlNewProp(elemNode, "data-y".toXmlStr, y
                        .to!string.toXmlStr);

                if (sprite.id.length > 0)
                {
                    auto idPropName = "data-id".toXmlStr;
                    xmlNewProp(elemNode, idPropName, sprite.id.toXmlStr);
                }
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

    string dump(xmlDoc* docPtr, xmlNode* child, int level = 1, int format = 1)
    {
        auto buff = xmlBufferCreate();
        assert(buff);
        scope (exit)
        {
            xmlBufferFree(buff);
        }

        xmlNodeDump(buff, docPtr, child, level, format);

        auto buffStr = xmlBufferContent(buff);
        string nodeXml = !buffStr ? "null" : buffStr.fromXmlStr.idup;
        return nodeXml;
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
