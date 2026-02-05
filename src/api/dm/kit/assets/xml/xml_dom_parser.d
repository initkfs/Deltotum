module api.dm.kit.assets.xml.xml_dom_parser;

import api.dm.kit.assets.xml.xml_elements : XmlAttr, XmlElement, XmlException;

import Ascii = std.ascii;
import std.conv : to;

/**
 * Authors: initkfs
 */

class DomParser
{
    protected string source;
    protected size_t index;
    protected size_t line = 1;
    protected size_t column = 1;

    char eof = '\0';
    char linebreak = '\n';

    void delegate(string message, size_t index, size_t line, size_t col) onLog;
    bool isLog;

    protected bool log(string message)
    {
        if (!isLog || !onLog)
        {
            return false;
        }

        onLog(message, index, line, column);
        return true;
    }

    XmlElement parse(string xml)
    {
        source = xml;
        index = 0;
        line = 1;
        column = 1;

        skipWhitespace;

        if (peek == '<' && peek(1) == '?')
        {
            parseXmlDecl;
        }

        skipWhitespace;

        return parseElement;
    }

    protected void skipWhitespace()
    {
        while (index < source.length && Ascii.isWhite(source[index]))
        {
            if (isLog)
            {
                log("[ ]");
            }
            next;
        }
    }

    protected char next()
    {
        if (index >= source.length)
        {
            if (isLog)
            {
                log("[eof]");
            }
            return eof;
        }

        char ch = source[index];
        index++;

        if (ch == linebreak)
        {
            line++;
            column = 1;
            if (isLog)
            {
                log("[ln]");
            }
        }
        else
        {
            column++;
        }

        return ch;
    }

    protected char peek(size_t ahead = 0)
    {
        size_t newIndex = index + ahead;
        if (newIndex >= source.length)
        {
            if (isLog)
            {
                log("[eof]");
            }
            return eof;
        }

        return source[newIndex];
    }

    protected void parseXmlDecl()
    {
        if (peek != '<' && peek(1) != '?')
        {
            new XmlException("Expected '<?' for XML declaration", index);
        }

        next;
        next;

        if (isLog)
        {
            log("[<?]");
        }

        // Skip to "?>"
        while (index < source.length)
        {
            if (peek == '?' && peek(1) == '>')
            {
                next;
                next;
                if (isLog)
                {
                    log("[?>]");
                }
                return;
            }
            next;
        }

        throw new XmlException("Unclosed XML declaration", index);
    }

    protected XmlElement parseElement()
    {
        // Expect opening '<'
        if (peek != '<')
        {
            throw new XmlException("Expected '<' to start element", index);
        }

        next;

        if (isLog)
        {
            log("[<]");
        }

        string name = parseName;
        auto element = new XmlElement(name);

        // Parse attributes
        skipWhitespace;
        while (peek != '>' && !(peek == '/' && peek(1) == '>'))
        {
            auto attr = parseAttribute;
            element.attributes ~= attr;
            skipWhitespace;
        }

        // Check for self-closing tag
        if (peek == '/')
        {
            next;
            if (isLog)
            {
                log("[/]");
            }

            if (peek != '>')
            {
                throw new XmlException("Expected '>' after '/'", index);
            }

            next; // Skip '>'
            if (isLog)
            {
                log("[>]");
            }
            return element;
        }

        // Expect '>' for normal element
        if (peek != '>')
        {
            throw new XmlException("Expected '>' or '/>'", index);
        }

        next;
        if (isLog)
        {
            log("[>]");
        }

        parseContent(element);

        // Parse closing
        if (peek != '<')
        {
            throw new XmlException("Expected closing tag", index);
        }
        next;
        if (isLog)
        {
            log("[<]");
        }

        if (peek != '/')
        {
            throw new XmlException("Expected '/' in closing tag", index);
        }

        next;
        if (isLog)
        {
            log("[/]");
        }

        string closingName = parseName;
        if (closingName != name)
        {
            throw new XmlException("Mismatched closing tag. Expected: </" ~ name ~ ">, got: </" ~ closingName ~ ">", index);
        }

        skipWhitespace;
        if (peek != '>')
        {
            throw new XmlException("Expected '>' to close element", index);
        }

        next;
        if (isLog)
        {
            log("[>]");
        }

        return element;
    }

    protected string parseName()
    {
        size_t start = index;

        // letter or underscore
        if (index >= source.length || !Ascii.isAlpha(source[index]) || source[index] == '_')
        {
            import std.format : format;

            throw new XmlException(format("Invalid name start character: '%s'", index < source.length ? source[index]
                    : 0), index);
        }

        if (isLog)
        {
            log("[startname:" ~ source[index] ~ "]");
        }

        next;

        // rest of name
        while (index < source.length)
        {
            char ch = source[index];
            if (Ascii.isAlphaNum(ch) || ch == '_' || ch == '-' || ch == ':' || ch == '.')
            {
                next;
                if (isLog)
                {
                    log("[name:" ~ ch ~ "]");
                }
            }
            else
            {
                break;
            }
        }

        return source[start .. index];
    }

    protected XmlAttr parseAttribute()
    {
        string name = parseName;

        skipWhitespace;
        if (peek != '=')
        {
            throw new XmlException("Expected '=' after attribute name", index);
        }

        next;
        if (isLog)
        {
            log("[=]");
        }

        skipWhitespace;

        // Parse attribute value (must be quoted)
        char quote = peek;
        if (quote != '"' && quote != '\'')
        {
            throw new XmlException("Expected quote for attribute value", index);
        }

        next;
        if (isLog)
        {
            log("[" ~ quote ~ "]");
        }

        //TODO logging
        size_t valueStart = index;
        while (index < source.length && source[index] != quote)
        {
            next;
        }

        if (peek != quote)
        {
            throw new XmlException("Unclosed attribute value", index);
        }

        string value = source[valueStart .. index];
        next; // Skip closing quote

        value = decodeEntitiesInText(value);

        return XmlAttr(name, value);
    }

    protected void parseContent(XmlElement element)
    {
        bool hasText = false;
        bool hasChildren = false;

        while (index < source.length)
        {
            skipWhitespace;

            if (peek == '<')
            {
                if (peek(1) == '!')
                {
                    handleSpecials(element);
                }
                else if (peek(1) == '/')
                {
                    if (hasText && hasChildren)
                    {
                        throw new XmlException(
                            "Mixed content (text and elements together) not supported: " ~ element.name,
                            index
                        );
                    }
                    return;
                }
                else
                {
                    hasChildren = true;

                    if (hasText)
                    {
                        throw new XmlException(
                            "Mixed content (text and elements together) not supported in SVG: " ~ element.name,
                            index
                        );
                    }

                    element.addChild(parseElement);
                }
            }
            else
            {
                size_t textStart = index;
                while (index < source.length && peek != '<')
                {
                    next;
                }

                string textContent = source[textStart .. index];

                // if (!isWhiteOnly(textContent) ||
                //     (element.children.empty && element.text.empty))
                // {
                //     element.text ~= textContent;
                // }

                if (!isWhiteOnly(textContent))
                {
                    hasText = true;

                    if (hasChildren)
                    {
                        throw new XmlException(
                            "Mixed content (text and elements together) not supported: " ~ element.name,
                            index
                        );
                    }

                    textContent = decodeEntitiesInText(textContent);
                    element.text ~= textContent;
                }
            }
        }
    }

    protected void handleSpecials(XmlElement element)
    {
        //"<!"
        next;
        next;

        if (isLog)
        {
            log("[<!]");
        }

        if (peek() == '-' && peek(1) == '-')
        {
            //<!-- ... -->
            parseComment;
        }
        else if (peek == '[')
        {
            next;
            if (isLog)
            {
                log("[");
            }
            // <![CDATA[ ... ]]>
            parseCData(element);
        }
        else
        {
            // <!DOCTYPE, <!ENTITY
            parseUnknownDecl;
        }
    }

    protected void parseComment()
    {
        //"--"
        next;
        next;

        if (isLog)
        {
            log("[--]");
        }

        // to "-->"
        while (index < source.length)
        {
            if (peek == '-' && peek(1) == '-' && peek(2) == '>')
            {
                // "-->"
                next;
                next;
                next;
                if (isLog)
                {
                    log("[-->]");
                }
                return;
            }
            next;
        }

        throw new XmlException("Unclosed comment", index);
    }

    protected void parseCData(XmlElement element)
    {
        string expected = "CDATA[";
        for (int i = 0; i < expected.length; i++)
        {
            if (peek(i) != expected[i])
            {
                import std.format : format;

                throw new XmlException(format("Invalid CDATA section, expected '%s', received '%s'", expected[i], peek(
                        i)), index);
            }
        }

        //  "CDATA["
        for (int i = 0; i < expected.length; i++)
        {
            next;
        }

        if (isLog)
        {
            log("CDATA[");
        }

        //to "]]>"
        size_t start = index;
        while (index < source.length)
        {
            if (peek() == ']' && peek(1) == ']' && peek(2) == '>')
            {
                string cdataContent = source[start .. index];
                element.text ~= cdataContent;

                // "]]>"
                next;
                next;
                next;
                if (isLog)
                {
                    log("]]>");
                }
                return;
            }
            next;
        }

        throw new XmlException("Unclosed CDATA section", index);
    }

    protected void parseUnknownDecl()
    {
        // to '>'
        while (index < source.length && peek() != '>')
        {
            next;
        }

        if (peek() == '>')
        {
            next; //  '>'
        }
    }

    protected bool isWhiteOnly(string s)
    {
        foreach (c; s)
        {
            if (!Ascii.isWhite(c))
            {
                return false;
            }

        }
        return true;
    }

    XmlElement parseFile(string filename)
    {
        import std.file : readText;

        return parse(readText(filename));
    }

    string decodeEntitiesInText(string text)
    {
        string result;
        size_t i = 0;

        while (i < text.length)
        {
            if (text[i] == '&')
            {
                // Find end of entity
                size_t end = i + 1;
                while (end < text.length && text[end] != ';')
                {
                    end++;
                }

                if (end < text.length && text[end] == ';')
                {
                    string entity = text[i .. end + 1];
                    result ~= decodeEntity(entity);
                    i = end + 1;
                }
                else
                {
                    // Not a valid entity, keep as-is
                    result ~= text[i];
                    i++;
                }
            }
            else
            {
                result ~= text[i];
                i++;
            }
        }

        return result;
    }

    /// Parse and decode single XML entity
    string decodeEntity(string entity)
    {
        if (entity.length < 3 || entity[0] != '&' || entity[$ - 1] != ';')
        {
            throw new XmlException("Invalid entity format: " ~ entity);
        }

        string code = entity[1 .. $ - 1];

        // Predefined entities
        switch (code)
        {
            case "lt":
                return "<";
            case "gt":
                return ">";
            case "amp":
                return "&";
            case "quot":
                return "\"";
            case "apos":
                return "'";
            default:
                // Numeric entities
                if (code.length > 1 && code[0] == '#')
                {
                    bool isHex = (code[1] == 'x' || code[1] == 'X');
                    string numStr = isHex ? code[2 .. $] : code[1 .. $];

                    // Validate numeric string
                    foreach (c; numStr)
                    {
                        if (isHex ? !Ascii.isHexDigit(c) : !Ascii.isDigit(c))
                        {
                            throw new XmlException("Invalid numeric entity: " ~ entity);
                        }
                    }

                    try
                    {
                        int codePoint = isHex
                            ? to!int(numStr, 16) : to!int(numStr);

                        // XML valid code points
                        if (codePoint == 0x9 || codePoint == 0xA || codePoint == 0xD ||
                            (codePoint >= 0x20 && codePoint <= 0xD7FF) ||
                            (codePoint >= 0xE000 && codePoint <= 0xFFFD) ||
                            (codePoint >= 0x10000 && codePoint <= 0x10FFFF))
                        {
                            //TODO decode
                            return (cast(dchar) codePoint).to!string;
                        }
                        else
                        {
                            throw new XmlException("Invalid XML code point: " ~ entity);
                        }
                    }
                    catch (Exception e)
                    {
                        throw new XmlException("Failed to parse entity: " ~ entity ~ ", " ~ e.msg);
                    }
                }

                // Unknown named entity
                throw new XmlException("Unknown XML entity: " ~ entity);
        }
    }
}

unittest
{
    import std.exception : assertThrown;

    {
        string xml = `<root><child>Text</child></root>`;
        auto parser = new DomParser();
        auto root = parser.parse(xml);

        assert(root.name == "root");
        assert(root.children.length == 1);
        assert(root.children[0].name == "child");
        assert(root.children[0].text == "Text");
    }

    {
        //Attrs
        string xml = `<element id="test" class="container" data-value="123"/>`;
        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        assert(elem.name == "element");
        assert(elem.getAttr("id") == "test");
        assert(elem.getAttr("class") == "container");
        assert(elem.getAttr("data-value") == "123");
        assert(elem.getAttr("missing") == "");
        assert(elem.hasAttr("id"));
        assert(!elem.hasAttr("missing"));
    }

    {
        //Self-closing tags
        string xml = `
            <svg>
                <circle cx="50" cy="50" r="40"/>
                <rect x="10" y="10" width="80" height="80"/>
            </svg>
        `;

        auto parser = new DomParser();
        auto svg = parser.parse(xml);

        assert(svg.name == "svg");
        assert(svg.children.length == 2);
        assert(svg.children[0].name == "circle");
        assert(svg.children[0].getAttr("cx") == "50");
        assert(svg.children[1].name == "rect");
        assert(svg.children[1].getAttr("width") == "80");

        // Self-closing elements should have no text
        assert(svg.children[0].text.length == 0);
    }

    {
        //Text content with whitespace
        string xml = `<p>  Some   text with  spaces  </p>`;
        auto parser = new DomParser();
        auto p = parser.parse(xml);
        assert(p.text == "Some   text with  spaces  ");
    }

    {
        //Nested elements
        string xml = `
            <html>
                <body>
                    <div class="header">
                        <h1>Title</h1>
                        <p>Paragraph</p>
                    </div>
                </body>
            </html>
        `;

        auto parser = new DomParser();
        auto html = parser.parse(xml);

        assert(html.name == "html");
        assert(html.children.length == 1);

        auto _body = html.children[0];
        assert(_body.name == "body");
        assert(_body.children.length == 1);

        auto div = _body.children[0];
        assert(div.name == "div");
        assert(div.getAttr("class") == "header");
        assert(div.children.length == 2);
        assert(div.children[0].name == "h1");
        assert(div.children[0].text == "Title");
        assert(div.children[1].name == "p");
        assert(div.children[1].text == "Paragraph");
    }

    {
        //XML declaration (ignored)
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
                      <document/>`;

        auto parser = new DomParser();
        auto doc = parser.parse(xml);

        assert(doc.name == "document");
    }

    {
        //Error handling - malformed XML
        // Missing closing tag
        string badXml1 = `<open>text`;
        auto parser1 = new DomParser();
        assertThrown!XmlException(parser1.parse(badXml1));

        // Mismatched tags
        string badXml2 = `<a><b></a></b>`;
        auto parser2 = new DomParser();
        assertThrown!XmlException(parser2.parse(badXml2));

        // Unclosed attribute
        string badXml3 = `<elem attr="value>`;
        auto parser3 = new DomParser();
        assertThrown!XmlException(parser3.parse(badXml3));

        // Invalid name start
        string badXml4 = `<123badname/>`;
        auto parser4 = new DomParser();
        assertThrown!XmlException(parser4.parse(badXml4));

        // Missing quote
        string badXml5 = `<elem attr=value/>`;
        auto parser5 = new DomParser();
        assertThrown!XmlException(parser5.parse(badXml5));
    }

    {
        //SVG
        string svg = `
            <svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="grad1">
                        <stop offset="0%" stop-color="red"/>
                        <stop offset="100%" stop-color="blue"/>
                    </linearGradient>
                </defs>
                <circle id="circle1" cx="100" cy="100" r="50" fill="url(#grad1)"/>
                <g transform="translate(50,50)">
                    <rect x="0" y="0" width="100" height="100" fill="green"/>
                    <text x="10" y="20">Hello SVG</text>
                </g>
            </svg>
        `;

        auto parser = new DomParser();
        auto root = parser.parse(svg);

        assert(root.name == "svg");
        assert(root.getAttr("width") == "200");
        assert(root.getAttr("xmlns") == "http://www.w3.org/2000/svg");

        auto defs = root.elementsByName("defs");
        assert(defs.length == 1);

        auto stops = root.elementsByName("stop");
        assert(stops.length == 2);
        assert(stops[0].getAttr("offset") == "0%");
        assert(stops[1].getAttr("offset") == "100%");

        auto circle = root.elementById("circle1");
        assert(circle !is null);
        assert(circle.getAttr("cx") == "100");
        assert(circle.getAttr("fill") == "url(#grad1)");

        auto groups = root.elementsByName("g");
        assert(groups.length == 1);
        assert(groups[0].getAttr("transform") == "translate(50,50)");

        auto texts = root.elementsByName("text");
        assert(texts.length == 1);
        assert(texts[0].text == "Hello SVG");
    }

    {
        //search methods
        string xml = `
            <root>
                <item id="first">Item 1</item>
                <item id="second">Item 2</item>
                <container>
                    <item id="third">Item 3</item>
                    <other>Test</other>
                </container>
                <item id="fourth">Item 4</item>
            </root>
        `;

        auto parser = new DomParser();
        auto root = parser.parse(xml);

        // Find by ID
        auto second = root.elementById("second");
        assert(second !is null);
        assert(second.text == "Item 2");

        auto third = root.elementById("third");
        assert(third !is null);
        assert(third.text == "Item 3");

        // Find non-existent
        assert(root.elementById("missing") is null);

        // Find all items
        auto allItems = root.elementsByName("item");
        assert(allItems.length == 4);
        assert(allItems[0].getAttr("id") == "first");
        assert(allItems[3].getAttr("id") == "fourth");

        // Find specific tag
        auto others = root.elementsByName("other");
        assert(others.length == 1);
        assert(others[0].text == "Test");
    }

    {
        // Names with hyphens, colons, dots
        string xml = `<ns:element-name attr.name="value.with.dots">
                        <child-1/>
                        <child.two/>
                      </ns:element-name>`;

        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        assert(elem.name == "ns:element-name");
        assert(elem.getAttr("attr.name") == "value.with.dots");
        assert(elem.children.length == 2);
        assert(elem.children[0].name == "child-1");
        assert(elem.children[1].name == "child.two");
    }

    {
        //Text with special characters
        string xml = `<text><![CDATA[This is <not> an element & should not be parsed]]></text>`;
        auto parser = new DomParser();
        auto elem = parser.parse(xml);
    }

    {
        //Empty elements and text, mixed not supported <mixed>Text<child/>More</mixed>
        string xml = `<root>
                        <empty1/>
                        <empty2></empty2>
                        <withtext>Text here</withtext>
                      </root>`;

        auto parser = new DomParser();
        parser.isLog = true;
        auto root = parser.parse(xml);

        assert(root.children.length == 3);
        assert(root.children[0].name == "empty1");
        assert(root.children[0].text.length == 0);
        assert(root.children[1].name == "empty2");
        assert(root.children[1].text.length == 0);
        assert(root.children[2].name == "withtext");
        assert(root.children[2].text == "Text here");
        //assert(root.children[3].name == "mixed");
        //assert(root.children[3].text == "Text");
        //assert(root.children[3].text == "TextMore");
        //assert(root.children[3].children.length == 1);
    }

    {
        //Attribute with single quotes
        string xml = `<element attr='single quoted' other="double quoted"/>`;
        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        assert(elem.getAttr("attr") == "single quoted");
        assert(elem.getAttr("other") == "double quoted");
    }

    {
        //toXml() serialization
        // Create a simple document
        auto root = new XmlElement("svg");
        root.setAttr("width", "100");
        root.setAttr("height", "100");

        auto circle = new XmlElement("circle");
        circle.setAttr("cx", "50");
        circle.setAttr("cy", "50");
        circle.setAttr("r", "40");
        root.addChild(circle);

        auto text = new XmlElement("text");
        text.text = "Hello";
        text.setAttr("x", "10");
        text.setAttr("y", "20");
        root.addChild(text);

        // Serialize
        string xml = root.toXml();

        // Parse it back
        auto parser = new DomParser();
        auto parsed = parser.parse(xml);

        // Verify structure is preserved
        assert(parsed.name == "svg");
        assert(parsed.getAttr("width") == "100");
        assert(parsed.children.length == 2);
        assert(parsed.children[0].name == "circle");
        assert(parsed.children[0].getAttr("r") == "40");
        assert(parsed.children[1].name == "text");
        assert(parsed.children[1].text == "Hello");
    }

    {
        // Whitespace handling in attributes
        string xml = `<element attr="  value with  spaces  "/>`;
        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        // Preserve spaces inside quotes
        assert(elem.getAttr("attr") == "  value with  spaces  ");
    }

    {
        //Deep nesting
        string xml = `<level1><level2><level3><level4><level5>Deep</level5></level4></level3></level2></level1>`;
        auto parser = new DomParser();
        auto root = parser.parse(xml);

        auto current = root;
        int depth = 0;
        while (!current.children.length == 0)
        {
            current = current.children[0];
            depth++;
        }

        assert(depth == 4);
        assert(current.name == "level5");
        assert(current.text == "Deep");
    }

    {
        //Mixed content (text and elements)
        string xml = `<p>This is <b>bold</b> and <i>italic</i> text.</p>`;
        auto parser = new DomParser();
        assertThrown!XmlException(parser.parse(xml));
    }

    {
        //Invalid XML
        auto parser = new DomParser();

        // Various invalid cases
        assertThrown!XmlException(parser.parse(""));
        assertThrown!XmlException(parser.parse("no tags here"));
        assertThrown!XmlException(parser.parse("<>"));
        assertThrown!XmlException(parser.parse("<"));
        assertThrown!XmlException(parser.parse("</>"));
        assertThrown!XmlException(parser.parse("<a></b>"));
        assertThrown!XmlException(parser.parse("<a b=>"));
        assertThrown!XmlException(parser.parse("<a b=\"no end quote>"));
    }

    // Test XML entities parsing
    {
        // Basic XML entities
        string xml = `<test attr="a&lt;b&quot;c&gt;d&amp;e'f">
                        Text &lt; &gt; &amp; &quot; &apos;
                      </test>`;

        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        // Check attributes
        assert(elem.getAttr("attr") == "a<b\"c>d&e'f");

        import std.string : strip;

        // Check text content
        assert(elem.text.strip == "Text < > & \" '");
    }

    // Numeric entities
    {
        string xml = `<test>&#65;&#x42;&#x43;</test>`; // A, B, C
        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        assert(elem.text == "ABC");
    }

    // Entity in attribute value
    {
        string xml = `<circle fill="&quot;red&quot;"/>`;
        auto parser = new DomParser();
        auto circle = parser.parse(xml);

        assert(circle.getAttr("fill") == "\"red\"");
    }

    // Invalid entity should throw
    {
        string xml = `<test>&invalid;</test>`;
        auto parser = new DomParser();

        assertThrown!XmlException(parser.parse(xml));
    }

    //Entity at end of text
    {
        string xml = `<test>Some text &amp; more</test>`;
        auto parser = new DomParser();
        auto elem = parser.parse(xml);

        assert(elem.text == "Some text & more");
    }
}
