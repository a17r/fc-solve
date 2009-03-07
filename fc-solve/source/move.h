/*
 * move.h - header file for the move and move stacks functions of
 * Freecell Solver
 *
 * Written by Shlomi Fish ( http://www.shlomifish.org/ ), 2000
 *
 * This file is in the public domain (it's uncopyrighted).
 */

#ifndef FC_SOLVE__MOVE_H
#define FC_SOLVE__MOVE_H

#ifdef __cplusplus
extern "C" {
#endif

/*
 * This include is done to prevent a warning in case stdlib.h defines
 * max. (which is the case for the Microsoft C Compiler)
 * */
#include <stdlib.h>

#include "state.h"
#include "fcs_move.h"


#if 0
fcs_move_stack_t * fcs_move_stack_create(void);
int fcs_move_stack_push(fcs_move_stack_t * stack, fcs_move_t move);
#endif

#define fcs_move_stack_pop(stack,move) (fc_solve_move_stack_pop(stack,move))
extern int fc_solve_move_stack_pop(fcs_move_stack_t * stack, fcs_move_t * move);

#if 0
void fcs_move_stack_destroy(fcs_move_stack_t * stack);
#endif

#define fcs_move_stack_destroy(stack) \
{     \
    free((stack)->moves);  \
    free(stack); \
}

extern void fc_solve_move_stack_swallow_stack(fcs_move_stack_t * stack, fcs_move_stack_t * src_stack);
#if 0
void fcs_move_stack_reset(fcs_move_stack_t * stack);
#endif
#define fcs_move_stack_reset(stack) \
{      \
    (stack)->num_moves = 0;   \
}



#define fcs_move_stack_get_num_moves(stack) (fc_solve_move_stack_get_num_moves(stack))
extern int fc_solve_move_stack_get_num_moves(fcs_move_stack_t * stack);

#if 0
fcs_move_stack_t * fcs_move_stack_duplicate(fcs_move_stack_t * stack);
#endif
#define fcs_move_stack_duplicate_into_var(final_ret,stack) \
{        \
    fcs_move_stack_t * ret;     \
    fcs_move_stack_t * temp_stack=(stack) ; \
           \
    ret = (fcs_move_stack_t *)malloc(sizeof(fcs_move_stack_t));     \
                 \
    ret->max_num_moves = temp_stack->max_num_moves;      \
    ret->num_moves = temp_stack->num_moves;         \
    ret->moves = (fcs_move_t *)malloc(sizeof(fcs_move_t) * ret->max_num_moves);     \
    memcpy(ret->moves, temp_stack->moves, sizeof(fcs_move_t) * ret->max_num_moves);    \
        \
    (final_ret) = ret;       \
}



void fc_solve_apply_move(
        fcs_state_t * state_with_locations_key,
        fcs_state_extra_info_t * state_with_locations_val,
        fcs_move_t move,
        int freecells_num,
        int stacks_num,
        int decks_num
);

void fc_solve_move_stack_normalize(
    fcs_move_stack_t * moves,
    fcs_state_t * init_state_key,
    fcs_state_extra_info_t * init_state_val,
    int freecells_num,
    int stacks_num,
    int decks_num
    );

extern char * fc_solve_move_to_string(fcs_move_t move, int standard_notation);

extern char * fc_solve_move_to_string_w_state(
        fcs_state_t * state_key,
        fcs_state_extra_info_t * state_val,
        int freecells_num,
        int stacks_num,
        int decks_num,
        fcs_move_t move,
        int standard_notation
        );

typedef fcs_standalone_state_ptrs_t fcs_derived_state_keyval_pair_t;

struct fcs_derived_states_list_struct
{
    int num_states;
    int max_num_states;
    fcs_derived_state_keyval_pair_t * states;
};

typedef struct fcs_derived_states_list_struct fcs_derived_states_list_t;

#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#endif

#define FCS_MOVE_STACK_GROW_BY 16

/* This macro allocates an empty move stack */
#define fcs_move_stack_alloc_into_var(final_ret) \
{       \
    fcs_move_stack_t * ret; \
        \
    /* Allocate the data structure itself */      \
    ret = (fcs_move_stack_t *)malloc(sizeof(fcs_move_stack_t));    \
       \
    ret->max_num_moves = FCS_MOVE_STACK_GROW_BY;      \
    ret->num_moves = 0;        \
    /* Allocate some space for the moves */     \
    ret->moves = (fcs_move_t *)malloc(sizeof(fcs_move_t)*ret->max_num_moves);  \
                \
    (final_ret) = ret;       \
}


#define fcs_move_stack_push(stack, move) \
{           \
    /* If all the moves inside the stack are taken then    \
       resize the move vector */       \
              \
    if (stack->num_moves == stack->max_num_moves) \
    {      \
        int a, b;   \
        a = (stack->max_num_moves >> 3);      \
        b = FCS_MOVE_STACK_GROW_BY;    \
        stack->max_num_moves += max(a,b);    \
        stack->moves = realloc(     \
            stack->moves,     \
            stack->max_num_moves * sizeof(fcs_move_t)   \
            );     \
    }       \
    stack->moves[stack->num_moves++] = move;    \
            \
}

#if 0
#define fc_solve_derived_states_list_add_state(list,state_key,state_val) \
    \
{       \
    if ((list)->num_states == (list)->max_num_states)  \
    {        \
        (list)->max_num_states += 16;     \
        (list)->states = realloc((list)->states, sizeof((list)->states[0]) * (list)->max_num_states); \
    }        \
    (list)->states[(list)->num_states].key = (state_key);    \
    (list)->states[(list)->num_states].val = (state_val);    \
    (list)->num_states++;        \
}

#else
extern void fc_solve_derived_states_list_add_state(
        fcs_derived_states_list_t * list,
        fcs_state_t * state_key,
        fcs_state_extra_info_t * state_val
        );
#endif


#ifdef __cplusplus
}
#endif

#endif  /* FC_SOLVE__MOVE_H */
