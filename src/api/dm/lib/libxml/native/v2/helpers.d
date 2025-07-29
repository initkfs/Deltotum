module api.dm.lib.libxml.native.v2.helpers;

import api.dm.lib.libxml.native.v2.types: xmlChar;

import std.string: toStringz, fromStringz;
import std.conv: to;

xmlChar* toXmlStr(string str) => cast(xmlChar*) str.toStringz;
xmlChar* toXmlStr(dstring str) => cast(xmlChar*) str.to!string.toStringz;
const(char)[] fromXmlStr(const xmlChar* str) => (cast(const(char*)) str).fromStringz;