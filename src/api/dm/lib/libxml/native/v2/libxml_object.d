module api.dm.lib.libxml.native.v2.libxml_object;

import api.dm.lib.libxml.native.v2.binddynamic;
import api.dm.lib.libxml.native.v2.types;
import api.dm.lib.libxml.native.v2.helpers;

/**
 * Authors: initkfs
 */

class LibXmlObject
{
    string getLastErrorNew()
    {
        xmlError* errorPtr = xmlGetLastError();
        if (!errorPtr)
        {
            return "Error is empty";
        }

        import std.format : format;
        import std.string : fromStringz;

        return format("%s:%s %s", errorPtr.file.fromStringz, errorPtr.line, errorPtr
                .message.fromStringz);
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

}
