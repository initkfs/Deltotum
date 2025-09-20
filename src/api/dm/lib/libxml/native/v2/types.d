module api.dm.lib.libxml.native.v2.types;
/**
 * Authors: initkfs
 */

extern (C):

alias xmlMallocFunc = void* function(size_t size);
alias xmlReallocFunc = void* function(void* mem, size_t size);
alias xmlFreeFunc = void function(void* mem);
alias xmlStrdupFunc = char* function(const char* str);

alias xmlChar = ubyte;

struct xmlNs;
struct xmlDtd;
struct xmlDict;
struct xmlID;
struct xmlBuffer;

struct xmlSaveCtxt;

struct xmlNode
{
    void* _private;
    xmlElementType type;
    xmlChar* name;

    xmlNode* children;
    xmlNode* last;
    xmlNode* parent;
    xmlNode* next;
    xmlNode* prev;
    xmlDoc* doc;

    xmlNs* ns; /* namespace */
    xmlChar* content;
    xmlAttr* properties;
    xmlNs* nsDef; /* namespace definitions */
    void* psvi; /* type/PSVI information */
    ushort line;
    ushort extra; /* extra data for XPath/XSLT */
}

struct xmlDoc
{
    void* _private;
    xmlElementType type;
    char* name;
    xmlNode* children;
    xmlNode* last;
    xmlNode* parent;
    xmlNode* next;
    xmlNode* prev;
    xmlDoc* doc;
    int compression;
    int standalone;
    xmlDtd* intSubset;
    xmlDtd* extSubset;
    xmlNs* oldNs;
    xmlChar* ver;
    xmlChar* encoding;
    void* ids;
    void* refs;
    xmlChar* URL;
    int charset;
    xmlDict* dict;
    void* psvi;
    int parseFlags;
    int properties;
}

struct xmlAttr
{
    void* _private;
    xmlElementType type;
    const xmlChar* name;
    xmlNode* children;
    xmlNode* last;
    xmlNode* parent;
    xmlAttr* next;
    xmlAttr* prev;
    xmlDoc* doc;
    xmlNs* ns;
    xmlAttributeType atype;
    void* psvi;
    xmlID* id;
}

enum xmlAttributeType
{
    XML_ATTRIBUTE_CDATA = 1,
    XML_ATTRIBUTE_ID,
    XML_ATTRIBUTE_IDREF,
    XML_ATTRIBUTE_IDREFS,
    XML_ATTRIBUTE_ENTITY,
    XML_ATTRIBUTE_ENTITIES,
    XML_ATTRIBUTE_NMTOKEN,
    XML_ATTRIBUTE_NMTOKENS,
    XML_ATTRIBUTE_ENUMERATION,
    XML_ATTRIBUTE_NOTATION
}

enum xmlElementType
{
    XML_ELEMENT_NODE = 1,
    XML_ATTRIBUTE_NODE = 2,
    XML_TEXT_NODE = 3,
    XML_CDATA_SECTION_NODE = 4,
    XML_ENTITY_REF_NODE = 5,
    XML_ENTITY_NODE = 6, /* unused */
    XML_PI_NODE = 7,
    XML_COMMENT_NODE = 8,
    XML_DOCUMENT_NODE = 9,
    XML_DOCUMENT_TYPE_NODE = 10, /* unused */
    XML_DOCUMENT_FRAG_NODE = 11,
    XML_NOTATION_NODE = 12, /* unused */
    XML_HTML_DOCUMENT_NODE = 13,
    XML_DTD_NODE = 14,
    XML_ELEMENT_DECL = 15,
    XML_ATTRIBUTE_DECL = 16,
    XML_ENTITY_DECL = 17,
    XML_NAMESPACE_DECL = 18,
    XML_XINCLUDE_START = 19,
    XML_XINCLUDE_END = 20
}

struct xmlError
{
    int domain;
    int code;
    char* message;
    xmlErrorLevel level;
    char* file;
    int line;
    char* str1;
    char* str2;
    char* str3;
    int int1;
    int int2;
    void* ctxt;
    void* node;
}

enum xmlErrorLevel
{
    XML_ERR_NONE = 0,
    XML_ERR_WARNING = 1,
    XML_ERR_ERROR = 2,
    XML_ERR_FATAL = 3
}

enum htmlParserOption
{
    HTML_PARSE_NOERROR = 1 << 5, /* suppress error reports */
    HTML_PARSE_NOWARNING = 1 << 6, /* suppress warning reports */
    HTML_PARSE_HTML5 = 1 << 26 /* HTML5 support */
}

enum xmlSaveOption
{
    XML_SAVE_FORMAT = 1 << 0,
    XML_SAVE_NO_DECL = 1 << 1,
    XML_SAVE_NO_EMPTY = 1 << 2,
    XML_SAVE_NO_XHTML = 1 << 3,
    XML_SAVE_XHTML = 1 << 4,
    XML_SAVE_AS_XML = 1 << 5,
    XML_SAVE_AS_HTML = 1 << 6,
    XML_SAVE_WSNONSIG = 1 << 7,
    XML_SAVE_EMPTY = 1 << 8,
    XML_SAVE_NO_INDENT = 1 << 9,
    XML_SAVE_INDENT = 1 << 10
}

enum xmlParserOption
{
    XML_PARSE_NOERROR = 1 << 5,
    XML_PARSE_NOWARNING = 1 << 6
}
