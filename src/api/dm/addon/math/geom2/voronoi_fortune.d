module api.dm.addon.math.geom2.voronoi_fortune;

/*
* Port from source code by Steven Fortune (http://ect.bell-labs.com/who/sjf/) 
* and Bram Stolk (https://github.com/stolk/forvor) 
* under Public Domain license
*/

//TODO Global refactoring

import Math = api.math;

import api.math.geom2;

enum NULL = 0;
enum DELETED = -2;

enum le = 0;
enum re = 1;

struct Freenode
{
    Freenode* nextfree;
}

struct Freelist
{
    Freenode* head;
    int nodesize;
}

struct Point
{
    float x = 0;
    float y = 0;
}

/* structure used both for sites and for vertices */

struct SiteVertex
{
    Point coord;
    int sitenbr;
    int refcnt;
}

struct Edge
{
    float a = 0, b = 0, c = 0;
    SiteVertex*[2] ep;
    SiteVertex*[2] reg;
    int edgenbr;
}

struct Halfedge
{
    Halfedge* elLeft;
    Halfedge* ELright;
    Edge* ELedge;
    int ELrefcnt;
    char ELpm = 0;
    SiteVertex* vertex;
    float ystar = 0;
    Halfedge* PQnext;
}

struct VoronoiFortune
{
    static void delegate(Line2d) onLine;
    static void delegate(Point) onVertex;

    /* edgelist.c */
    static
    {
        int ELhashsize;
        SiteVertex* bottomsite;
        Freelist hfl;
        Halfedge* elLeftend, elEightEnd;
        Halfedge** elHash;

        /* geometry.c */
        float deltax = 0, deltay = 0;
        //int nsites, nedges, sqrtNsites, nvertices;
        int nedges, sqrtNsites, nvertices;
        //Freelist sfl, efl;
        Freelist efl;

        /* heap.c */
        int pqmin, pqcount, pqhashsize;
        Halfedge* pqhash;

        /* main.c */
        int sorted, triangulate, plot, isDebug, nsites, siteidx;
        float xmin = 0, xmax = 0, ymin = 0, ymax = 0;
        SiteVertex* sites;
        Freelist sfl;

        enum MAXALLOCS = 128;
        private void*[MAXALLOCS] allocations;
        private int numallocs = 0;

        static int totalAlloc;
    }

    /*** MEMORY.C ***/

    import core.stdc.stdio;
    import core.stdc.stdlib; /* malloc(), exit() */
    import core.stdc.assert_;

    static void freeinit(Freelist* fl, int size)
    {
        fl.head = null;
        fl.nodesize = size;
    }

    static void freeexit()
    {
        foreach (i; 0 .. numallocs)
        {
            free(allocations[i]);
            allocations[i] = null;
        }
        numallocs = 0;
    }

    static char* getfree(Freelist* fl)
    {
        int i = void;
        Freenode* t = void;
        if (!fl.head)
        {
            t = cast(Freenode*) myalloc(nsites * fl.nodesize);
            for (i = 0; i < nsites; i++)
            {
                makefree(cast(Freenode*)(cast(char*) t + i * fl.nodesize), fl);
            }
        }

        t = fl.head;

        fl.head = (fl.head).nextfree;

        return (cast(char*) t);
    }

    static void makefree(Freenode* curr, Freelist* fl)
    {
        curr.nextfree = fl.head;
        fl.head = curr;
    }

    static char* myalloc(ulong n) => myalloc(cast(uint) n);
   
    static char* myalloc(uint n)
    {
        char* t = void;
        assert(numallocs < MAXALLOCS);
        if ((t = cast(char*) malloc(n)) == cast(char*) 0)
        {
            import std.format: format;
            throw new Exception(format("Insufficient memory processing site %d (%d bytes in use)\n",siteidx, totalAlloc));
        }

        totalAlloc += n;
        allocations[numallocs++] = cast(void*) t;
        return (t);
    }

    /*** HEAP.C ***/
    static void PQinsert(Halfedge* he, SiteVertex* v, float offset)
    {
        Halfedge* last, next;

        he.vertex = v;
        ref_(v);
        he.ystar = v.coord.y + offset;
        last = &pqhash[PQbucket(he)];
        while ((next = last.PQnext) != cast(Halfedge*) null &&
            (he.ystar > next.ystar ||
                (he.ystar == next.ystar &&
                v.coord.x > next.vertex.coord.x)))
        {
            last = next;
        }
        he.PQnext = last.PQnext;
        last.PQnext = he;
        pqcount++;
    }

    static void PQdelete(Halfedge* he)
    {
        Halfedge* last;

        if (he.vertex)
        {
            last = &pqhash[PQbucket(he)];
            while (last.PQnext != he)
            {
                last = last.PQnext;
            }
            last.PQnext = he.PQnext;
            pqcount--;
            deref(he.vertex);
            he.vertex = cast(SiteVertex*) null;
        }
    }

    static int PQbucket(Halfedge* he)
    {
        int bucket;

        if (he.ystar < ymin)
            bucket = 0;
        else if (he.ystar >= ymax)
            bucket = pqhashsize - 1;
        else
            bucket = cast(int)((he.ystar - ymin) / deltay * pqhashsize);
        if (bucket < 0)
        {
            bucket = 0;
        }
        if (bucket >= pqhashsize)
        {
            bucket = pqhashsize - 1;
        }
        if (bucket < pqmin)
        {
            pqmin = bucket;
        }
        return (bucket);
    }

    static int PQempty() => (pqcount == 0);

    static Point PQ_min()
    {
        Point answer;

        while (!pqhash[pqmin].PQnext)
        {
            ++pqmin;
        }
        answer.x = pqhash[pqmin].PQnext.vertex.coord.x;
        answer.y = pqhash[pqmin].PQnext.ystar;
        return (answer);
    }

    static Halfedge* PQextractmin()
    {
        Halfedge* curr = void;

        curr = pqhash[pqmin].PQnext;
        pqhash[pqmin].PQnext = curr.PQnext;
        pqcount--;
        return (curr);
    }

    static void PQinitialize()
    {
        int i;

        pqcount = pqmin = 0;
        pqhashsize = 4 * sqrtNsites;
        pqhash = cast(Halfedge*) myalloc(pqhashsize * (*pqhash).sizeof);
        for (i = 0; i < pqhashsize; i++)
        {
            pqhash[i].PQnext = cast(Halfedge*) null;
        }
    }

    /*** EDGELIST.C ***/
    static int ntry, totalsearch;

    static void ELinitialize()
    {
        int i;

        freeinit(&hfl, Halfedge.sizeof);
        ELhashsize = 2 * sqrtNsites;
        elHash = cast(Halfedge**) myalloc((*elHash).sizeof * ELhashsize);
        for (i = 0; i < ELhashsize; i++)
        {
            elHash[i] = cast(Halfedge*) null;
        }
        elLeftend = HEcreate(cast(Edge*) null, 0);
        elEightEnd = HEcreate(cast(Edge*) null, 0);
        elLeftend.elLeft = cast(Halfedge*) null;
        elLeftend.ELright = elEightEnd;
        elEightEnd.elLeft = elLeftend;
        elEightEnd.ELright = cast(Halfedge*) null;
        elHash[0] = elLeftend;
        elHash[ELhashsize - 1] = elEightEnd;
    }

    static Halfedge* HEcreate(Edge* e, int pm)
    {
        Halfedge* answer;

        answer = cast(Halfedge*) getfree(&hfl);
        answer.ELedge = e;
        answer.ELpm = cast(char) pm;
        answer.PQnext = null;
        answer.vertex = null;
        answer.ELrefcnt = 0;
        return (answer);
    }

    static void ELinsert(Halfedge* lb, Halfedge* new_)
    {
        new_.elLeft = lb;
        new_.ELright = lb.ELright;
        (lb.ELright).elLeft = new_;
        lb.ELright = new_;
    }

    /* Get entry from hash table, pruning any deleted nodes */

    static Halfedge* ELgethash(int b)
    {
        Halfedge* he;

        if ((b < 0) || (b >= ELhashsize))
        {
            return null;
        }
        he = elHash[b];
        if ((he is null) || (he.ELedge != cast(Edge*) DELETED))
        {
            return (he);
        }
        /* Hash table points to deleted half edge.  Patch as necessary. */
        elHash[b] = null;
        if ((--(he.ELrefcnt)) == 0)
        {
            makefree(cast(Freenode*) he, cast(Freelist*)&hfl);
        }
        return null;
    }

    static Halfedge* elLeftbnd(Point* p)
    {
        int i, bucket;
        Halfedge* he;

        /* Use hash table to get close to desired halfedge */
        bucket = cast(int)((p.x - xmin) / deltax * ELhashsize);
        if (bucket < 0)
        {
            bucket = 0;
        }
        if (bucket >= ELhashsize)
        {
            bucket = ELhashsize - 1;
        }
        he = ELgethash(bucket);
        if (he == cast(Halfedge*) null)
        {
            for (i = 1; 1; i++)
            {
                if ((he = ELgethash(bucket - i)) != cast(Halfedge*) null)
                {
                    break;
                }
                if ((he = ELgethash(bucket + i)) != cast(Halfedge*) null)
                {
                    break;
                }
            }
            totalsearch += i;
        }
        ntry++;
        /* Now search linear list of halfedges for the corect one */
        if (he == elLeftend || (he != elEightEnd && right_of(he, p)))
        {
            do
            {
                he = he.ELright;
            }
            while (he != elEightEnd && right_of(he, p));
            he = he.elLeft;
        }
        else
        {
            do
            {
                he = he.elLeft;
            }
            while (he != elLeftend && !right_of(he, p));
        }
        /*** Update hash table and reference counts ***/
        if ((bucket > 0) && (bucket < ELhashsize - 1))
        {
            if (elHash[bucket] != cast(Halfedge*) null)
            {
                (elHash[bucket].ELrefcnt)--;
            }
            elHash[bucket] = he;
            (elHash[bucket].ELrefcnt)++;
        }
        return (he);
    }

    /*** This delete routine can't reclaim node, since pointers from hash
 : table may be present.
 ***/

    static void ELdelete(Halfedge* he)
    {
        (he.elLeft).ELright = he.ELright;
        (he.ELright).elLeft = he.elLeft;
        he.ELedge = cast(Edge*) DELETED;
    }

    static Halfedge* ELright(Halfedge* he)
    {
        return (he.ELright);
    }

    static Halfedge* elLeft(Halfedge* he)
    {
        return (he.elLeft);
    }

    static SiteVertex* leftreg(Halfedge* he)
    {
        if (he.ELedge == cast(Edge*) null)
        {
            return (bottomsite);
        }
        return (he.ELpm == le ? he.ELedge.reg[le] : he.ELedge.reg[re]);
    }

    static SiteVertex* rightreg(Halfedge* he)
    {
        if (he.ELedge == cast(Edge*) null)
        {
            return (bottomsite);
        }
        return (he.ELpm == le ? he.ELedge.reg[re] : he.ELedge.reg[le]);
    }

    /*** VORONOI.C ***/

    /*** implicit parameters: nsites, sqrtNsites, xmin, xmax, ymin, ymax,
 : deltax, deltay (can all be estimates).
 : Performance suffers if they are wrong; better to make nsites,
 : deltax, and deltay too big than too small.  (?)
 ***/

    static void voronoi(SiteVertex* function() nextsite)
    {
        SiteVertex* newsite, bot, top, temp, p, v;
        Point newintstar;
        int pm;
        Halfedge* lbnd, rbnd, llbnd, rrbnd, bisector;
        Edge* e;

        PQinitialize();
        bottomsite = (*nextsite)();
        out_site(bottomsite);
        ELinitialize();
        newsite = (*nextsite)();
        while (1)
        {
            if (!PQempty())
            {
                newintstar = PQ_min();
            }
            if (newsite != cast(SiteVertex*) null && (PQempty()
                    || newsite.coord.y < newintstar.y
                    || (newsite.coord.y == newintstar.y
                    && newsite.coord.x < newintstar.x)))
            { /* new site is smallest */
                {
                    out_site(newsite);
                }
                lbnd = elLeftbnd(&(newsite.coord));
                rbnd = ELright(lbnd);
                bot = rightreg(lbnd);
                e = bisect(bot, newsite);
                bisector = HEcreate(e, le);
                ELinsert(lbnd, bisector);
                p = intersect(lbnd, bisector);
                if (p != cast(SiteVertex*) null)
                {
                    PQdelete(lbnd);
                    PQinsert(lbnd, p, dist(p, newsite));
                }
                lbnd = bisector;
                bisector = HEcreate(e, re);
                ELinsert(lbnd, bisector);
                p = intersect(bisector, rbnd);
                if (p != cast(SiteVertex*) null)
                {
                    PQinsert(bisector, p, dist(p, newsite));
                }
                newsite = (*nextsite)();
            }
            else if (!PQempty()) /* intersection is smallest */
            {
                lbnd = PQextractmin();
                llbnd = elLeft(lbnd);
                rbnd = ELright(lbnd);
                rrbnd = ELright(rbnd);
                bot = leftreg(lbnd);
                top = rightreg(rbnd);
                out_triple(bot, top, rightreg(lbnd));
                v = lbnd.vertex;
                makevertex(v);
                endpoint(lbnd.ELedge, lbnd.ELpm, v);
                endpoint(rbnd.ELedge, rbnd.ELpm, v);
                ELdelete(lbnd);
                PQdelete(rbnd);
                ELdelete(rbnd);
                pm = le;
                if (bot.coord.y > top.coord.y)
                {
                    temp = bot;
                    bot = top;
                    top = temp;
                    pm = re;
                }
                e = bisect(bot, top);
                bisector = HEcreate(e, pm);
                ELinsert(llbnd, bisector);
                endpoint(e, re - pm, v);
                deref(v);
                p = intersect(llbnd, bisector);
                if (p != cast(SiteVertex*) null)
                {
                    PQdelete(llbnd);
                    PQinsert(llbnd, p, dist(p, bot));
                }
                p = intersect(bisector, rrbnd);
                if (p != cast(SiteVertex*) null)
                {
                    PQinsert(bisector, p, dist(p, bot));
                }
            }
            else
            {
                break;
            }
        }

        for (lbnd = ELright(elLeftend); lbnd != elEightEnd; lbnd = ELright(lbnd))
        {
            e = lbnd.ELedge;
            out_ep(e);
        }
    }

    /*** GEOMETRY.C ***/

    import core.stdc.math;

    static void geominit()
    {
        freeinit(&efl, Edge.sizeof);
        nvertices = nedges = 0;
        sqrtNsites = cast(int) Math.sqrt(nsites + 4);
        deltay = ymax - ymin;
        deltax = xmax - xmin;
    }

    static void geomexit()
    {
        freeexit();
    }

    static Edge* bisect(SiteVertex* s1, SiteVertex* s2)
    {
        float dx = 0, dy = 0, adx = 0, ady = 0;
        Edge* newedge;

        newedge = cast(Edge*) getfree(&efl);
        newedge.reg[0] = s1;
        newedge.reg[1] = s2;
        ref_(s1);
        ref_(s2);
        newedge.ep[0] = newedge.ep[1] = null;
        dx = s2.coord.x - s1.coord.x;
        dy = s2.coord.y - s1.coord.y;
        adx = dx > 0 ? dx : -dx;
        ady = dy > 0 ? dy : -dy;
        newedge.c = s1.coord.x * dx + s1.coord.y * dy + (dx * dx +
                dy * dy) * 0.5;
        if (adx > ady)
        {
            newedge.a = 1.0;
            newedge.b = dy / dx;
            newedge.c /= dx;
        }
        else
        {
            newedge.b = 1.0;
            newedge.a = dx / dy;
            newedge.c /= dy;
        }
        newedge.edgenbr = nedges;
        out_bisector(newedge);
        nedges++;
        return (newedge);
    }

    static SiteVertex* intersect(Halfedge* el1, Halfedge* el2)
    {
        Edge* e1, e2, e;
        Halfedge* el;
        float d = 0, xint = 0, yint = 0;
        int right_of_site;
        SiteVertex* v;

        e1 = el1.ELedge;
        e2 = el2.ELedge;
        if ((e1 == cast(Edge*) null) || (e2 == cast(Edge*) null))
        {
            return (cast(SiteVertex*) null);
        }
        if (e1.reg[1] == e2.reg[1])
        {
            return (cast(SiteVertex*) null);
        }
        d = (e1.a * e2.b) - (e1.b * e2.a);
        if ((-1.0e-10 < d) && (d < 1.0e-10))
        {
            return (cast(SiteVertex*) null);
        }
        xint = (e1.c * e2.b - e2.c * e1.b) / d;
        yint = (e2.c * e1.a - e1.c * e2.a) / d;
        if ((e1.reg[1].coord.y < e2.reg[1].coord.y) ||
            (e1.reg[1].coord.y == e2.reg[1].coord.y &&
                e1.reg[1].coord.x < e2.reg[1].coord.x))
        {
            el = el1;
            e = e1;
        }
        else
        {
            el = el2;
            e = e2;
        }
        right_of_site = (xint >= e.reg[1].coord.x);
        if ((right_of_site && (el.ELpm == le)) ||
            (!right_of_site && (el.ELpm == re)))
        {
            return (cast(SiteVertex*) null);
        }
        v = cast(SiteVertex*) getfree(&sfl);
        v.refcnt = 0;
        v.coord.x = xint;
        v.coord.y = yint;
        return (v);
    }

    /*** returns 1 if p is to right of halfedge e ***/

    static int right_of(Halfedge* el, Point* p)
    {
        Edge* e = void;
        SiteVertex* topsite = void;
        int right_of_site = void, above = void, fast = void;
        float dxp = void, dyp = void, dxs = void, t1 = void, t2 = void, t3 = void, yl = void;

        e = el.ELedge;
        topsite = e.reg[1];
        right_of_site = (p.x > topsite.coord.x);
        if (right_of_site && (el.ELpm == le))
        {
            return (1);
        }
        if (!right_of_site && (el.ELpm == re))
        {
            return (0);
        }
        if (e.a == 1.0)
        {
            dyp = p.y - topsite.coord.y;
            dxp = p.x - topsite.coord.x;
            fast = 0;
            if ((!right_of_site & (e.b < 0.0)) ||
                (right_of_site & (e.b >= 0.0)))
            {
                fast = above = (dyp >= e.b * dxp);
            }
            else
            {
                above = ((p.x + p.y * e.b) > (e.c));
                if (e.b < 0.0)
                {
                    above = !above;
                }
                if (!above)
                {
                    fast = 1;
                }
            }
            if (!fast)
            {
                dxs = topsite.coord.x - (e.reg[0]).coord.x;
                above = (e.b * (dxp * dxp - dyp * dyp))
                    <
                    (dxs * dyp * (1.0 + 2.0 * dxp /
                            dxs + e.b * e.b));
                if (e.b < 0.0)
                {
                    above = !above;
                }
            }
        }
        else /*** e->b == 1.0 ***/
        {
            yl = e.c - e.a * p.x;
            t1 = p.y - yl;
            t2 = p.x - topsite.coord.x;
            t3 = yl - topsite.coord.y;
            above = ((t1 * t1) > ((t2 * t2) + (t3 * t3)));
        }
        return (el.ELpm == le ? above : !above);
    }

    static void endpoint(Edge* e, int lr, SiteVertex* s)
    {
        e.ep[lr] = s;
        ref_(s);
        if (e.ep[re - lr] == cast(SiteVertex*) null)
        {
            return;
        }
        out_ep(e);
        deref(e.reg[le]);
        deref(e.reg[re]);
        makefree(cast(Freenode*) e, cast(Freelist*)&efl);
    }

    static float dist(SiteVertex* s, SiteVertex* t)
    {
        float dx = void, dy = void;

        dx = s.coord.x - t.coord.x;
        dy = s.coord.y - t.coord.y;
        return (sqrt(dx * dx + dy * dy));
    }

    static void makevertex(SiteVertex* v)
    {
        v.sitenbr = nvertices++;
        out_vertex(v);
    }

    static void deref(SiteVertex* v)
    {
        if (--(v.refcnt) == 0)
        {
            makefree(cast(Freenode*) v, cast(Freelist*)&sfl);
        }
    }

    static void ref_(SiteVertex* v)
    {
        ++(v.refcnt);
    }

    /*** OUTPUT.C ***/

    import core.stdc.stdio;

    static float pxmin = 0, pxmax = 0, pymin = 0, pymax = 0, cradius = 0;

    static void openpl()
    {
    }

    static void line(float ax, float ay, float bx, float by)
    {
        import api.math.geom2.line2 : Line2d;

        if (onLine)
        {
            onLine(Line2d(ax, ay, bx, by));
        }
    }

    static void circle(float ax, float ay, float radius)
    {
        if(onVertex){
            onVertex(Point(ax, ay));
        }
    }

    static void range(float pxmin, float pxmax, float pymin, float pymax)
    {
    }

    static void out_bisector(Edge* e)
    {
        if (triangulate && plot)
        {
            line(e.reg[0].coord.x, e.reg[0].coord.y,
                e.reg[1].coord.x, e.reg[1].coord.y);
        }
        if (!triangulate && !plot && !isDebug)
        {
            printf("l %f %f %f %d %d\n", e.a, e.b, e.c, e.reg[le].sitenbr, e.reg[re].sitenbr);
        }
        if (isDebug)
        {
            printf("line(%d) %gx+%gy=%g, bisecting %d %d\n", e.edgenbr,
                e.a, e.b, e.c, e.reg[le].sitenbr, e.reg[re].sitenbr);
        }
    }

    static void out_ep(Edge* e)
    {
        if (!triangulate && plot)
        {
            clip_line(e);
        }
        if (!triangulate && !plot)
        {
            printf("e %d", e.edgenbr);
            printf(" %d ", e.ep[le] != cast(SiteVertex*) null ? e.ep[le].sitenbr : -1);
            printf("%d\n", e.ep[re] != cast(SiteVertex*) null ? e.ep[re].sitenbr : -1);
        }
    }

    static void out_vertex(SiteVertex* v)
    {
        if (!triangulate && !plot && !isDebug)
        {
            printf("v %f %f\n", v.coord.x, v.coord.y);
        }
        if (isDebug)
        {
            printf("vertex(%d) at %f %f\n", v.sitenbr, v.coord.x, v.coord.y);
        }
    }

    import api.math.geom2;

    static void out_site(SiteVertex* s)
    {
        if (!triangulate && plot && !isDebug)
        {
            circle(s.coord.x, s.coord.y, cradius);
        }
        if (!triangulate && !plot && !isDebug)
        {
            printf("s %f %f\n", s.coord.x, s.coord.y);
        }
        if (isDebug)
        {
            printf("site (%d) at %f %f\n", s.sitenbr, s.coord.x, s.coord.y);
        }
    }

    static void out_triple(SiteVertex* s1, SiteVertex* s2, SiteVertex* s3)
    {
        if (triangulate && !plot && !isDebug)
        {
            printf("%d %d %d\n", s1.sitenbr, s2.sitenbr, s3.sitenbr);
        }
        if (isDebug)
        {
            printf("circle through left=%d right=%d bottom=%d\n",
                s1.sitenbr, s2.sitenbr, s3.sitenbr);
        }
    }

    static void plotinit()
    {
        float dx = void, dy = void, d = void;

        dy = ymax - ymin;
        dx = xmax - xmin;
        d = (dx > dy ? dx : dy) * 1.1;
        pxmin = xmin - (d - dx) / 2.0;
        pxmax = xmax + (d - dx) / 2.0;
        pymin = ymin - (d - dy) / 2.0;
        pymax = ymax + (d - dy) / 2.0;
        cradius = (pxmax - pxmin) / 350.0;
        openpl();
        range(pxmin, pymin, pxmax, pymax);
    }

    static void clip_line(Edge* e)
    {
        SiteVertex* s1 = void, s2 = void;
        float x1 = void, x2 = void, y1 = void, y2 = void;

        if (e.a == 1.0 && e.b >= 0.0)
        {
            s1 = e.ep[1];
            s2 = e.ep[0];
        }
        else
        {
            s1 = e.ep[0];
            s2 = e.ep[1];
        }
        if (e.a == 1.0)
        {
            y1 = pymin;
            if (s1 != cast(SiteVertex*) null && s1.coord.y > pymin)
            {
                y1 = s1.coord.y;
            }
            if (y1 > pymax)
            {
                return;
            }
            x1 = e.c - e.b * y1;
            y2 = pymax;
            if (s2 != cast(SiteVertex*) null && s2.coord.y < pymax)
            {
                y2 = s2.coord.y;
            }
            if (y2 < pymin)
            {
                return;
            }
            x2 = e.c - e.b * y2;
            if (((x1 > pxmax) && (x2 > pxmax)) || ((x1 < pxmin) && (x2 < pxmin)))
            {
                return;
            }
            if (x1 > pxmax)
            {
                x1 = pxmax;
                y1 = (e.c - x1) / e.b;
            }
            if (x1 < pxmin)
            {
                x1 = pxmin;
                y1 = (e.c - x1) / e.b;
            }
            if (x2 > pxmax)
            {
                x2 = pxmax;
                y2 = (e.c - x2) / e.b;
            }
            if (x2 < pxmin)
            {
                x2 = pxmin;
                y2 = (e.c - x2) / e.b;
            }
        }
        else
        {
            x1 = pxmin;
            if (s1 != cast(SiteVertex*) null && s1.coord.x > pxmin)
            {
                x1 = s1.coord.x;
            }
            if (x1 > pxmax)
            {
                return;
            }
            y1 = e.c - e.a * x1;
            x2 = pxmax;
            if (s2 != cast(SiteVertex*) null && s2.coord.x < pxmax)
            {
                x2 = s2.coord.x;
            }
            if (x2 < pxmin)
            {
                return;
            }
            y2 = e.c - e.a * x2;
            if (((y1 > pymax) && (y2 > pymax)) || ((y1 < pymin) && (y2 < pymin)))
            {
                return;
            }
            if (y1 > pymax)
            {
                y1 = pymax;
                x1 = (e.c - y1) / e.a;
            }
            if (y1 < pymin)
            {
                y1 = pymin;
                x1 = (e.c - y1) / e.a;
            }
            if (y2 > pymax)
            {
                y2 = pymax;
                x2 = (e.c - y2) / e.a;
            }
            if (y2 < pymin)
            {
                y2 = pymin;
                x2 = (e.c - y2) / e.a;
            }
        }
        line(x1, y1, x2, y2);
    }

    static extern (C) int scomp(const(void)* vs1, const(void)* vs2)
    {
        Point* s1 = cast(Point*) vs1;
        Point* s2 = cast(Point*) vs2;

        if (s1.y < s2.y)
        {
            return (-1);
        }
        if (s1.y > s2.y)
        {
            return (1);
        }
        if (s1.x < s2.x)
        {
            return (-1);
        }
        if (s1.x > s2.x)
        {
            return (1);
        }
        return (0);
    }

    static SiteVertex* nextone()
    {
        SiteVertex* s = void;

        if (siteidx < nsites)
        {
            s = &sites[siteidx++];
            return (s);
        }
        else
        {
            return (cast(SiteVertex*) null);
        }
    }

    static SiteVertex* readone()
    {
        SiteVertex* s = void;

        s = cast(SiteVertex*) getfree(&sfl);
        s.refcnt = 0;
        s.sitenbr = siteidx++;
        if (scanf("%f %f", &(s.coord.x), &(s.coord.y)) == EOF)
        {
            return (cast(SiteVertex*) null);
        }
        return (s);
    }

    import api.math.geom2.vec2 : Vec2d;

    void runVoronoi(Vec2d[] points)
    {
        /*** read all sites, sort, and compute xmin, xmax, ymin, ymax ***/

        nsites = cast(int) points.length;
        sites = cast(SiteVertex*) malloc(nsites * SiteVertex.sizeof);
        assert(sites);

        freeinit(&sfl, SiteVertex.sizeof);

        siteidx = 0;

        foreach (pi, ref point; points)
        {
            Point p = Point(cast(float) point.x, cast(float) point.y);
            sites[pi] = SiteVertex(p, nsites, 0);
        }

        qsort(cast(void*) sites, nsites, SiteVertex.sizeof, &scomp);
        xmin = sites[0].coord.x;
        xmax = sites[0].coord.x;
        for (auto i = 1; i < nsites; ++i)
        {
            if (sites[i].coord.x < xmin)
            {
                xmin = sites[i].coord.x;
            }
            if (sites[i].coord.x > xmax)
            {
                xmax = sites[i].coord.x;
            }
        }
        ymin = sites[0].coord.y;
        ymax = sites[nsites - 1].coord.y;

        /*** read one site ***/

        sorted = 1;
        plot = 1;

        static SiteVertex* function() nextsite;

        // ymin = 0;
        // ymax = 400;
        // xmin = 0;
        // xmax = 400;

        nextsite = &nextone;

        geominit();
        plotinit();
        voronoi(nextsite);

        free(sites);
    }

}
