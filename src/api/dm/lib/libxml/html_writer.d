module api.dm.lib.libxml.html_writer;

import api.dm.lib.libxml.native;

import std.string : toStringz, fromStringz;

/**
 * Authors: initkfs
 */
class HtmlWriter
{

    void save(string file)
    {
        xmlDoc* doc = xmlNewDoc("1.0".toXmlStr);

        xmlDtd* dtd = xmlNewDtd(doc, "html".toXmlStr, null, null);
        xmlAddChild(cast(xmlNode*) doc, cast(xmlNode*) dtd);

        xmlNode* html = xmlNewNode(null, "html".toXmlStr);
        xmlNewProp(html, "lang".toXmlStr, "en".toXmlStr);

        xmlDocSetRootElement(doc, html);

        xmlNode* head = xmlNewNode(null, "head".toXmlStr);
        xmlNode* title = xmlNewNode(null, "title".toXmlStr);
        xmlNode* titleText = xmlNewText("Hello world".toXmlStr);
        xmlAddChild(title, titleText);
        xmlAddChild(head, title);

        xmlNode* meta = xmlNewNode(null, "meta".toXmlStr);
        xmlNewProp(meta, "charset".toXmlStr, "utf-8".toXmlStr);
        xmlAddChild(head, meta);
        
        xmlAddChild(html, head);

        xmlNode* body = xmlNewNode(null, "body".toXmlStr);
        xmlNode* h1 = xmlNewNode(null, "h1".toXmlStr);
        xmlNode* h1Text = xmlNewText("Привет, мир!".toXmlStr);
        xmlAddChild(h1, h1Text);
        xmlAddChild(body, h1);

        xmlNode* p = xmlNewNode(null, "p".toXmlStr);
        xmlNode* pText = xmlNewText(
            "Test libxml2".toXmlStr);
        xmlAddChild(p, pText);
        xmlAddChild(body, p);

        xmlAddChild(html, body);

        xmlSaveCtxt* saveCtx = xmlSaveToFilename(
            file.toStringz,
            "UTF-8",
            xmlSaveOption.XML_SAVE_FORMAT | xmlSaveOption.XML_SAVE_NO_DECL
        );

        assert(saveCtx);
        scope(exit){
            xmlSaveClose(saveCtx);
        }

        if (xmlSaveDoc(saveCtx, doc) != 0)
        {
            throw new Exception("Error to saving");
        }

        // if (xmlSaveClose(saveCtx) != 0)
        // {
        //     throw new Exception(getLastError);
        // }

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
