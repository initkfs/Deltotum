module api.dm.gui.controls.texts.adt.piece_table;

import std;
import core.stdc.stdlib;
import core.stdc.string;

/**
 * Authors: initkfs
 */
struct Piece
{
    char[] source;

    size_t start;
    size_t length;

    char[] text()
    {
        return source[start .. start + length];
    }

    string toString()
    {
        import std.format : format;

        return format("s:%d,len:%s,text:|%s|", start, length, text);
    }
}

struct PieceTable
{
    char[] original;

    char[] additions;
    size_t additionPos;
    size_t additionsCapacity = 1024;

    Piece[] pieces;
    size_t numPieces;
    size_t piecesCapacity = 1;

    void create(const(char)[] text)
    {
        original = (cast(char*) malloc(text.length))[0 .. text.length];
        original[] = text;

        assert(additionsCapacity > 0);
        additions = (cast(char*) malloc(additionsCapacity))[0 .. additionsCapacity];
        additionPos = 0;

        pieces = (cast(Piece*) malloc(Piece.sizeof * piecesCapacity))[0 .. piecesCapacity];
        numPieces = piecesCapacity;

        //Raw text
        pieces[0] = Piece(source : original, start:
            0, length:
            original.length);
    }

    void destroy()
    {
        free(original.ptr);
        free(additions.ptr);
        free(pieces.ptr);
    }

    void insert(int pos, const(char)[] text)
    {
        size_t textLen = text.length;

        if (additionPos + text.length >= additions.length)
        {
            const newCapacity = additions.length > textLen ? additions.length * 2 : (
                textLen + additions.length) * 2;
            additions = (cast(char*) realloc(additions.ptr, newCapacity))[0 .. newCapacity];
        }

        additions[additionPos .. textLen] = text;

        size_t pieceIndex;
        size_t pieceOffset;
        for (; pieceIndex < numPieces; pieceIndex++)
        {
            auto piece = pieces[pieceIndex];
            if (pieceOffset + piece.length >= pos)
                break;
            pieceOffset += piece.length;
        }

        // split piece into 2 parts, if is not at the end
        size_t splitPos = pos - pieceOffset + 1;
        Piece oldPiece = pieces[pieceIndex];

        const minPieces = numPieces + 2;
        if (minPieces > pieces.length)
        {
            const newCapacity = minPieces * 2;
            pieces = (cast(Piece*) realloc(pieces.ptr, Piece.sizeof * newCapacity))[0 .. newCapacity];
        }

        //right shift
        /** 
         * for (int i = numPieces - 1; i >= pieceIndex + 1; i--) {
              pieces[i + 2] = pieces[i];
           }
         */
        auto srcSlice = pieces[pieceIndex + 1 .. numPieces];
        foreach (i, ref item; srcSlice)
        {
            pieces[pieceIndex + 2 + i] = item;
        }

        //left piece before insertion
        pieces[pieceIndex] = Piece(source : oldPiece.source,
    start:
            oldPiece.start,
    length:
            splitPos
        );

        //new piece, append
        pieces[pieceIndex + 1] = Piece(source : additions, start:
            additionPos, length:
            textLen
        );

        //right piece, after insertion
        pieces[pieceIndex + 2] = Piece(
    source : oldPiece.source,
    start:
            oldPiece.start + splitPos,
    length:
            oldPiece.length - splitPos
        );

        numPieces += 2;
        additionPos += textLen;
    }

    void remove(int pos, int length)
    {
        if (length <= 0)
        {
            return;
        }

        int remainLen = length;
        int currentPos = 0;
        int i = 0;

        //find starting peace
        while (i < numPieces && currentPos + pieces[i].length <= pos)
        {
            currentPos += pieces[i].length;
            i++;
        }

        //out of bounds
        if (i >= numPieces)
        {
            return;
        }

        int offsetInPiece = pos - currentPos;
        Piece* piece = &pieces[i];

        //Removal starts in the piece middle
        if (offsetInPiece > 0)
        {
            if (numPieces + 1 > pieces.length)
            {
                const newCapacity = (numPieces + 1) * 2;
                pieces = (cast(Piece*) realloc(pieces.ptr, Piece.sizeof * newCapacity))[0 .. newCapacity];
            }

            //right shift
            for (size_t j = numPieces - 1; j >= i + 1; j--)
            {
                pieces[j + 1] = pieces[j];
            }

            //left piece before removing
            pieces[i].length = offsetInPiece;

            //right piece after removing
            pieces[i + 1] = Piece(
                piece.source,
                piece.start + offsetInPiece,
                piece.length - offsetInPiece);
            numPieces++;
            i++;
        }

        //Removing whole pieces
        while (i < numPieces && remainLen >= pieces[i].length)
        {
            remainLen -= pieces[i].length;
            //left shift
            for (size_t j = i; j < numPieces - 1; j++)
            {
                pieces[j] = pieces[j + 1];
            }
            numPieces--;
        }

        //Removing part of a piece
        if (remainLen > 0 && i < numPieces)
        {
            pieces[i].start += remainLen;
            pieces[i].length -= remainLen;
        }
    }

    char[] text()
    {
        int totalLen = 0;
        foreach (i; 0 .. numPieces)
        {
            totalLen += pieces[i].length;
        }

        char[] result = (cast(char*) malloc(totalLen))[0 .. totalLen];
        int pos = 0;

        foreach (i; 0 .. numPieces)
        {
            auto piece = pieces[i];
            result[pos .. pos + piece.length] = piece.text;
            pos += piece.length;
        }

        return result;
    }
}

unittest
{
    PieceTable pt;

    pt.create("Hello, world!");
    assert(pt.numPieces == 1);
    assert(pt.pieces[0].text == "Hello, world!");

    pt.insert(6, "awesome ");
    assert(pt.pieces.length == (3 * 2));
    assert(pt.numPieces == 3);

    auto p0 = pt.pieces[0];
    assert(p0.start == 0);
    assert(p0.length == 7);
    assert(p0.text == "Hello, ");

    auto p1 = pt.pieces[1];
    assert(p1.start == 0);
    assert(p1.length == 8);
    assert(p1.text == "awesome ");

    auto p2 = pt.pieces[2];
    assert(p2.start == 7);
    assert(p2.length == 6);
    assert(p2.text == "world!");

    pt.destroy;
}

unittest
{
    PieceTable pt;

    pt.create("Hello, world!");
    pt.remove(0, 2);
    assert(pt.text == "llo, world!");
    pt.remove(8, 3);
    assert(pt.text == "llo, wor");
    pt.destroy;

    pt.create("Hello, ");
    pt.insert(6, "world!");
    assert(pt.text == "Hello, world!");
    pt.remove(7, 6);
    assert(pt.text == "Hello, ");
}
