/* Copyright (c) 2000 Shlomi Fish
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * meta_move_funcs_helpers.h - header file of the move functions of Freecell
 * Solver.
 *
 * The move functions code itself is found in freecell.c and simpsim.c.
 *
 */

#ifndef FC_SOLVE__META_MOVE_FUNCS_HELPERS_H
#define FC_SOLVE__META_MOVE_FUNCS_HELPERS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <limits.h>
#include <string.h>

#include "inline.h"

#include "instance.h"

#ifdef FCS_FREECELL_ONLY
#define calc_max_sequence_move(fc_num, fs_num) (((fc_num)+1)<<(fs_num))
#else
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
#endif

/*
 *  These are some macros to make it easier for the programmer.
 * */
#define ptr_state_key (ptr_state_key)
#define ptr_state_val (ptr_state_val)
#define state_key (*ptr_state_key)
#define state  (state_key)
#define state_val (*ptr_state_val)
#define new_state (*ptr_new_state_key)
#define new_state_key (new_state)
#define new_state_val (*ptr_new_state_val)


#define sfs_check_state_begin()                                     \
    {         \
        fc_solve_sfs_check_state_begin(hard_thread,  \
                &ptr_new_state_key,                  \
                &ptr_new_state_val,                  \
                ptr_state_val,                       \
                moves);                              \
    }


#define sfs_check_state_end()                                             \
    { \
        check = fc_solve_sfs_check_state_end(soft_thread, ptr_state_val, ptr_new_state_val, state_context_value, moves, derived_states_list);                         \
        if ((check == FCS_STATE_BEGIN_SUSPEND_PROCESS) ||                   \
            (check == FCS_STATE_SUSPEND_PROCESS))                            \
        {         \
            return check;         \
        }         \
    }

/*
    This macro checks if the top card in the stack is a flipped card
    , and if so flips it so its face is up.
  */
#ifndef FCS_WITHOUT_CARD_FLIPPING
#define fcs_flip_top_card(stack_idx)                                   \
{                                                                  \
    fcs_cards_column_t flip_top_card_col;                                        \
    flip_top_card_col = fcs_state_get_col(new_state, stack_idx);                 \
                                                                   \
    if (fcs_col_len(flip_top_card_col) > 0)                                             \
    {                                                              \
        if (fcs_card_get_flipped(                                  \
                fcs_col_get_card(flip_top_card_col, fcs_col_len(flip_top_card_col)-1)        \
                ) == 1                                             \
           )                                                       \
        {                                                          \
            fcs_col_flip_card(flip_top_card_col, fcs_col_len(flip_top_card_col)-1);                   \
            fcs_int_move_set_type(temp_move, FCS_MOVE_TYPE_FLIP_CARD); \
            fcs_int_move_set_src_stack(temp_move, stack_idx);              \
                                                                   \
            fcs_move_stack_push(moves, temp_move);                 \
        }                                                          \
    }                                                              \
}
#else
#define fcs_flip_top_card(stack_idx) {}
#endif

static GCC_INLINE void fc_solve_move_sequence_function(
        fcs_state_t * new_state_ptr,
        fcs_move_stack_t * moves,
        int dest_idx,
        int source_idx,
        int start,
        int end
        )
{
    int i;
    fcs_cards_column_t new_src_col, new_dest_col;
    fcs_internal_move_t temp_move;

    new_src_col = fcs_state_get_col(*new_state_ptr, source_idx);
    new_dest_col = fcs_state_get_col(*new_state_ptr, dest_idx);

    for ( i = start ; i <= end ; i++)
    {
        fcs_col_push_col_card(new_dest_col, new_src_col, i);
    }

    for ( i = start ; i <= end ; i++)
    {
        fcs_col_pop_top(new_src_col);
    }

    fcs_int_move_set_type(temp_move, FCS_MOVE_TYPE_STACK_TO_STACK);
    fcs_int_move_set_src_stack(temp_move, source_idx);
    fcs_int_move_set_dest_stack(temp_move, dest_idx);
    fcs_int_move_set_num_cards_in_seq(temp_move, end-start+1);

    fcs_move_stack_push(moves, temp_move);
}

/*
 * dest is the destination stack
 * source is the source stack
 * start is the start height
 * end is the end height
 * a is the iterator
 * */
#define fcs_move_sequence(dest_idx, source_idx, start_idx, end_idx) \
    {   \
        fc_solve_move_sequence_function(ptr_new_state_key, moves, dest_idx, source_idx, start_idx, end_idx); \
    }

#ifdef FCS_FREECELL_ONLY
#define tests_declare_accessors_freecell_only()
#define tests_declare_seqs_built_by()
#define tests_declare_empty_stacks_fill()
#else
#define tests_declare_accessors_freecell_only() \
    fc_solve_instance_t * instance;
#define tests_declare_seqs_built_by() \
    int sequences_are_built_by;
#define tests_declare_empty_stacks_fill() \
    int empty_stacks_fill;
#endif

/*
 * This macro declares a few access variables that are used in all
 * the tests.
 * */
#define tests_declare_accessors_no_stacks()         \
    tests_declare_accessors_freecell_only()                    \
    fc_solve_hard_thread_t * hard_thread;               \
    fcs_state_t * ptr_state_key; \
    fcs_state_t * ptr_new_state_key; \
    fcs_state_extra_info_t * ptr_new_state_val; \
    fcs_move_stack_t * moves;                                  \
    int state_context_value                                  \

#define tests_declare_accessors() \
    tests_declare_accessors_no_stacks();           \
    char * indirect_stacks_buffer;                             \

#ifdef FCS_FREECELL_ONLY

#define tests_define_accessors_freecell_only() {}

#define tests__is_filled_by_any_card() 1

#define tests__is_filled_by_kings_only() 0

#define tests__is_filled_by_none() 0

#else

#define tests_define_accessors_freecell_only() \
{ \
    instance = hard_thread->instance;                     \
}

#define tests__is_filled_by_any_card() \
    (empty_stacks_fill == FCS_ES_FILLED_BY_ANY_CARD)

#define tests__is_filled_by_kings_only() \
    (empty_stacks_fill == FCS_ES_FILLED_BY_KINGS_ONLY)

#define tests__is_filled_by_none() \
    (empty_stacks_fill == FCS_ES_FILLED_BY_NONE)

#endif

/*
 * This macro defines these accessors to have some value.
 * */
#define tests_define_accessors_no_stacks()                                  \
    ptr_state_key = ptr_state_val->key;                           \
    hard_thread = soft_thread->hard_thread;                       \
    moves = &(hard_thread->reusable_move_stack);                     \
    state_context_value = 0;                                      \
    tests_define_accessors_freecell_only()

#define tests_define_accessors()  \
    tests_define_accessors_no_stacks();       \
    indirect_stacks_buffer = hard_thread->indirect_stacks_buffer; \

#ifdef FCS_FREECELL_ONLY

#define tests_define_seqs_built_by()
#define tests_define_empty_stacks_fill()
#else

#define tests_define_seqs_built_by()   \
{ \
    sequences_are_built_by = instance->sequences_are_built_by; \
}

#define tests_define_empty_stacks_fill() \
{ \
    empty_stacks_fill = instance->empty_stacks_fill; \
}

#endif

#define my_copy_stack(idx) fcs_copy_stack(new_state_key, new_state_val, idx, indirect_stacks_buffer);

#ifdef __cplusplus
}
#endif

#endif /* FC_SOLVE__META_MOVE_FUNCS_HELPERS_H */
