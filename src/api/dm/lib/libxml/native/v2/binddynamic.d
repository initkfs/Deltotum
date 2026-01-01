module api.dm.lib.libxml.native.v2.binddynamic;

/**
 * Authors: initkfs
 */
import api.dm.lib.libxml.native.v2.types;
import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;

import core.stdc.stdlib : free;

static extern (C) xmlParserInput* emptyXmlExternalEntityLoader(const char* URL, const char* publicId, xmlParserCtxt* context)
{
    return null;
}

xmlFreeFunc _xmlFree;

extern (C) nothrow
{
    char** xmlParserVersion;

    int function(xmlFreeFunc freeFunc,
        xmlMallocFunc mallocFunc,
        xmlReallocFunc reallocFunc,
        xmlStrdupFunc strdupFunc) xmlMemSetup;

    int function(xmlFreeFunc* freeFunc, xmlMallocFunc* mallocFunc,
        xmlReallocFunc* reallocFunc,
        xmlStrdupFunc* strdupFunc) xmlMemGet;

    void function(void*) xmlFree;
    void* function(size_t size) xmlMalloc;

    void function() xmlInitParser;
    void function() xmlInitMemory;
    void function() xmlCleanupParser;

    xmlDoc* function(const char* buffer, int size, const char* URL, const char* encoding, int options) htmlReadMemory;
    void function(xmlDoc*) xmlFreeDoc;

    xmlDoc* function(const char* buffer, int size, const char* URL, const char* encoding, int options) xmlReadMemory;

    xmlDtd* function(xmlDoc* doc,
        const xmlChar* name,
        const xmlChar* publicId,
        const xmlChar* systemId) xmlNewDtd;

    xmlNode* function(xmlNode* parent) xmlFirstElementChild;

    xmlNode* function(const xmlDoc* doc) xmlDocGetRootElement;
    xmlChar* function(xmlNode* cur) xmlNodeGetContent;
    xmlChar* function(const xmlNode* node) xmlGetNodePath;
    xmlNode* function(xmlNode* node) xmlNextElementSibling;
    xmlAttr* function(xmlNode* node, const xmlChar* name, const xmlChar* value) xmlNewProp;
    xmlChar* function(const xmlNode* node, const xmlChar* name) xmlGetProp;
    xmlAttr* function(xmlNode* node, const xmlChar* name, const xmlChar* value) xmlSetProp;
    xmlAttr* function(const xmlNode* node, const xmlChar* name) xmlHasProp;
    int function(const xmlNode* node) xmlIsBlankNode;

    xmlChar* function(xmlDoc* doc, const xmlNode* list, int inLine) xmlNodeListGetString;

    long function(const xmlNode* node) xmlGetLineNo;

    void function(xmlNode* cur) xmlFreeNode;

    xmlDoc* function(const xmlChar* ver) xmlNewDoc;
    xmlNode* function(xmlDoc* doc, xmlNode* root) xmlDocSetRootElement;
    xmlNode* function(xmlNs* ns, const xmlChar* name) xmlNewNode;
    xmlNode* function(xmlNode* node, int extended) xmlCopyNode;

    xmlNode* function(xmlNode* parent, xmlNs* ns, const xmlChar* name, const xmlChar* content) xmlNewChild;
    xmlNode* function(xmlNode* parent, xmlNode* cur) xmlAddChild;
    xmlNode* function(const xmlChar* content) xmlNewText;

    xmlSaveCtxt* function(const char* filename, const char* encoding, int options) xmlSaveToFilename;
    xmlSaveCtxt* function(xmlBuffer* buffer, const char* encoding, int options) xmlSaveToBuffer;

    long function(xmlSaveCtxt* ctxt, xmlDoc* doc) xmlSaveDoc;
    int function(xmlSaveCtxt* ctxt) xmlSaveClose;

    xmlError* function() xmlGetLastError;
    void function() xmlResetLastError;

    xmlDoc* function(const xmlChar* URI, const xmlChar* publicId) htmlNewDocNoDtD;

    void function(xmlExternalEntityLoader f) xmlSetExternalEntityLoader;

    xmlBuffer* function() xmlBufferCreate;
    void function(xmlBuffer*) xmlBufferFree;
    xmlChar* function(xmlBuffer* buf) xmlBufferContent;

    int function(xmlBuffer* buf,
        xmlDoc* doc,
        xmlNode* cur,
        int level,
        int format) xmlNodeDump;

}

class LibxmlLib : DynamicLoader
{
    bool isDisableExternLoading = true;

    override void bindAll()
    {
        bind(cast(void*)&xmlParserVersion, "xmlParserVersion");
        bind(&xmlInitMemory, "xmlInitMemory");
        bind(&xmlMemSetup, "xmlMemSetup");
        bind(&xmlMemGet, "xmlMemGet");
        bind(&xmlFree, "xmlFree");
        bind(&xmlMalloc, "xmlMalloc");
        bind(&xmlInitParser, "xmlInitParser");
        bind(&xmlCleanupParser, "xmlCleanupParser");
        bind(&htmlReadMemory, "htmlReadMemory");
        bind(&xmlReadMemory, "xmlReadMemory");
        bind(&xmlFreeDoc, "xmlFreeDoc");
        bind(&xmlNewDtd, "xmlNewDtd");
        bind(&xmlDocGetRootElement, "xmlDocGetRootElement");
        bind(&xmlFirstElementChild, "xmlFirstElementChild");
        bind(&xmlNodeGetContent, "xmlNodeGetContent");
        bind(&xmlGetNodePath, "xmlGetNodePath");
        bind(&xmlNextElementSibling, "xmlNextElementSibling");
        bind(&xmlNewProp, "xmlNewProp");
        bind(&xmlGetProp, "xmlGetProp");
        bind(&xmlSetProp, "xmlSetProp");
        bind(&xmlHasProp, "xmlHasProp");
        bind(&xmlIsBlankNode, "xmlIsBlankNode");
        bind(&xmlNodeListGetString, "xmlNodeListGetString");
        bind(&xmlGetLineNo, "xmlGetLineNo");
        bind(&xmlFreeNode, "xmlFreeNode");

        bind(&xmlNewDoc, "xmlNewDoc");
        bind(&xmlDocSetRootElement, "xmlDocSetRootElement");
        bind(&xmlNewNode, "xmlNewNode");
        bind(&xmlCopyNode, "xmlCopyNode");
        bind(&xmlNewChild, "xmlNewChild");
        bind(&xmlAddChild, "xmlAddChild");
        bind(&xmlNewText, "xmlNewText");

        bind(&xmlSaveToFilename, "xmlSaveToFilename");
        bind(&xmlSaveToBuffer, "xmlSaveToBuffer");
        bind(&xmlSaveDoc, "xmlSaveDoc");
        bind(&xmlSaveClose, "xmlSaveClose");

        bind(&xmlGetLastError, "xmlGetLastError");
        bind(&xmlResetLastError, "xmlResetLastError");

        bind(&htmlNewDocNoDtD, "htmlNewDocNoDtD");

        bind(&xmlBufferCreate, "xmlBufferCreate");
        bind(&xmlBufferContent, "xmlBufferContent");
        bind(&xmlBufferFree, "xmlBufferFree");
        bind(&xmlNodeDump, "xmlNodeDump");

        bind(&xmlSetExternalEntityLoader, "xmlSetExternalEntityLoader");

        xmlInitParser();
        xmlInitMemory();

        // import core.stdc.stdlib : malloc, realloc, free;
        // import core.stdc.string : strdup;

        // if (xmlMemSetup(&free, &malloc, &realloc, &strdup))
        // {
        //     throw new Exception("Fail set libxml memory functions");
        // }

        if (xmlMemGet(&_xmlFree, null, null, null
            ))
        {
            throw new Exception("Error getting libxml allocators");
        }

        if (!_xmlFree)
        {
            throw new Exception("Libxml free function is null");
        }

        if (isDisableExternLoading)
        {
            xmlSetExternalEntityLoader(&emptyXmlExternalEntityLoader);
        }
    }

    version (Windows)
    {
        const(char)[][2] paths = ["libxml2.dll", "libxml.dll"];
    }
    else version (OSX)
    {
        const(char)[][1] paths = ["libxml2.dylib"];
    }
    else version (Posix)
    {
        const(char)[][1] paths = ["libxml2.so"];
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override int libVersion()
    {
        return 2;
    }

    override string libVersionStr()
    {
        import std.conv : to;

        if (!xmlParserVersion)
        {
            return super.libVersionStr;
        }

        import std.string : fromStringz;

        return (*xmlParserVersion).fromStringz.idup;
    }

}
