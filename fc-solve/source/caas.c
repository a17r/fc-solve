/*
 * caas.c - the various possible implementations of the function
 * fc_solve_check_and_add_state().
 *
 * Written by Shlomi Fish ( http://www.shlomifish.org/ ), 2000
 *
 * This file is in the public domain (it's uncopyrighted).
 */

#ifndef FC_SOLVE__CAAS_C
#define FC_SOLVE__CAAS_C

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "fcs_dm.h"
#include "fcs.h"

#include "fcs_isa.h"

#include "lookup2.h"


#ifdef INDIRECT_STACK_STATES
#include "fcs_hash.h"
#endif

#include "caas.h"
#include "ms_ca.h"

#include "test_arr.h"

#ifdef DMALLOC
#include "dmalloc.h"
#endif


/*
    The objective of the fcs_caas_check_and_insert macros is:
    1. To check if new_state is already in the prev_states collection.
    2. If not, to add it and to set check to true.
    3. If so, to set check to false.
  */


#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INTERNAL_HASH)
#ifdef FCS_WITH_MHASH
#define fcs_caas_check_and_insert()            \
    /*                                            \
        Calculate the has function of the state.   \
    */                   \
    {        \
        char * temp_ptr;    \
        instance->mhash_context = mhash_init(instance->mhash_type); \
        mhash(instance->mhash_context, (void *)new_state, sizeof(fcs_state_t));    \
        temp_ptr = mhash_end(instance->mhash_context); \
        /* Retrieve the first 32 bits and make them the hash value */      \
        hash_value_int = *(SFO_hash_value_t*)temp_ptr;      \
        free(temp_ptr);      \
    }      \
            \
    if (hash_value_int < 0)       \
    {    \
        /*             \
         * This is a bit mask that nullifies the sign bit of the  \
         * number so it will always be positive           \
         * */            \
        hash_value_int &= (~(1<<((sizeof(hash_value_int)<<3)-1)));     \
    }    \
    check = ((*existing_state = fc_solve_hash_insert(          \
        instance->hash,              \
        new_state,                   \
        hash_value_int,              \
        1                            \
        )) == NULL);



#else
#define fcs_caas_check_and_insert()                                     \
    {                                                                   \
        const char * s_ptr = (char*)new_state;                          \
        const char * s_end = s_ptr+sizeof(fcs_state_t);                 \
        hash_value_int = 0;                                             \
        while (s_ptr < s_end)                                           \
        {                                                               \
            hash_value_int += (hash_value_int << 5) + *(s_ptr++);       \
        }                                                               \
        hash_value_int += (hash_value_int>>5);                          \
    }                                                                   \
    if (hash_value_int < 0)                                             \
    {                                                                   \
        /*                                                              \
         * This is a bit mask that nullifies the sign bit of the        \
         * number so it will always be positive                         \
         * */                                                           \
        hash_value_int &= (~(1<<((sizeof(hash_value_int)<<3)-1)));      \
    }                                                                   \
    check = ((*existing_state = fc_solve_hash_insert(            \
        instance->hash,                                                 \
        new_state,                                                      \
        freecell_solver_lookup2_hash_function(                          \
            (ub1 *)new_state,                                           \
            sizeof(fcs_state_t),                                        \
            24                                                          \
            ),                                                          \
        hash_value_int,                                                 \
        1                                                               \
        )) == NULL);

#endif
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INDIRECT)
#define fcs_caas_check_and_insert()              \
    /* Try to see if the state is found in indirect_prev_states */  \
    if ((pos_ptr = (fcs_state_with_locations_t * *)bsearch(&new_state,                                         \
                instance->indirect_prev_states,                     \
                instance->num_indirect_prev_states,                 \
                sizeof(fcs_state_with_locations_t *),               \
                fc_solve_state_compare_indirect)) == NULL)                \
    {                                                               \
        /* It isn't in prev_states, but maybe it's in the sort margin */        \
        pos_ptr = (fcs_state_with_locations_t * *)fc_solve_bsearch(              \
            &new_state,                                                     \
            instance->indirect_prev_states_margin,                          \
            instance->num_prev_states_margin,                               \
            sizeof(fcs_state_with_locations_t *),                           \
            fc_solve_state_compare_indirect_with_context, \
            NULL,                  \
            &found);              \
                             \
        if (found)                \
        {                             \
            check = 0;                   \
            *existing_state = *pos_ptr;     \
        }                                 \
        else                               \
        {                                     \
            /* Insert the state into its corresponding place in the sort         \
             * margin */                             \
            memmove((void*)(pos_ptr+1),       \
                    (void*)pos_ptr,       \
                    sizeof(fcs_state_with_locations_t *) * \
                    (instance->num_prev_states_margin-  \
                      (pos_ptr-instance->indirect_prev_states_margin)   \
                    ));  \
            *pos_ptr = new_state;                \
                       \
            instance->num_prev_states_margin++;             \
              \
            if (instance->num_prev_states_margin >= PREV_STATES_SORT_MARGIN)         \
            {          \
                /* The sort margin is full, let's combine it with the main array */         \
                if (instance->num_indirect_prev_states + instance->num_prev_states_margin > instance->max_num_indirect_prev_states)       \
                {               \
                    while (instance->num_indirect_prev_states + instance->num_prev_states_margin > instance->max_num_indirect_prev_states)        \
                    {            \
                        instance->max_num_indirect_prev_states += PREV_STATES_GROW_BY;         \
                    }                \
                    instance->indirect_prev_states = realloc(instance->indirect_prev_states, sizeof(fcs_state_with_locations_t *) * instance->max_num_indirect_prev_states);       \
                }             \
                            \
                fc_solve_merge_large_and_small_sorted_arrays(           \
                    instance->indirect_prev_states,              \
                    instance->num_indirect_prev_states,           \
                    instance->indirect_prev_states_margin,          \
                    instance->num_prev_states_margin,              \
                    sizeof(fcs_state_with_locations_t *),           \
                    fc_solve_state_compare_indirect_with_context,          \
                    NULL                        \
                );                   \
                                  \
                instance->num_indirect_prev_states += instance->num_prev_states_margin;       \
                          \
                instance->num_prev_states_margin=0;           \
            }                  \
            check = 1;               \
        }                  \
                    \
    }                   \
    else                 \
    {         \
        *existing_state = *pos_ptr; \
        check = 0;          \
    }

#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBREDBLACK_TREE)

#define fcs_caas_check_and_insert()               \
    *existing_state = (fcs_state_with_locations_t *)rbsearch(new_state, instance->tree); \
    check = ((*existing_state) == new_state);

#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_AVL_TREE) || (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE)

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_AVL_TREE)
#define fcs_libavl_states_tree_insert(a,b) avl_insert((a),(b))
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE)
#define fcs_libavl_states_tree_insert(a,b) rb_insert((a),(b))
#endif

#define fcs_caas_check_and_insert()       \
    *existing_state = fcs_libavl_states_tree_insert(instance->tree, new_state); \
    check = (*existing_state == NULL);

#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_TREE)
#define fcs_caas_check_and_insert()       \
    *existing_state = g_tree_lookup(instance->tree, (gpointer)new_state);  \
    if (*existing_state == NULL) \
    {            \
        /* The new state was not found. Let's insert it.       \
         * The value must be the same as the key, so g_tree_lookup()   \
         * will return it. */                  \
        g_tree_insert(                        \
            instance->tree,                      \
            (gpointer)new_state,              \
            (gpointer)new_state                 \
            );                         \
        check = 1;                  \
    }              \
    else        \
    {          \
        check = 0;     \
    }



#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_HASH)
#define fcs_caas_check_and_insert()       \
    *existing_state = g_hash_table_lookup(instance->hash, (gpointer)new_state); \
    if (*existing_state == NULL) \
    { \
        /* The new state was not found. Let's insert it.       \
         * The value must be the same as the key, so g_tree_lookup()   \
         * will return it. */                  \
        g_hash_table_insert(         \
            instance->hash,          \
            (gpointer)new_state,          \
            (gpointer)new_state            \
        \
            );           \
        check = 1;              \
    }          \
    else        \
    {          \
        check = 0;     \
    }

#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_DB_FILE)
#define fcs_caas_check_and_insert()     \
    {         \
        DBT key, value;      \
        key.data = new_state; \
        key.size = sizeof(*new_state);      \
        if (instance->db->get(         \
            instance->db,        \
            NULL,        \
            &key,      \
            &value,      \
            0        \
            ) == 0) \
        {      \
            /* The new state was not found. Let's insert it.       \
             * The value must be the same as the key, so g_tree_lookup()   \
             * will return it. */                  \
                \
            value.data = key.data;     \
            value.size = key.size;     \
            instance->db->put(         \
                instance->db,      \
                NULL,           \
                &key,         \
                &value,         \
                0);             \
            check = 1;        \
        }         \
        else         \
        {         \
            check = 0;        \
            *existing_state = (fcs_state_with_locations_t *)(value.data);     \
        }         \
    }

#else
#error no define
#endif

#ifdef INDIRECT_STACK_STATES
static void GCC_INLINE fc_solve_cache_stacks(
        fc_solve_hard_thread_t * hard_thread,
        fcs_state_t * new_state_key,
        fcs_state_extra_info_t * new_state_val

        )

{

}

#else
#define fc_solve_cache_stacks(instance, new_state)
#endif


#ifdef FCS_WITH_TALONS
void fc_solve_cache_talon(
    fc_solve_instance_t * instance,
    fcs_state_t * new_state_key,
    fcs_state_extra_info_t * new_state_val

    )

{

}

#endif


#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_HASH)
guint fc_solve_hash_function(gconstpointer key)
{
    guint hash_value;
    const char * s_ptr = (char*)key;
    const char * s_end = s_ptr+sizeof(fcs_state_t);
    hash_value = 0;
    while (s_ptr < s_end)
    {
        hash_value += (hash_value << 5) + *(s_ptr++);
    }
    hash_value += (hash_value >> 5);

    return hash_value;
}
#endif


/*
 * check_and_add_state() does the following things:
 *
 * 1. Check if the number of iterations exceeded its maximum, and if so
 *    return FCS_STATE_EXCEEDS_MAX_NUM_TIMES in order to terminate the
 *    solving process.
 * 2. Check if the maximal depth was reached and if so return
 *    FCS_STATE_EXCEEDS_MAX_DEPTH
 * 3. Canonize the state.
 * 4. Check if the state is already found in the collection of the states
 *    that were already checked.
 *    If it is:
 *
 *        5a. Return FCS_STATE_ALREADY_EXISTS
 *
 *    If it isn't:
 *
 *        5b. Call solve_for_state() on the board.
 *
 * */

GCC_INLINE int fc_solve_check_and_add_state(
    fc_solve_soft_thread_t * soft_thread,
    fcs_state_t * new_state_key,
    fcs_state_extra_info_t * new_state_val,

    fcs_state_t * * existing_state_key,

    fcs_state_extra_info_t * * existing_state_val

    )

{

}




/*
 * This implementation crashes for some reason, so don't use it.
 *
 * */


#if 0

static char meaningless_data[16] = "Hello World!";

int fc_solve_check_and_add_state(fc_solve_instance_t * instance, fcs_state_with_locations_t * new_state, int depth)
{
    DBT key, value;

    if ((instance->max_num_times >= 0) &&
        (instance->max_num_times <= instance->num_times))
    {
        return FCS_STATE_EXCEEDS_MAX_NUM_TIMES;
    }

    if ((instance->max_depth >= 0) &&
        (instance->max_depth <= depth))
    {
        return FCS_STATE_EXCEEDS_MAX_DEPTH;
    }

    fcs_canonize_state(new_state, instance->freecells_num, instance->stacks_num);

    fc_solve_cache_stacks(instance, new_state);

    key.data = new_state;
    key.size = sizeof(*new_state);

    if (instance->db->get(
        instance->db,
        NULL,
        &key,
        &value,
        0
        ) == 0)
    {
        /* The new state was not found. Let's insert it.
         * The value should be non-NULL or else g_hash_table_lookup() will
         * return NULL even if it exists. */

        value.data = meaningless_data;
        value.size = 8;
        instance->db->put(
            instance->db,
            NULL,
            &key,
            &value,
            0);
        if (fc_solve_solve_for_state(instance, new_state, depth+1,0) == FCS_STATE_WAS_SOLVED)
        {
            return FCS_STATE_WAS_SOLVED;
        }
        else
        {
            return FCS_STATE_IS_NOT_SOLVEABLE;
        }
    }
    else
    {
        /* free (value.data) ; */
        return FCS_STATE_ALREADY_EXISTS;
    }
}


#endif

#endif /* #ifndef FC_SOLVE__CAAS_C */
