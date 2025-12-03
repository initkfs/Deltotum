module api.sims.ele.lib.ngspice.native.v45.types;
/**
 * Authors: initkfs
 */

extern (C):

alias NG_BOOL = bool;

alias pvecvaluesall = vecvaluesall*;
alias pvecinfoall = vecinfoall*;

struct ngcomplex {
    double cx_real = 0;
    double cx_imag = 0;
} 

alias ngcomplex_t = ngcomplex;

struct vector_info {
    char *v_name;		/* Same as so_vname. */
    int v_type;			/* Same as so_vtype. */
    short v_flags;		/* Flags (a combination of VF_*). */
    double *v_realdata;		/* Real data. */
    ngcomplex_t *v_compdata;	/* Complex data. */
    int v_length;		/* Length of the vector. */
}

alias pvector_info = vector_info*;

struct vecvalues {
    char* name;        /* name of a specific vector */
    double _creal;      /* actual data value */
    double cimag;      /* actual data value */
    NG_BOOL is_scale;     /* if 'name' is the scale vector */
    NG_BOOL is_complex;   /* if the data are complex numbers */
}

alias pvecvalues = vecvalues*;

struct vecvaluesall {
    int veccount;      /* number of vectors in plot */
    int vecindex;      /* index of actual set of vectors. i.e. the number of accepted data points */
    pvecvalues* vecsa; /* values of actual set of vectors, indexed from 0 to veccount - 1 */
}

struct vecinfo
{
    int number;     /* number of vector, as postion in the linked list of vectors, starts with 0 */
    char *vecname;  /* name of the actual vector */
    NG_BOOL is_real;   /* TRUE if the actual vector has real data */
    void *pdvec;    /* a void pointer to struct dvec *d, the actual vector */
    void *pdvecscale; /* a void pointer to struct dvec *ds, the scale vector */
}

alias pvecinfo = vecinfo*;

struct vecinfoall
{
    /* the plot */
    char *name;
    char *title;
    char *date;
    char *type;
    int veccount;

    /* the data as an array of vecinfo with length equal to the number of vectors in the plot */
    pvecinfo *vecs;
}