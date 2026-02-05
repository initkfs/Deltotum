module api.dm.kit.assets.xml.xml_elements;

/**
 * Authors: initkfs
 */

class XmlException : Exception
{
    this(string msg, size_t position = 0)
    {
        import std.conv : to;

        super(msg ~ (position ? " at position " ~ position.to!string : ""));
    }
}

struct XmlAttr
{
    string name;
    string value;
}

class XmlElement
{
    string name;
    XmlAttr[] attributes;

    XmlElement[] children;
    string text;

    this(string name, XmlAttr[] attrs = null)
    {
        this.name = name;
        this.attributes = attrs;
    }

    void addChild(XmlElement child)
    {
        children ~= child;
    }

    void setAttr(string name, string value)
    {
        foreach (attr; attributes)
        {
            if (attr.name == name)
            {
                attr.value = value;
                return;
            }
        }

        attributes ~= XmlAttr(name, value);
    }

    auto getAttrT(T)(string name)
    {
        import std.conv : to;

        string val = getAttr(name);
        if (val.length == 0)
        {
            throw new XmlException("Not found attr with name: " ~ name);
        }
        return val.to!T;
    }

    string getAttr(string name)
    {
        foreach (attr; attributes)
        {
            if (attr.name == name)
                return attr.value;
        }
        return null;
    }

    bool hasAttr(string name)
    {
        foreach (attr; attributes)
        {
            if (attr.name == name)
            {
                return true;
            }

        }
        return false;
    }

    XmlElement elementById(string id, string idKey = "id")
    {
        if (getAttr(idKey) == id)
            return this;

        foreach (child; children)
        {
            auto result = child.elementById(id);
            if (result)
            {
                return result;
            }
        }

        return null;
    }

    XmlElement[] elementsByName(string tagName)
    {
        XmlElement[] results;

        if (this.name == tagName)
            results ~= this;

        foreach (child; children)
        {
            results ~= child.elementsByName(tagName);
        }

        return results;
    }

    string toXml(uint indent = 0)
    {
        import std.array : replicate;

        string space = " ".replicate(indent);
        string result = space ~ "<" ~ name;

        foreach (attr; attributes)
        {
            result ~= ` ` ~ attr.name ~ `="` ~ attr.value ~ `"`;
        }

        if (children.length == 0 && text.length == 0)
        {
            result ~= "/>\n";
            return result;
        }

        result ~= ">";

        if (!text.length == 0)
        {
            result ~= text;
        }

        if (!children.length == 0)
        {
            result ~= "\n";
            foreach (child; children)
            {
                result ~= child.toXml(indent + 2);
            }
            result ~= space;
        }

        result ~= "</" ~ name ~ ">\n";
        return result;
    }
}
