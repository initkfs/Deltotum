module deltotum.core.utils.meta;

import std.traits : isIntegral;

/**
 * Authors: initkfs
 */
enum hasOverloads(alias type, string symbol) = __traits(getOverloads, type, symbol).length != 0;
