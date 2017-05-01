/*
 * This file is part of Freecell Solver. It is subject to the license terms in
 * the COPYING.txt file found in the top-level directory of this distribution
 * and at http://fc-solve.shlomifish.org/docs/distro/COPYING.html . No part of
 * Freecell Solver, including this file, may be copied, modified, propagated,
 * or distributed except according to the terms contained in the COPYING file.
 *
 * Copyright (c) 2000 Shlomi Fish
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "generic_tree.h"
#include "delta_states.h"

/* We need it for the typedef of fcs_fcc_move_t. */
#include "fcc_brfs_test.h"
#include "lock.h"

#ifndef FCS_DBM_WITHOUT_CACHES

#include "dbm_lru_cache.h"

typedef union fcs_pre_cache_key_val_pair_struct {
    struct
    {
        fcs_encoded_state_buffer_t key;
        fcs_encoded_state_buffer_t parent;
    };
    union fcs_pre_cache_key_val_pair_struct *next;
} fcs_pre_cache_key_val_pair_t;

typedef struct
{
    dict_t *kaz_tree;
    fcs_compact_allocator_t kv_allocator;
    fcs_pre_cache_key_val_pair_t *kv_recycle_bin;
    long count_elements;
    void *tree_recycle_bin;
} fcs_pre_cache_t;
#endif

typedef void *fcs_dbm_store_t;
void fc_solve_dbm_store_init(
    fcs_dbm_store_t *store, const char *path, void **recycle_bin_ptr);

dict_t *fc_solve_dbm_store_get_dict(fcs_dbm_store_t store);

fcs_bool_t fc_solve_dbm_store_does_key_exist(
    fcs_dbm_store_t store, const unsigned char *key_raw);

fcs_bool_t fc_solve_dbm_store_lookup_parent(fcs_dbm_store_t store,
    const unsigned char *const key, unsigned char *const parent);

fcs_dbm_record_t *fc_solve_dbm_store_insert_key_value(fcs_dbm_store_t store,
    const fcs_encoded_state_buffer_t *key, fcs_dbm_record_t *parent,
    const fcs_bool_t should_modify_parent);

#ifndef FCS_DBM_WITHOUT_CACHES
void fc_solve_dbm_store_offload_pre_cache(
    fcs_dbm_store_t store, fcs_pre_cache_t *const pre_cache);
#endif

void fc_solve_dbm_store_destroy(fcs_dbm_store_t store);

typedef struct fcs_dbm_queue_item_struct
{
    fcs_encoded_state_buffer_t key;
    /* TODO : maybe get rid of moves_seq with FCS_DBM_WITHOUT_CACHES
     * to save space. */
    fcs_fcc_moves_seq_t moves_seq;
#ifndef FCS_DBM_WITHOUT_CACHES
    fcs_fcc_move_t *moves_to_key;
#endif

    struct fcs_dbm_queue_item_struct *next;
} fcs_dbm_queue_item_t;

enum TERMINATE_REASON
{
    DONT_TERMINATE = 0,
    QUEUE_TERMINATE,
    MAX_ITERS_TERMINATE,
    SOLUTION_FOUND_TERMINATE
};

typedef struct
{
    fcs_lock_t storage_lock;
    long queue_num_extracted_and_processed;
    fcs_encoded_state_buffer_t first_key;
    long num_states_in_collection;
    FILE *out_fh;
    fcs_dbm_variant_type_t variant;
    long count_num_processed, count_of_items_in_queue, max_count_num_processed;
    fcs_bool_t queue_solution_was_found;
    enum TERMINATE_REASON should_terminate;
#ifdef FCS_DBM_WITHOUT_CACHES
    fcs_dbm_record_t *queue_solution_ptr;
#else
    fcs_encoded_state_buffer_t queue_solution;
#endif
    void *tree_recycle_bin;
} fcs_dbm_instance_common_elems_t;

static inline void fcs_dbm__found_solution(
    fcs_dbm_instance_common_elems_t *const common,
    fcs_dbm_record_t *const token, fcs_dbm_queue_item_t *const item)
{
    common->should_terminate = SOLUTION_FOUND_TERMINATE;
    common->queue_solution_was_found = TRUE;
#ifdef FCS_DBM_WITHOUT_CACHES
    common->queue_solution_ptr = token;
#else
    common->queue_solution = item->key;
#endif
}

static inline void fcs_dbm__common_init(
    fcs_dbm_instance_common_elems_t *const common, const long iters_delta_limit,
    const fcs_dbm_variant_type_t local_variant, FILE *const out_fh)
{
    common->variant = local_variant;
    common->out_fh = out_fh;
    common->queue_solution_was_found = FALSE;
    common->should_terminate = DONT_TERMINATE;
    common->queue_num_extracted_and_processed = 0;
    common->num_states_in_collection = 0;
    common->count_num_processed = 0;
    if (iters_delta_limit >= 0)
    {
        common->max_count_num_processed =
            common->count_num_processed + iters_delta_limit;
    }
    else
    {
        common->max_count_num_processed = LONG_MAX;
    }
    common->count_of_items_in_queue = 0;
    common->tree_recycle_bin = NULL;
    fcs_lock_init(&common->storage_lock);
}

typedef struct
{
#ifndef FCS_DBM_WITHOUT_CACHES
#ifndef FCS_DBM_CACHE_ONLY
    fcs_pre_cache_t pre_cache;
#endif
    fcs_lru_cache_t cache;
#endif
#ifndef FCS_DBM_CACHE_ONLY
    fcs_dbm_store_t store;
#endif

    /* The queue */
    long pre_cache_max_count;
} fcs_dbm__cache_store__common_t;

#ifdef __cplusplus
}
#endif
