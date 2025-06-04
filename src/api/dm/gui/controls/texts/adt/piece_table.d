module api.dm.gui.controls.texts.adt.piece_table;

import std;
import core.stdc.stdlib;
import core.stdc.string;

/**
 * Authors: initkfs
 */
struct Piece
{
    char* source;
    int start;
    int length;
}

struct PieceTable
{
    char* original;

    char* additions;
    int add_pos;
    int add_capacity;

    Piece* pieces;
    int num_pieces;
    int pieces_capacity;

    void create(const char* text)
    {
        original = strdup(text);
        additions = cast(char*) malloc(1024);
        add_pos = 0;
        add_capacity = 1024;

        pieces = cast(Piece*) malloc(Piece.sizeof * 1);
        num_pieces = 1;
        pieces_capacity = 1;

        //Raw text
        pieces[0] = Piece(source : original, start:
            0, length:
            cast(int) strlen(text));
    }

    void destroy()
    {
        free(original);
        free(additions);
        free(pieces);
    }

    void insert(int pos, const char* text)
    {

        int text_len = cast(int) strlen(text);

        if (add_pos + text_len >= add_capacity)
        {
            add_capacity *= 2;
            additions = cast(char*) realloc(additions, add_capacity);
        }

        memcpy(additions + add_pos, text, text_len);

        int piece_index = 0;
        int offset = 0;
        for (; piece_index < num_pieces; piece_index++)
        {
            if (offset + pieces[piece_index].length >= pos)
                break;
            offset += pieces[piece_index].length;
        }

        // split piece into 2 parts, if is not at the end
        int split_pos = pos - offset;
        Piece old_piece = pieces[piece_index];

        if (num_pieces + 2 > pieces_capacity)
        {
            pieces_capacity *= 2;
            pieces = cast(Piece*) realloc(pieces, Piece.sizeof * pieces_capacity);
        }

        //right shift
        memmove(
            &pieces[piece_index + 2],
            &pieces[piece_index + 1],
            Piece.sizeof * (num_pieces - piece_index - 1)
        );

        //left piece before insertion
        pieces[piece_index] = Piece(source : old_piece.source,
    start:
            old_piece.start,
    length:
            split_pos
        );

        //new piece, append
        pieces[piece_index + 1] = Piece(source : additions, start:
            add_pos, length:
            text_len
        );

        //right piece, after insertion
        pieces[piece_index + 2] = Piece(
    source : old_piece.source,
    start:
            old_piece.start + split_pos,
    length:
            old_piece.length - split_pos
        );

        num_pieces += 2;
        add_pos += text_len;
    }

    char* text()
    {
        int total_len = 0;
        for (int i = 0; i < num_pieces; i++)
        {
            total_len += pieces[i].length;
        }

        char* result = cast(char*) malloc(total_len + 1);
        int pos = 0;

        for (int i = 0; i < num_pieces; i++)
        {
            memcpy(result + pos, pieces[i].source + pieces[i].start, pieces[i].length);
            pos += pieces[i].length;
        }

        result[total_len] = '\0';
        return result;
    }
}

unittest
{
    PieceTable pt;
    pt.create("Hello, world!");

    writefln("Original: %s\n", pt.text.fromStringz);

    pt.insert(7, "awesome ");
    writefln("After insert: %s\n", pt.text.fromStringz);

    destroy(pt);
}
