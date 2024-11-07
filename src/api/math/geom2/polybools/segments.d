module api.math.geom2.polybools.segments;
/*
 * Authors: initkfs
 */
import api.math.geom2.polybools.helpers : LinkedList, TransitionResult;
import api.math.geom2.polybools.helpers : Epsilon;

import std.algorithm.mutation : remove;
import std : reverse;

import std.stdio : writeln;

/* 
 * D port of https://github.com/Menecats/polybool-java
 * Copyright (c) 2021 Davide Menegatti (@menecats)
 * under MIT License: https://github.com/Menecats/polybool-java/blob/main/LICENSE
 */
class Segment
{

    public static class SegmentFill
    {

        public bool above;
        public bool below;

        bool isInitAbove;
        bool isInitBelow;

        this()
        {
        }

        public this(bool above, bool below)
        {
            this.above = above;
            this.below = below;
        }
    }

    public double[] start;
    public double[] end;

    public SegmentFill myFill;
    public SegmentFill otherFill;

    public this(double[] start, double[] end)
    {
        this(start, end, new SegmentFill());
    }

    public this(double[] start, double[] end, SegmentFill myFill)
    {
        this.start = start;
        this.end = end;
        this.myFill = myFill;
    }

    override string toString()
    {
        import std.format : format;

        return format("start: %s, end: %s", start, end);
    }
}

class SegmentChainer
{
    static class SegmentChainerMatch
    {
        int index;
        bool matches_head;
        bool matches_pt1;

        public this()
        {
            this(0, false, false);
        }

        public this(int index, bool matches_head, bool matches_pt1)
        {
            this.index = index;
            this.matches_head = matches_head;
            this.matches_pt1 = matches_pt1;
        }

        override string toString()
        {
            import std.format : format;

            return format("%s %s %s", index, matches_head, matches_pt1);
        }
    }

    public static double[][][] chain(Segment[] segments, Epsilon eps)
    {
        double[][][] chains;
        double[][][] regions;

        foreach (ii, Segment seg; segments)
        {

            double[] pt1 = seg.start;
            double[] pt2 = seg.end;
            if (eps.pointsSame(pt1, pt2))
            {
                writeln(
                    "PolyBool: Warning: Zero-length segment detected; your epsilon is probably too small or too large");
                return null;
            }

            //search for two chains that this segment matches
            SegmentChainerMatch first_match = new SegmentChainerMatch();
            SegmentChainerMatch second_match = new SegmentChainerMatch();

            SegmentChainerMatch[] next_match = [first_match];

            auto setMatch = (int index, bool matches_head, bool matches_pt1) {
                // return true if we've matched twice
                next_match[0].index = index;
                next_match[0].matches_head = matches_head;
                next_match[0].matches_pt1 = matches_pt1;

                if (next_match[0] == first_match)
                {
                    next_match[0] = second_match;
                    return false;
                }
                next_match[0] = null;
                return true; // we've matched twice, we're done here
            };

            for (int i = 0; i < chains.length; i++)
            {
                double[][] chain = chains[i];
                double[] head = chain[0];
                double[] tail = chain[$ - 1];

                if (eps.pointsSame(head, pt1))
                {
                    if (setMatch(i, true, true))
                        break;
                }
                else if (eps.pointsSame(head, pt2))
                {
                    if (setMatch(i, true, false))
                        break;
                }
                else if (eps.pointsSame(tail, pt1))
                {
                    if (setMatch(i, false, true))
                        break;
                }
                else if (eps.pointsSame(tail, pt2))
                {
                    if (setMatch(i, false, false))
                        break;
                }
            }

            if (next_match[0] == first_match)
            {
                double[][] newChain;
                newChain ~= pt1;
                newChain ~= pt2;

                // we didn't match anything, so create a new chain
                // import std;
                chains ~= newChain;
                continue;
            }

            if (next_match[0] == second_match)
            {
                // we matched a single chain

                // add the other point to the apporpriate end, and check to see if we've closed the
                // chain into a loop

                int index = first_match.index;
                double[] pt = first_match.matches_pt1 ? pt2 : pt1; // if we matched pt1, then we add pt2, etc
                bool addToHead = first_match.matches_head; // if we matched at head, then add to the head

                double[][] chain = chains[index];
                double[] grow = addToHead ? chain[0] : chain[$ - 1];
                double[] grow2 = addToHead ? chain[1] : chain[$ - 2];
                double[] oppo = addToHead ? chain[$ - 1] : chain[0];
                double[] oppo2 = addToHead ? chain[$ - 2] : chain[1];

                if (eps.pointsCollinear(grow2, grow, pt))
                {
                    // grow isn't needed because it's directly between grow2 and pt:
                    // grow2 ---grow---> pt
                    if (addToHead)
                    {
                        chains[index] = chain.remove(0);
                        chain = chains[index];
                    }
                    else
                    {
                        chains[index] = chain.remove(chain.length - 1);
                        chain = chains[index];
                    }
                    grow = grow2; // old grow is gone... new grow is what grow2 was
                }

                if (eps.pointsSame(oppo, pt))
                {
                    // we're closing the loop, so remove chain from chains
                    chains = chains.remove(index);

                    if (eps.pointsCollinear(oppo2, oppo, grow))
                    {
                        // oppo isn't needed because it's directly between oppo2 and grow:
                        // oppo2 ---oppo--->grow
                        if (addToHead)
                        {
                            chains[index] = chain.remove(chain.length - 1);
                            chain = chains[index];
                        }
                        else
                        {
                            chains[index] = chain.remove(0);
                            chain = chains[index];
                        }
                    }

                    // we have a closed chain!
                    regions ~= chain;
                    continue;
                }

                // not closing a loop, so just add it to the apporpriate side
                if (addToHead)
                {
                    chains[index] = [pt] ~ chain;
                    chain = chains[index];
                }
                else
                {
                    chains[index] ~= pt;
                    chain = chains[index];
                }
                continue;
            }

            // otherwise, we matched two chains, so we need to combine those chains together

            auto reverseChain = (int index) => (chains[index]).reverse;
            auto appendChain = (int index1, int index2) {
                // index1 gets index2 appended to it, and index2 is removed
                double[][] chain1 = chains[index1];
                double[][] chain2 = chains[index2];
                double[] tail = chain1[$ - 1];
                double[] tail2 = chain1[$ - 2];
                double[] head = chain2[0];
                double[] head2 = chain2[1];

                if (eps.pointsCollinear(tail2, tail, head))
                {
                    // tail isn't needed because it's directly between tail2 and head
                    // tail2 ---tail---> head
                    chains[index1] = chain1.remove(chain1.length - 1);
                    chain1 = chains[index1];
                    tail = tail2; // old tail is gone... new tail is what tail2 was
                }

                if (eps.pointsCollinear(tail, head, head2))
                {
                    // head isn't needed because it's directly between tail and head2
                    // tail ---head---> head2
                    chains[index2] = chain2.remove(0);
                    chain2 = chains[index2];
                }

                double[][] concatenated;
                concatenated ~= chain1;
                concatenated ~= chain2;
                chains[index1] = concatenated;
                //chains.set(index1, concatenated);
                chains = chains.remove(index2);
                //chains.remove((int) index2);
            };

            int F = first_match.index;
            int S = second_match.index;

            bool reverseF = chains[F].length < chains[S].length; // reverse the shorter chain, if needed
            if (first_match.matches_head)
            {
                if (second_match.matches_head)
                {
                    if (reverseF)
                    {
                        // <<<< F <<<< --- >>>> S >>>>
                        reverseChain(F);
                        // >>>> F >>>> --- >>>> S >>>>
                        appendChain(F, S);
                    }
                    else
                    {
                        // <<<< F <<<< --- >>>> S >>>>
                        reverseChain(S);
                        // <<<< F <<<< --- <<<< S <<<<   logically same as:
                        // >>>> S >>>> --- >>>> F >>>>
                        appendChain(S, F);
                    }
                }
                else
                {
                    // <<<< F <<<< --- <<<< S <<<<   logically same as:
                    // >>>> S >>>> --- >>>> F >>>>
                    appendChain(S, F);
                }
            }
            else
            {
                if (second_match.matches_head)
                {
                    // >>>> F >>>> --- >>>> S >>>>
                    appendChain(F, S);
                }
                else
                {
                    if (reverseF)
                    {
                        // >>>> F >>>> --- <<<< S <<<<
                        reverseChain(F);
                        // <<<< F <<<< --- <<<< S <<<<   logically same as:
                        // >>>> S >>>> --- >>>> F >>>>
                        appendChain(S, F);
                    }
                    else
                    {
                        // >>>> F >>>> --- <<<< S <<<<
                        reverseChain(S);
                        // >>>> F >>>> --- >>>> S >>>>
                        appendChain(F, S);
                    }
                }
            }
        }

        return regions;
    }
}

public class SegmentSelector
{
    private static Segment[] select(Segment[] segments, int[] selection)
    {

        Segment[] result;

        foreach (Segment seg; segments)
        {
            int index =
                (seg.myFill.above ? 8 : 0) +
                (seg.myFill.below ? 4 : 0) +
                ((seg.otherFill !is null && seg.otherFill.above) ? 2 : 0) +
                (
                    (seg.otherFill !is null && seg.otherFill.below) ? 1 : 0);

            if (selection[index] != 0)
            {
                // copy the segment to the results, while also calculating the fill status
                result ~= new Segment(
                    seg.start,
                    seg.end,
                    new Segment.SegmentFill(
                        selection[index] == 1,
                        selection[index] == 2
                )
                );
            }
        }

        return result;
    }

    public static Segment[] unions(Segment[] segments)
    {
        // above1 below1 above2 below2    Keep?               Value
        //    0      0      0      0   =>   no                  0
        //    0      0      0      1   =>   yes filled below    2
        //    0      0      1      0   =>   yes filled above    1
        //    0      0      1      1   =>   no                  0
        //    0      1      0      0   =>   yes filled below    2
        //    0      1      0      1   =>   yes filled below    2
        //    0      1      1      0   =>   no                  0
        //    0      1      1      1   =>   no                  0
        //    1      0      0      0   =>   yes filled above    1
        //    1      0      0      1   =>   no                  0
        //    1      0      1      0   =>   yes filled above    1
        //    1      0      1      1   =>   no                  0
        //    1      1      0      0   =>   no                  0
        //    1      1      0      1   =>   no                  0
        //    1      1      1      0   =>   no                  0
        //    1      1      1      1   =>   no                  0
        return select(segments,
            [
            0, 2, 1, 0,
            2, 2, 0, 0,
            1, 0, 1, 0,
            0, 0, 0, 0
        ]);
    }

    public static Segment[] intersect(Segment[] segments)
    {
        // above1 below1 above2 below2    Keep?               Value
        //    0      0      0      0   =>   no                  0
        //    0      0      0      1   =>   no                  0
        //    0      0      1      0   =>   no                  0
        //    0      0      1      1   =>   no                  0
        //    0      1      0      0   =>   no                  0
        //    0      1      0      1   =>   yes filled below    2
        //    0      1      1      0   =>   no                  0
        //    0      1      1      1   =>   yes filled below    2
        //    1      0      0      0   =>   no                  0
        //    1      0      0      1   =>   no                  0
        //    1      0      1      0   =>   yes filled above    1
        //    1      0      1      1   =>   yes filled above    1
        //    1      1      0      0   =>   no                  0
        //    1      1      0      1   =>   yes filled below    2
        //    1      1      1      0   =>   yes filled above    1
        //    1      1      1      1   =>   no                  0
        return select(segments,
            [
            0, 0, 0, 0,
            0, 2, 0, 2,
            0, 0, 1, 1,
            0, 2, 1, 0
        ]
        );
    }

    public static Segment[] difference(Segment[] segments)
    { // primary - secondary
        // above1 below1 above2 below2    Keep?               Value
        //    0      0      0      0   =>   no                  0
        //    0      0      0      1   =>   no                  0
        //    0      0      1      0   =>   no                  0
        //    0      0      1      1   =>   no                  0
        //    0      1      0      0   =>   yes filled below    2
        //    0      1      0      1   =>   no                  0
        //    0      1      1      0   =>   yes filled below    2
        //    0      1      1      1   =>   no                  0
        //    1      0      0      0   =>   yes filled above    1
        //    1      0      0      1   =>   yes filled above    1
        //    1      0      1      0   =>   no                  0
        //    1      0      1      1   =>   no                  0
        //    1      1      0      0   =>   no                  0
        //    1      1      0      1   =>   yes filled above    1
        //    1      1      1      0   =>   yes filled below    2
        //    1      1      1      1   =>   no                  0
        return select(segments,
            [
            0, 0, 0, 0,
            2, 0, 2, 0,
            1, 1, 0, 0,
            0, 1, 2, 0
        ]
        );
    }

    public static Segment[] differenceRev(Segment[] segments)
    { // secondary - primary
        // above1 below1 above2 below2    Keep?               Value
        //    0      0      0      0   =>   no                  0
        //    0      0      0      1   =>   yes filled below    2
        //    0      0      1      0   =>   yes filled above    1
        //    0      0      1      1   =>   no                  0
        //    0      1      0      0   =>   no                  0
        //    0      1      0      1   =>   no                  0
        //    0      1      1      0   =>   yes filled above    1
        //    0      1      1      1   =>   yes filled above    1
        //    1      0      0      0   =>   no                  0
        //    1      0      0      1   =>   yes filled below    2
        //    1      0      1      0   =>   no                  0
        //    1      0      1      1   =>   yes filled below    2
        //    1      1      0      0   =>   no                  0
        //    1      1      0      1   =>   no                  0
        //    1      1      1      0   =>   no                  0
        //    1      1      1      1   =>   no                  0
        return select(segments,
            [
            0, 2, 1, 0,
            0, 0, 1, 1,
            0, 2, 0, 2,
            0, 0, 0, 0
        ]);
    }

    public static Segment[] xor(Segment[] segments)
    { // primary ^ secondary
        // above1 below1 above2 below2    Keep?               Value
        //    0      0      0      0   =>   no                  0
        //    0      0      0      1   =>   yes filled below    2
        //    0      0      1      0   =>   yes filled above    1
        //    0      0      1      1   =>   no                  0
        //    0      1      0      0   =>   yes filled below    2
        //    0      1      0      1   =>   no                  0
        //    0      1      1      0   =>   no                  0
        //    0      1      1      1   =>   yes filled above    1
        //    1      0      0      0   =>   yes filled above    1
        //    1      0      0      1   =>   no                  0
        //    1      0      1      0   =>   no                  0
        //    1      0      1      1   =>   yes filled below    2
        //    1      1      0      0   =>   no                  0
        //    1      1      0      1   =>   yes filled above    1
        //    1      1      1      0   =>   yes filled below    2
        //    1      1      1      1   =>   no                  0
        return select(segments,
            [
            0, 2, 1, 0,
            2, 0, 0, 1,
            1, 0, 0, 2,
            0, 1, 2, 0
        ]);
    }

}
