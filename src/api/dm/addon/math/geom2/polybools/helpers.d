module api.dm.addon.math.geom2.polybools.helpers;

/*
 * Authors: initkfs
 */

import Math = api.math;

/*
 * D port of https://github.com/Menecats/polybool-java
 * Copyright (c) 2021 Davide Menegatti (@menecats)
 * under MIT License: https://github.com/Menecats/polybool-java/blob/main/LICENSE
 */
static class TransitionResult(T)
{
    LinkedList!T before;
    LinkedList!T after;
    LinkedList!T delegate(LinkedList!T) insert;

    this(LinkedList!T before,
        LinkedList!T after,
        LinkedList!T delegate(LinkedList!T) insert)
    {
        this.before = before;
        this.after = after;
        this.insert = insert;
    }
}

class LinkedList(T)
{
    static LinkedList!T create()
    {
        return new LinkedList!T(true, null);
    }

    static LinkedList!T node(T content)
    {
        return new LinkedList!T(false, content);
    }

    private LinkedList!T prev;
    private LinkedList!T next;

    private T content;
    private bool root;

    private this(bool root, T content)
    {
        this.root = root;
        this.content = content;
    }

    bool exists(LinkedList!T node)
    {
        return node !is null && node != this;
    }

    bool isEmpty()
    {
        return this.next is null;
    }

    LinkedList!T getHead()
    {
        return this.next;
    }

    LinkedList!T getPrev()
    {
        return prev;
    }

    LinkedList!T getNext()
    {
        return next;
    }

    void insertBefore(LinkedList!T node, bool delegate(LinkedList!T) check)
    {
        LinkedList!T last = this;
        LinkedList!T here = this.next;

        while (here !is null && !here.root)
        {
            if (check(here))
            {
                node.prev = here.prev;
                node.next = here;
                if (here.prev !is null)
                    here.prev.next = node;
                here.prev = node;
                return;
            }
            last = here;
            here = here.next;
        }

        last.next = node;
        node.prev = last;
        node.next = null;
    }

    TransitionResult!T findTransition(bool delegate(LinkedList!T) check)
    {
        LinkedList!T prev = this;
        LinkedList!T here = this.next;

        while (here !is null)
        {
            if (check(here))
                break;

            prev = here;
            here = here.next;
        }

        LinkedList!T Prev = prev;
        LinkedList!T Here = here;

        return new TransitionResult!T(
            prev == this
                ? null : prev,
            here,
            (LinkedList!T node) {
            node.prev = Prev;
            node.next = Here;
            Prev.next = node;
            if (Here !is null)
                Here.prev = node;

            return node;
        }
        );
    }

    void remove()
    {
        if (this.root)
            return;

        if (this.prev !is null)
            this.prev.next = this.next;
        if (this.next !is null)
            this.next.prev = this.prev;

        this.prev = null;
        this.next = null;
    }

    T getContent()
    {
        return content;
    }
}

class Epsilon
{

    static class EpsilonIntersectionResult
    {
        int alongA;
        int alongB;
        float[] pt;
    }

    protected float eps = 0;

    this()
    {
        this(1e-10);
    }

    this(float eps)
    {
        this.eps = eps;
    }

    float epsilon(float eps)
    {
        return (this.eps = Math.abs(eps));
    }

    bool pointAboveOrOnLine(float[] pt, float[] left, float[] right)
    {
        float Ax = left[0];
        float Ay = left[1];
        float Bx = right[0];
        float By = right[1];
        float Cx = pt[0];
        float Cy = pt[1];

        return (Bx - Ax) * (Cy - Ay) - (By - Ay) * (Cx - Ax) >= -this.eps;
    }

    bool pointBetween(float[] p, float[] left, float[] right)
    {
        // p must be collinear with left->right
        // returns false if p == left, p == right, or left == right
        float d_py_ly = p[1] - left[1];
        float d_rx_lx = right[0] - left[0];
        float d_px_lx = p[0] - left[0];
        float d_ry_ly = right[1] - left[1];

        float dot = d_px_lx * d_rx_lx + d_py_ly * d_ry_ly;
        // if `dot` is 0, then `p` == `left` or `left` == `right` (reject)
        // if `dot` is less than 0, then `p` is to the left of `left` (reject)
        if (dot < this.eps)
            return false;

        float sqlen = d_rx_lx * d_rx_lx + d_ry_ly * d_ry_ly;
        // if `dot` > `sqlen`, then `p` is to the right of `right` (reject)
        // therefore, if `dot - sqlen` is greater than 0, then `p` is to the right of `right` (reject)
        return !(dot - sqlen > -this.eps);
    }

    bool pointsSameX(float[] p1, float[] p2)
    {
        return Math.abs(p1[0] - p2[0]) < this.eps;
    }

    bool pointsSameY(float[] p1, float[] p2)
    {
        return Math.abs(p1[1] - p2[1]) < this.eps;
    }

    bool pointsSame(float[] p1, float[] p2)
    {
        return this.pointsSameX(p1, p2) && this.pointsSameY(p1, p2);
    }

    int pointsCompare(float[] p1, float[] p2)
    {
        // returns -1 if p1 is smaller, 1 if p2 is smaller, 0 if equal
        if (this.pointsSameX(p1, p2))
            return this.pointsSameY(p1, p2) ? 0 : (p1[1] < p2[1] ? -1 : 1);
        return p1[0] < p2[0] ? -1 : 1;
    }

    bool pointsCollinear(float[] pt1, float[] pt2, float[] pt3)
    {
        // does pt1->pt2->pt3 make a straight line?
        // essentially this is just checking to see if the slope(pt1->pt2) === slope(pt2->pt3)
        // if slopes are equal, then they must be collinear, because they share pt2
        float dx1 = pt1[0] - pt2[0];
        float dy1 = pt1[1] - pt2[1];
        float dx2 = pt2[0] - pt3[0];
        float dy2 = pt2[1] - pt3[1];
        return Math.abs(dx1 * dy2 - dx2 * dy1) < this.eps;
    }

    EpsilonIntersectionResult linesIntersect(float[] a0, float[] a1, float[] b0, float[] b1)
    {
        // returns false if the lines are coincident (e.g., parallel or on top of each other)
        //
        // returns an object if the lines intersect:
        //   {
        //     pt: [x, y],    where the intersection point is at
        //     alongA: where intersection point is along A,
        //     alongB: where intersection point is along B
        //   }
        //
        //  alongA and alongB will each be one of: -2, -1, 0, 1, 2
        //
        //  with the following meaning:
        //
        //    -2   intersection point is before segment's first point
        //    -1   intersection point is directly on segment's first point
        //     0   intersection point is between segment's first and second points (exclusive)
        //     1   intersection point is directly on segment's second point
        //     2   intersection point is after segment's second point
        float adx = a1[0] - a0[0];
        float ady = a1[1] - a0[1];
        float bdx = b1[0] - b0[0];
        float bdy = b1[1] - b0[1];

        float axb = adx * bdy - ady * bdx;
        if (Math.abs(axb) < this.eps)
            return null; // lines are coincident

        float dx = a0[0] - b0[0];
        float dy = a0[1] - b0[1];

        float A = (bdx * dy - bdy * dx) / axb;
        float B = (adx * dy - ady * dx) / axb;

        EpsilonIntersectionResult ret = new EpsilonIntersectionResult();
        ret.pt = [a0[0] + A * adx, a0[1] + A * ady];

        // categorize where intersection point is along A and B

        if (A <= -this.eps)
            ret.alongA = -2;
        else if (A < this.eps)
            ret.alongA = -1;
        else if (A - 1 <= -this.eps)
            ret.alongA = 0;
        else if (A - 1 < this.eps)
            ret.alongA = 1;
        else
            ret.alongA = 2;

        if (B <= -this.eps)
            ret.alongB = -2;
        else if (B < this.eps)
            ret.alongB = -1;
        else if (B - 1 <= -this.eps)
            ret.alongB = 0;
        else if (B - 1 < this.eps)
            ret.alongB = 1;
        else
            ret.alongB = 2;

        return ret;
    }

    bool pointInsideRegion(float[] pt, float[][] region)
    {
        float x = pt[0];
        float y = pt[1];
        float last_x = region[$ - 1][0];
        float last_y = region[$ - 1][1];
        bool inside = false;
        foreach (float[] regionPt; region)
        {
            float curr_x = regionPt[0];
            float curr_y = regionPt[1];

            // if y is between curr_y and last_y, and
            // x is to the right of the boundary created by the line
            if ((curr_y - y > this.eps) != (last_y - y > this.eps) && (last_x - curr_x) * (
                    y - curr_y) / (last_y - curr_y) + curr_x - x > this.eps)
                inside = !inside;

            last_x = curr_x;
            last_y = curr_y;
        }
        return inside;
    }
}
