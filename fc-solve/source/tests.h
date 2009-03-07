/*
 * fcs.h - header file of the test functions for Freecell Solver.
 *
 * The test functions code is found in freecell.c
 *
 * Written by Shlomi Fish ( http://www.shlomifish.org/ ), 2000
 *
 * This file is in the public domain (it's uncopyrighted).
 */

#ifndef FC_SOLVE__TESTS_H
#define FC_SOLVE__TESTS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <limits.h>
#include <string.h>

#include "fcs_isa.h"
#include "fcs.h"

#include "test_arr.h"


/*
 * The number of cards that can be moved is
 * (freecells_number + 1) * 2 ^ (free_stacks_number)
 *
 * See the Freecell FAQ and the source code of PySol
 *
 * */
#define calc_max_sequence_move(fc_num, fs_num)                    \
    ((instance->unlimited_sequence_move) ?                         \
            INT_MAX :                                             \
    ((instance->empty_stacks_fill == FCS_ES_FILLED_BY_ANY_CARD) ? \
                (((fc_num)+1)<<(fs_num))                        : \
        ((fc_num)+1)                                              \
    ))

#include "caas.h"

/*
 *  These are some macros to make it easier for the programmer.
 * */
#define ptr_state_key (ptr_state_with_locations_key)
#define ptr_state_val (ptr_state_with_locations_val)
#define state_key (*ptr_state_key)
#define state  (state_key)
#define state_val (*ptr_state_val)
#define new_state (*ptr_new_state_key)
#define new_state_key (new_state)
#define new_state_val (*ptr_new_state_val)


#define sfs_check_state_begin()                                                \
    fcs_state_ia_alloc_into_var(ptr_new_state_key, ptr_new_state_val, hard_thread);    \
    fcs_duplicate_state(new_state_key, new_state_val, state_key, state_val);       \
    /* Some A* and BFS parameters that need to be initialized in               \
     * the derived state.                                                      \
     * */                                                                      \
    ptr_new_state_val->parent_key = ptr_state_key;           \
    ptr_new_state_val->parent_val = ptr_state_val;           \
    ptr_new_state_val->moves_to_parent = moves;                     \
    /* Make sure depth is consistent with the game graph.                      \
     * I.e: the depth of every newly discovered state is derived from          \
     * the state from which it was discovered. */                              \
    ptr_new_state_val->depth = ptr_new_state_val->depth + 1; \
    /* Mark this state as a state that was not yet visited */                  \
    ptr_new_state_val->visited = 0;                                 \
    /* It's a newly created state which does not have children yet. */         \
    ptr_new_state_val->num_active_children = 0;                     \
    memset(ptr_new_state_val->scan_visited, '\0',                   \
        sizeof(ptr_new_state_val->scan_visited)                     \
        );                                                                     \
    fcs_move_stack_reset(moves);                                               \

#define sfs_check_state_end()                                             \
/* The last move in a move stack should be FCS_MOVE_TYPE_CANONIZE         \
 * because it indicates that the order of the stacks and freecells        \
 * need to be recalculated                                                \
 * */                                                                     \
fcs_move_set_type(temp_move,FCS_MOVE_TYPE_CANONIZE);                      \
fcs_move_stack_push(moves, temp_move);                                    \
                                                                          \
{                                                                         \
    fcs_state_t * existing_state_key;                                     \
    fcs_state_extra_info_t * existing_state_val;                          \
    check = fc_solve_check_and_add_state(                                 \
        soft_thread,                                                      \
        ptr_new_state_key,                                                \
        ptr_new_state_val,                                                \
        &existing_state_key,                                              \
        &existing_state_val                                               \
        );                                                                \
    if ((check == FCS_STATE_BEGIN_SUSPEND_PROCESS) ||                     \
        (check == FCS_STATE_SUSPEND_PROCESS))                             \
    {                                                                     \
        /* This state is not going to be used, so                         \
         * let's clean it. */                                             \
        fcs_state_ia_release(hard_thread);                                \
        return check;                                                     \
    }                                                                     \
    else if (check == FCS_STATE_ALREADY_EXISTS)                           \
    {                                                                     \
        fcs_state_ia_release(hard_thread);                                \
        calculate_real_depth(existing_state_key, existing_state_val);     \
        /* Re-parent the existing state to this one.                      \
         *                                                                \
         * What it means is that if the depth of the state if it          \
         * can be reached from this one is lower than what it             \
         * already have, then re-assign its parent to this state.         \
         * */                                                             \
        if (reparent &&                                                   \
           (existing_state_val->depth > ptr_state_val->depth+1))   \
        {                                                                 \
            /* Make a copy of "moves" because "moves" will be destroyed */\
            existing_state_val->moves_to_parent =                             \
                fc_solve_move_stack_compact_allocate(              \
                    hard_thread, moves                                    \
                    );                                                    \
            if (!(existing_state_val->visited & FCS_VISITED_DEAD_END))        \
            {                                                             \
                if ((--existing_state_val->parent_val->num_active_children) == 0) \
                {                                                         \
                    mark_as_dead_end(                                     \
                        existing_state_val->parent_key,                   \
                        existing_state_val->parent_val                    \
                        );                                                \
                }                                                         \
                ptr_state_val->num_active_children++;          \
            }                                                             \
            existing_state_val->parent_key = ptr_state_key;               \
            existing_state_val->parent_val = ptr_state_val;               \
            existing_state_val->depth = ptr_state_val->depth + 1;  \
        }                                                                 \
        fc_solve_derived_states_list_add_state(                                \
            derived_states_list,                                          \
            existing_state_key,                                           \
            existing_state_val                                            \
            );                                                            \
    }                                                                     \
    else                                                                  \
    {                                                                     \
        fc_solve_derived_states_list_add_state(                                \
            derived_states_list,                                          \
            ptr_new_state_key,                                            \
            ptr_new_state_val                                             \
            );                                                            \
   }                                                                      \
}


/*
    This macro checks if the top card in the stack is a flipped card
    , and if so flips it so its face is up.
  */
#define fcs_flip_top_card(stack)                                   \
{                                                                  \
    int cards_num;                                                 \
    cards_num = fcs_stack_len(new_state,stack);                    \
                                                                   \
    if (cards_num > 0)                                             \
    {                                                              \
        if (fcs_card_get_flipped(                                  \
                fcs_stack_card(                                    \
                    new_state,                                     \
                    stack,                                         \
                    cards_num-1)                                   \
                ) == 1                                             \
           )                                                       \
        {                                                          \
            fcs_flip_stack_card(new_state,stack,cards_num-1);      \
            fcs_move_set_type(temp_move, FCS_MOVE_TYPE_FLIP_CARD); \
            fcs_move_set_src_stack(temp_move, stack);              \
                                                                   \
            fcs_move_stack_push(moves, temp_move);                 \
        }                                                          \
    }                                                              \
}


/*
 * dest is the destination stack
 * source is the source stack
 * start is the start height
 * end is the end height
 * a is the iterator
 * */
#define fcs_move_sequence(dest, source, start, end, a)              \
{                                                                   \
    for ( a = (start) ; a <= (end) ; a++)                           \
    {                                                               \
        fcs_push_stack_card_into_stack(new_state, dest, source, a); \
    }                                                               \
                                                                    \
    for ( a = (start) ; a <= (end) ; a++)                           \
    {                                                               \
        fcs_pop_stack_card(new_state, source, temp_card);           \
    }                                                               \
                                                                    \
    fcs_move_set_type(temp_move, FCS_MOVE_TYPE_STACK_TO_STACK);     \
    fcs_move_set_src_stack(temp_move, source);                      \
    fcs_move_set_dest_stack(temp_move, dest);                       \
    fcs_move_set_num_cards_in_seq(temp_move, (end)-(start)+1);      \
                                                                    \
    fcs_move_stack_push(moves, temp_move);                          \
}

/*
 * This test declares a few access variables that are used in all
 * the tests.
 * */
#define tests_declare_accessors()                              \
    fc_solve_hard_thread_t * hard_thread;               \
    fc_solve_instance_t * instance;                     \
    fcs_state_t * ptr_new_state_key; \
    fcs_state_extra_info_t * ptr_new_state_val; \
    fcs_move_stack_t * moves;                                  \
    char * indirect_stacks_buffer;                             \
    int calc_real_depth;                                       \
    int scans_synergy

/*
 * This macro defines these accessors to have some value.
 * */
#define tests_define_accessors()                                  \
    hard_thread = soft_thread->hard_thread;                       \
    instance = hard_thread->instance;                             \
    moves = hard_thread->reusable_move_stack;                     \
    indirect_stacks_buffer = hard_thread->indirect_stacks_buffer; \
    calc_real_depth = instance->calc_real_depth;                  \
    scans_synergy = instance->scans_synergy;



extern int fc_solve_sfs_simple_simon_move_sequence_to_founds(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );
extern int fc_solve_sfs_simple_simon_move_sequence_to_true_parent(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

extern int fc_solve_sfs_simple_simon_move_whole_stack_sequence_to_false_parent(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

extern int fc_solve_sfs_simple_simon_move_sequence_to_true_parent_with_some_cards_above(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

extern int fc_solve_sfs_simple_simon_move_sequence_with_some_cards_above_to_true_parent(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

extern int fc_solve_sfs_simple_simon_move_sequence_with_junk_seq_above_to_true_parent_with_some_cards_above(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

extern int fc_solve_sfs_simple_simon_move_whole_stack_sequence_to_false_parent_with_some_cards_above(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

extern int fc_solve_sfs_simple_simon_move_sequence_to_parent_on_the_same_stack(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_t * ptr_state_with_locations_key,
        fcs_state_extra_info_t * ptr_state_with_locations_val,
        int num_freestacks,
        int num_freecells,
        fcs_derived_states_list_t * derived_states_list,
        int reparent
        );

#ifdef __cplusplus
}
#endif

#define my_copy_stack(idx) fcs_copy_stack(new_state_key, new_state_val, idx, indirect_stacks_buffer);

#endif /* FC_SOLVE__TESTS_H */
