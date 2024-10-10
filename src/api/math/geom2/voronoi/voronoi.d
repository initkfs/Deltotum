module api.math.geom2.voronoi.voronoi;

/*
* Port from source code by Steven Fortune (http://ect.bell-labs.com/who/sjf/) 
* and Bram Stolk (https://github.com/stolk/forvor) 
* under Public Domain license
*/

//TODO refactor

import Math = api.math;

import api.math.geom2;

void delegate(Line2d) onLine;

enum NULL = 0;

enum DELETED = -2;

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

struct Site
{
    Point coord;
    int sitenbr;
    int refcnt;
}

struct Edge
{
    float a = 0, b = 0, c = 0;
    Site*[2] ep;
    Site*[2] reg;
    int edgenbr;
}

enum le = 0;
enum re = 1;

struct Halfedge
{
    Halfedge* ELleft;
    Halfedge* ELright;
    Edge* ELedge;
    int ELrefcnt;
    char ELpm = 0;
    Site* vertex;
    float ystar = 0;
    Halfedge* PQnext;
}

/* edgelist.c */
int ELhashsize;
Site* bottomsite;
Freelist hfl;
Halfedge* ELleftend, ELrightend;
Halfedge** ELhash;

/* geometry.c */
float deltax = 0, deltay = 0;
//int nsites, nedges, sqrt_nsites, nvertices;
int nedges, sqrt_nsites, nvertices;
//Freelist sfl, efl;
Freelist efl;

/* heap.c */
int PQmin, PQcount, PQhashsize;
Halfedge* PQhash;

/* main.c */
int sorted, triangulate, plot, debug_, nsites, siteidx;
float xmin = 0, xmax = 0, ymin = 0, ymax = 0;
Site* sites;
Freelist sfl;

/* getopt.c */
int getopt(int, char**, const(char)*);

/*** MEMORY.C ***/

import core.stdc.stdio;
import core.stdc.stdlib; /* malloc(), exit() */
import core.stdc.assert_;

enum MAXALLOCS = 128;
private void*[MAXALLOCS] allocations;
private int numallocs = 0;

void freeinit(Freelist* fl, int size)
{
    fl.head = cast(Freenode*) null;
    fl.nodesize = size;
}

void freeexit()
{
    int i = void;
    for (i = 0; i < numallocs; ++i)
    {
        free(allocations[i]);
        allocations[i] = null;
    }
    numallocs = 0;
}

char* getfree(Freelist* fl)
{
    int i = void;
    Freenode* t = void;
    if (fl.head == cast(Freenode*) null)
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

void makefree(Freenode* curr, Freelist* fl)
{
    curr.nextfree = fl.head;
    fl.head = curr;
}

int total_alloc;

char* myalloc(ulong n)
{
    return myalloc(cast(uint) n);
}

char* myalloc(uint n)
{
    char* t = void;
    assert(numallocs < MAXALLOCS);
    if ((t = cast(char*) malloc(n)) == cast(char*) 0)
    {
        fprintf(stderr, "Insufficient memory processing site %d (%d bytes in use)\n",
            siteidx, total_alloc);
        exit(0);
    }
    total_alloc += n;
    allocations[numallocs++] = cast(void*) t;
    return (t);
}

/*** HEAP.C ***/
void PQinsert(Halfedge* he, Site* v, float offset)
{
    Halfedge* last = void, next = void;

    he.vertex = v;
    ref_(v);
    he.ystar = v.coord.y + offset;
    last = &PQhash[PQbucket(he)];
    while ((next = last.PQnext) != cast(Halfedge*) null &&
        (he.ystar > next.ystar ||
            (he.ystar == next.ystar &&
            v.coord.x > next.vertex.coord.x)))
    {
        last = next;
    }
    he.PQnext = last.PQnext;
    last.PQnext = he;
    PQcount++;
}

void PQdelete(Halfedge* he)
{
    Halfedge* last = void;

    if (he.vertex != cast(Site*) null)
    {
        last = &PQhash[PQbucket(he)];
        while (last.PQnext != he)
        {
            last = last.PQnext;
        }
        last.PQnext = he.PQnext;
        PQcount--;
        deref(he.vertex);
        he.vertex = cast(Site*) null;
    }
}

int PQbucket(Halfedge* he)
{
    int bucket = void;

    if (he.ystar < ymin)
        bucket = 0;
    else if (he.ystar >= ymax)
        bucket = PQhashsize - 1;
    else
        bucket = cast(int)((he.ystar - ymin) / deltay * PQhashsize);
    if (bucket < 0)
    {
        bucket = 0;
    }
    if (bucket >= PQhashsize)
    {
        bucket = PQhashsize - 1;
    }
    if (bucket < PQmin)
    {
        PQmin = bucket;
    }
    return (bucket);
}

int PQempty()
{
    return (PQcount == 0);
}

Point PQ_min()
{
    Point answer = void;

    while (PQhash[PQmin].PQnext == cast(Halfedge*) null)
    {
        ++PQmin;
    }
    answer.x = PQhash[PQmin].PQnext.vertex.coord.x;
    answer.y = PQhash[PQmin].PQnext.ystar;
    return (answer);
}

Halfedge* PQextractmin()
{
    Halfedge* curr = void;

    curr = PQhash[PQmin].PQnext;
    PQhash[PQmin].PQnext = curr.PQnext;
    PQcount--;
    return (curr);
}

void PQinitialize()
{
    int i = void;

    PQcount = PQmin = 0;
    PQhashsize = 4 * sqrt_nsites;
    PQhash = cast(Halfedge*) myalloc(PQhashsize * (*PQhash).sizeof);
    for (i = 0; i < PQhashsize; i++)
    {
        PQhash[i].PQnext = cast(Halfedge*) null;
    }
}

/*** EDGELIST.C ***/
int ntry, totalsearch;

void ELinitialize()
{
    int i = void;

    freeinit(&hfl, Halfedge.sizeof);
    ELhashsize = 2 * sqrt_nsites;
    ELhash = cast(Halfedge**) myalloc((*ELhash).sizeof * ELhashsize);
    for (i = 0; i < ELhashsize; i++)
    {
        ELhash[i] = cast(Halfedge*) null;
    }
    ELleftend = HEcreate(cast(Edge*) null, 0);
    ELrightend = HEcreate(cast(Edge*) null, 0);
    ELleftend.ELleft = cast(Halfedge*) null;
    ELleftend.ELright = ELrightend;
    ELrightend.ELleft = ELleftend;
    ELrightend.ELright = cast(Halfedge*) null;
    ELhash[0] = ELleftend;
    ELhash[ELhashsize - 1] = ELrightend;
}

Halfedge* HEcreate(Edge* e, int pm)
{
    Halfedge* answer = void;

    answer = cast(Halfedge*) getfree(&hfl);
    answer.ELedge = e;
    answer.ELpm = cast(char) pm;
    answer.PQnext = cast(Halfedge*) null;
    answer.vertex = cast(Site*) null;
    answer.ELrefcnt = 0;
    return (answer);
}

void ELinsert(Halfedge* lb, Halfedge* new_)
{
    new_.ELleft = lb;
    new_.ELright = lb.ELright;
    (lb.ELright).ELleft = new_;
    lb.ELright = new_;
}

/* Get entry from hash table, pruning any deleted nodes */

Halfedge* ELgethash(int b)
{
    Halfedge* he = void;

    if ((b < 0) || (b >= ELhashsize))
    {
        return (cast(Halfedge*) null);
    }
    he = ELhash[b];
    if ((he == cast(Halfedge*) null) || (he.ELedge != cast(Edge*) DELETED))
    {
        return (he);
    }
    /* Hash table points to deleted half edge.  Patch as necessary. */
    ELhash[b] = cast(Halfedge*) null;
    if ((--(he.ELrefcnt)) == 0)
    {
        makefree(cast(Freenode*) he, cast(Freelist*)&hfl);
    }
    return (cast(Halfedge*) null);
}

Halfedge* ELleftbnd(Point* p)
{
    int i = void, bucket = void;
    Halfedge* he = void;

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
    if (he == ELleftend || (he != ELrightend && right_of(he, p)))
    {
        do
        {
            he = he.ELright;
        }
        while (he != ELrightend && right_of(he, p));
        he = he.ELleft;
    }
    else
    {
        do
        {
            he = he.ELleft;
        }
        while (he != ELleftend && !right_of(he, p));
    }
    /*** Update hash table and reference counts ***/
    if ((bucket > 0) && (bucket < ELhashsize - 1))
    {
        if (ELhash[bucket] != cast(Halfedge*) null)
        {
            (ELhash[bucket].ELrefcnt)--;
        }
        ELhash[bucket] = he;
        (ELhash[bucket].ELrefcnt)++;
    }
    return (he);
}

/*** This delete routine can't reclaim node, since pointers from hash
 : table may be present.
 ***/

void ELdelete(Halfedge* he)
{
    (he.ELleft).ELright = he.ELright;
    (he.ELright).ELleft = he.ELleft;
    he.ELedge = cast(Edge*) DELETED;
}

Halfedge* ELright(Halfedge* he)
{
    return (he.ELright);
}

Halfedge* ELleft(Halfedge* he)
{
    return (he.ELleft);
}

Site* leftreg(Halfedge* he)
{
    if (he.ELedge == cast(Edge*) null)
    {
        return (bottomsite);
    }
    return (he.ELpm == le ? he.ELedge.reg[le] : he.ELedge.reg[re]);
}

Site* rightreg(Halfedge* he)
{
    if (he.ELedge == cast(Edge*) null)
    {
        return (bottomsite);
    }
    return (he.ELpm == le ? he.ELedge.reg[re] : he.ELedge.reg[le]);
}

/*** VORONOI.C ***/

/*** implicit parameters: nsites, sqrt_nsites, xmin, xmax, ymin, ymax,
 : deltax, deltay (can all be estimates).
 : Performance suffers if they are wrong; better to make nsites,
 : deltax, and deltay too big than too small.  (?)
 ***/

void voronoi(Site* function() nextsite)
{
    Site* newsite = void, bot = void, top = void, temp = void, p = void, v = void;
    Point newintstar = void;
    int pm = void;
    Halfedge* lbnd = void, rbnd = void, llbnd = void, rrbnd = void, bisector = void;
    Edge* e = void;

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
        if (newsite != cast(Site*) null && (PQempty()
                || newsite.coord.y < newintstar.y
                || (newsite.coord.y == newintstar.y
                && newsite.coord.x < newintstar.x)))
        { /* new site is smallest */
            {
                out_site(newsite);
            }
            lbnd = ELleftbnd(&(newsite.coord));
            rbnd = ELright(lbnd);
            bot = rightreg(lbnd);
            e = bisect(bot, newsite);
            bisector = HEcreate(e, le);
            ELinsert(lbnd, bisector);
            p = intersect(lbnd, bisector);
            if (p != cast(Site*) null)
            {
                PQdelete(lbnd);
                PQinsert(lbnd, p, dist(p, newsite));
            }
            lbnd = bisector;
            bisector = HEcreate(e, re);
            ELinsert(lbnd, bisector);
            p = intersect(bisector, rbnd);
            if (p != cast(Site*) null)
            {
                PQinsert(bisector, p, dist(p, newsite));
            }
            newsite = (*nextsite)();
        }
        else if (!PQempty()) /* intersection is smallest */
        {
            lbnd = PQextractmin();
            llbnd = ELleft(lbnd);
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
            if (p != cast(Site*) null)
            {
                PQdelete(llbnd);
                PQinsert(llbnd, p, dist(p, bot));
            }
            p = intersect(bisector, rrbnd);
            if (p != cast(Site*) null)
            {
                PQinsert(bisector, p, dist(p, bot));
            }
        }
        else
        {
            break;
        }
    }

    for (lbnd = ELright(ELleftend); lbnd != ELrightend; lbnd = ELright(lbnd))
    {
        e = lbnd.ELedge;
        out_ep(e);
    }
}

/*** GEOMETRY.C ***/

import core.stdc.math;

void geominit()
{
    freeinit(&efl, Edge.sizeof);
    nvertices = nedges = 0;
    sqrt_nsites = cast(int) Math.sqrt(nsites + 4);
    deltay = ymax - ymin;
    deltax = xmax - xmin;
}

void geomexit()
{
    freeexit();
}

Edge* bisect(Site* s1, Site* s2)
{
    float dx = 0, dy = 0, adx = 0, ady = 0;
    Edge* newedge = null;

    newedge = cast(Edge*) getfree(&efl);
    newedge.reg[0] = s1;
    newedge.reg[1] = s2;
    ref_(s1);
    ref_(s2);
    newedge.ep[0] = newedge.ep[1] = cast(Site*) null;
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

Site* intersect(Halfedge* el1, Halfedge* el2)
{
    Edge* e1 = void, e2 = void, e = void;
    Halfedge* el = void;
    float d = void, xint = void, yint = void;
    int right_of_site = void;
    Site* v = void;

    e1 = el1.ELedge;
    e2 = el2.ELedge;
    if ((e1 == cast(Edge*) null) || (e2 == cast(Edge*) null))
    {
        return (cast(Site*) null);
    }
    if (e1.reg[1] == e2.reg[1])
    {
        return (cast(Site*) null);
    }
    d = (e1.a * e2.b) - (e1.b * e2.a);
    if ((-1.0e-10 < d) && (d < 1.0e-10))
    {
        return (cast(Site*) null);
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
        return (cast(Site*) null);
    }
    v = cast(Site*) getfree(&sfl);
    v.refcnt = 0;
    v.coord.x = xint;
    v.coord.y = yint;
    return (v);
}

/*** returns 1 if p is to right of halfedge e ***/

int right_of(Halfedge* el, Point* p)
{
    Edge* e = void;
    Site* topsite = void;
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

void endpoint(Edge* e, int lr, Site* s)
{
    e.ep[lr] = s;
    ref_(s);
    if (e.ep[re - lr] == cast(Site*) null)
    {
        return;
    }
    out_ep(e);
    deref(e.reg[le]);
    deref(e.reg[re]);
    makefree(cast(Freenode*) e, cast(Freelist*)&efl);
}

float dist(Site* s, Site* t)
{
    float dx = void, dy = void;

    dx = s.coord.x - t.coord.x;
    dy = s.coord.y - t.coord.y;
    return (sqrt(dx * dx + dy * dy));
}

void makevertex(Site* v)
{
    v.sitenbr = nvertices++;
    out_vertex(v);
}

void deref(Site* v)
{
    if (--(v.refcnt) == 0)
    {
        makefree(cast(Freenode*) v, cast(Freelist*)&sfl);
    }
}

void ref_(Site* v)
{
    ++(v.refcnt);
}

/*** OUTPUT.C ***/

import core.stdc.stdio;

float pxmin = 0, pxmax = 0, pymin = 0, pymax = 0, cradius = 0;

void openpl()
{
}

void line(float ax, float ay, float bx, float by)
{
    import api.math.geom2.line2: Line2d;

    if(onLine){
        onLine(Line2d(ax, ay, bx, by));
    }
}

void circle(float ax, float ay, float radius)
{
}

void range(float pxmin, float pxmax, float pymin, float pymax)
{
}

void out_bisector(Edge* e)
{
    if (triangulate && plot)
    {
        line(e.reg[0].coord.x, e.reg[0].coord.y,
            e.reg[1].coord.x, e.reg[1].coord.y);
    }
    if (!triangulate && !plot && !debug_)
    {
        printf("l %f %f %f %d %d\n", e.a, e.b, e.c, e.reg[le].sitenbr, e.reg[re].sitenbr);
    }
    if (debug_)
    {
        printf("line(%d) %gx+%gy=%g, bisecting %d %d\n", e.edgenbr,
            e.a, e.b, e.c, e.reg[le].sitenbr, e.reg[re].sitenbr);
    }
}

void out_ep(Edge* e)
{
    if (!triangulate && plot)
    {
        clip_line(e);
    }
    if (!triangulate && !plot)
    {
        printf("e %d", e.edgenbr);
        printf(" %d ", e.ep[le] != cast(Site*) null ? e.ep[le].sitenbr : -1);
        printf("%d\n", e.ep[re] != cast(Site*) null ? e.ep[re].sitenbr : -1);
    }
}

void out_vertex(Site* v)
{
    if (!triangulate && !plot && !debug_)
    {
        printf("v %f %f\n", v.coord.x, v.coord.y);
    }
    if (debug_)
    {
        printf("vertex(%d) at %f %f\n", v.sitenbr, v.coord.x, v.coord.y);
    }
}

import api.math.geom2;

void out_site(Site* s)
{
    if (!triangulate && plot && !debug_)
    {
        circle(s.coord.x, s.coord.y, cradius);
    }
    if (!triangulate && !plot && !debug_)
    {
        printf("s %f %f\n", s.coord.x, s.coord.y);
    }
    if (debug_)
    {
        printf("site (%d) at %f %f\n", s.sitenbr, s.coord.x, s.coord.y);
    }
}

void out_triple(Site* s1, Site* s2, Site* s3)
{
    if (triangulate && !plot && !debug_)
    {
        printf("%d %d %d\n", s1.sitenbr, s2.sitenbr, s3.sitenbr);
    }
    if (debug_)
    {
        printf("circle through left=%d right=%d bottom=%d\n",
            s1.sitenbr, s2.sitenbr, s3.sitenbr);
    }
}

void plotinit()
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

void clip_line(Edge* e)
{
    Site* s1 = void, s2 = void;
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
        if (s1 != cast(Site*) null && s1.coord.y > pymin)
        {
            y1 = s1.coord.y;
        }
        if (y1 > pymax)
        {
            return;
        }
        x1 = e.c - e.b * y1;
        y2 = pymax;
        if (s2 != cast(Site*) null && s2.coord.y < pymax)
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
        if (s1 != cast(Site*) null && s1.coord.x > pxmin)
        {
            x1 = s1.coord.x;
        }
        if (x1 > pxmax)
        {
            return;
        }
        y1 = e.c - e.a * x1;
        x2 = pxmax;
        if (s2 != cast(Site*) null && s2.coord.x < pxmax)
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

static Site* nextone()
{
    Site* s = void;

    if (siteidx < nsites)
    {
        s = &sites[siteidx++];
        return (s);
    }
    else
    {
        return (cast(Site*) null);
    }
}

static Site* readone()
{
    Site* s = void;

    s = cast(Site*) getfree(&sfl);
    s.refcnt = 0;
    s.sitenbr = siteidx++;
    if (scanf("%f %f", &(s.coord.x), &(s.coord.y)) == EOF)
    {
        return (cast(Site*) null);
    }
    return (s);
}

import api.math.geom2.vec2 : Vec2d;

void runVoronoi(Vec2d[] points)
{
    /*** read all sites, sort, and compute xmin, xmax, ymin, ymax ***/

    nsites = cast(int) points.length;
    sites = cast(Site*) malloc(nsites * Site.sizeof);
    assert(sites);

    freeinit(&sfl, Site.sizeof);

    siteidx = 0;

    foreach (pi, ref point; points)
    {
        Point p = Point(cast(float) point.x, cast(float) point.y);
        sites[pi] = Site(p, nsites, 0);
    }

    qsort(cast(void*) sites, nsites, Site.sizeof, &scomp);
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

    debug_ = 1;
    triangulate = 1;
    sorted = 1;
    plot = 1;

    static Site* function() nextsite;

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
