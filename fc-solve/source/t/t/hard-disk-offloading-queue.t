#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1131;
use File::Spec ();
use File::Path qw(mkpath);

package FC_Solve::QueueInC;

use Config;
use Inline;

my $IS_WIN = ( $^O eq "MSWin32" );

sub load
{
    my ($self) = @_;

    my $src = <<'EOF';
#define FCS_DBM_USE_OFFLOADING_QUEUE

/*
 * offloading_queue.h - header file for the offloading-to-hard-disk
 * queue.
 */

#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <unistd.h>

#include "config.h"
#include "state.h"

typedef const unsigned char *fcs_offloading_queue_item_t;
#if !defined(FCS_DBM_USE_OFFLOADING_QUEUE)

typedef struct fcs_Q_item_wrapper_struct
{
    fcs_offloading_queue_item_t datum;
    struct fcs_Q_item_wrapper_struct *next;
} fcs_Q_item_wrapper_t;

typedef struct
{
    fcs_compact_allocator_t queue_allocator;
    fcs_Q_item_wrapper_t *queue_head, *queue_tail, *queue_recycle_bin;
    long num_inserted, num_items_in_queue, num_extracted;
} fcs_offloading_queue_t;

static inline void fcs_offloading_queue__init(
    fcs_offloading_queue_t *queue, fcs_meta_compact_allocator_t *meta_alloc)
{
    fc_solve_compact_allocator_init(&(queue->queue_allocator), meta_alloc);

    queue->queue_head = queue->queue_tail = queue->queue_recycle_bin = NULL;
    queue->num_inserted = queue->num_items_in_queue = queue->num_extracted = 0;

    return;
}

static inline void fcs_offloading_queue__destroy(fcs_offloading_queue_t *queue)
{
    fc_solve_compact_allocator_finish(&(queue->queue_allocator));
}

static inline fcs_bool_t fcs_offloading_queue__extract(
    fcs_offloading_queue_t *const queue,
    fcs_offloading_queue_item_t *const return_item)
{
    fcs_Q_item_wrapper_t *const item = queue->queue_head;

    if (!item)
    {
        *return_item = NULL;
        return FALSE;
    }

    *return_item = item->datum;

    if (!(queue->queue_head = item->next))
    {
        queue->queue_tail = NULL;
    }

    item->next = queue->queue_recycle_bin;
    queue->queue_recycle_bin = item;

    queue->num_items_in_queue--;
    queue->num_extracted++;

    return TRUE;
}

static inline void fcs_offloading_queue__insert(
    fcs_offloading_queue_t *queue, const fcs_offloading_queue_item_t *datum)
{
    fcs_Q_item_wrapper_t *new_item;

    if (queue->queue_recycle_bin)
    {
        queue->queue_recycle_bin = (new_item = queue->queue_recycle_bin)->next;
    }
    else
    {
        new_item = (fcs_Q_item_wrapper_t *)fcs_compact_alloc_ptr(
            &(queue->queue_allocator), sizeof(*new_item));
    }
    new_item->datum = *datum;
    new_item->next = NULL;

    if (queue->queue_tail)
    {
        queue->queue_tail = queue->queue_tail->next = new_item;
    }
    else
    {
        queue->queue_head = queue->queue_tail = new_item;
    }

    queue->num_inserted++;
    queue->num_items_in_queue++;

    return;
}

/* Implement the standard in-memory queue as a linked list. */
#else

typedef struct
{
    size_t num_items_per_page;
    long page_index, queue_id;
    size_t write_to_idx;
    size_t read_from_idx;
    unsigned char *data;
} fcs_offloading_queue_page_t;

static inline void fcs_offloading_queue_page__recycle(
    fcs_offloading_queue_page_t *const page)
{
    page->write_to_idx = 0;
    page->read_from_idx = 0;
}

static inline void fcs_offloading_queue_page__init(
    fcs_offloading_queue_page_t *const page, const size_t num_items_per_page,
    const long page_index, const long queue_id)
{
    fcs_offloading_queue_page_t new_page = {
        .num_items_per_page = num_items_per_page,
        .page_index = page_index,
        .queue_id = queue_id,
        .data =
            malloc(sizeof(fcs_offloading_queue_item_t) * num_items_per_page)};
    *page = new_page;
    fcs_offloading_queue_page__recycle(page);

    return;
}

static inline void fcs_offloading_queue_page__destroy(
    fcs_offloading_queue_page_t *const page)
{
    free(page->data);
    page->data = NULL;
}

static inline fcs_bool_t fcs_offloading_queue_page__can_extract(
    const fcs_offloading_queue_page_t *const page)
{
    return (page->read_from_idx < page->write_to_idx);
}

static inline void fcs_offloading_queue_page__extract(
    fcs_offloading_queue_page_t *const page,
    fcs_offloading_queue_item_t *const out_item)
{
    memcpy(out_item,
        (page->data + sizeof(*out_item) * ((page->read_from_idx)++)),
        sizeof(*out_item));
}

static inline fcs_bool_t fcs_offloading_queue_page__can_insert(
    const fcs_offloading_queue_page_t *const page)
{
    return (page->write_to_idx < page->num_items_per_page);
}

static inline void fcs_offloading_queue_page__insert(
    fcs_offloading_queue_page_t *const page,
    const fcs_offloading_queue_item_t *const in_item)
{
    memcpy(page->data + ((page->write_to_idx)++) * sizeof(*in_item), in_item,
        sizeof(*in_item));
}

static inline const char *fcs_offloading_queue_page__calc_filename(
    fcs_offloading_queue_page_t *const page, char *const buffer,
    const char *const offload_dir_path)
{
    sprintf(buffer, "%s/fcs_queue%lXq_%020lX.page", offload_dir_path,
        page->queue_id, page->page_index);

    return buffer;
}

static inline void fcs_offloading_queue_page__start_after(
    fcs_offloading_queue_page_t *const page,
    const fcs_offloading_queue_page_t *const other_page)
{
    page->page_index = other_page->page_index + 1;
    fcs_offloading_queue_page__recycle(page);
}

static inline void fcs_offloading_queue_page__bump(
    fcs_offloading_queue_page_t *const page)
{
    fcs_offloading_queue_page__start_after(page, page);
}

static inline void fcs_offloading_queue_page__read_next_from_disk(
    fcs_offloading_queue_page_t *const page, const char *const offload_dir_path)
{
    fcs_offloading_queue_page__bump(page);
    char page_filename[PATH_MAX + 1];
    fcs_offloading_queue_page__calc_filename(
        page, page_filename, offload_dir_path);

    FILE *const f = fopen(page_filename, "rb");
    fread(page->data, sizeof(fcs_offloading_queue_item_t),
        page->num_items_per_page, f);
    fclose(f);

    /* We need to set this limit because it's a read-only page that we
     * retrieve from the disk and otherwise ->can_extract() will return
     * false for most items.
     * */
    page->write_to_idx = page->num_items_per_page;

    unlink(page_filename);
}

static inline void fcs_offloading_queue_page__offload(
    fcs_offloading_queue_page_t *const page, const char *const offload_dir_path)
{
    char page_filename[PATH_MAX + 1];

    fcs_offloading_queue_page__calc_filename(
        page, page_filename, offload_dir_path);

    FILE *const f = fopen(page_filename, "wb");
    fwrite(page->data, sizeof(fcs_offloading_queue_item_t),
        page->num_items_per_page, f);
    fclose(f);
}

typedef struct
{
    int num_items_per_page;
    const char *offload_dir_path;
    long num_inserted, num_items_in_queue, num_extracted;
    long id;
    /*
     * page_idx_to_write_to, page_idx_for_backup and page_idx_to_read_from
     * always point to the two "pages" below, but they can be swapped and
     * page_idx_for_backup may be NULL.
     */
    int page_idx_to_write_to, page_idx_for_backup, page_idx_to_read_from;
    fcs_offloading_queue_page_t pages[2];
} fcs_offloading_queue_t;

const size_t NUM_ITEMS_PER_PAGE = (128 * 1024);
static inline void fcs_offloading_queue__init(
    fcs_offloading_queue_t *const queue, const char *const offload_dir_path,
    const long id)
{
    queue->num_items_per_page = NUM_ITEMS_PER_PAGE;
    queue->offload_dir_path = offload_dir_path;
    queue->num_inserted = queue->num_items_in_queue = queue->num_extracted = 0;
    queue->id = id;

    fcs_offloading_queue_page__init(
        &(queue->pages[0]), NUM_ITEMS_PER_PAGE, 0, queue->id);
    fcs_offloading_queue_page__init(
        &(queue->pages[1]), NUM_ITEMS_PER_PAGE, 0, queue->id);

    queue->page_idx_to_read_from = queue->page_idx_to_write_to = 0;
    queue->page_idx_for_backup = 1;
}

static inline void fcs_offloading_queue__destroy(fcs_offloading_queue_t *queue)
{
    fcs_offloading_queue_page__destroy(&(queue->pages[0]));
    fcs_offloading_queue_page__destroy(&(queue->pages[1]));
}

static inline void fcs_offloading_queue__insert(
    fcs_offloading_queue_t *queue, const fcs_offloading_queue_item_t *item)
{
    if (!fcs_offloading_queue_page__can_insert(
            queue->pages + queue->page_idx_to_write_to))
    {
        if (queue->pages[queue->page_idx_to_read_from].page_index !=
            queue->pages[queue->page_idx_to_write_to].page_index)
        {
            fcs_offloading_queue_page__offload(
                queue->pages + queue->page_idx_to_write_to,
                queue->offload_dir_path);
            fcs_offloading_queue_page__bump(
                queue->pages + queue->page_idx_to_write_to);
        }
        else
        {
            queue->page_idx_to_write_to = queue->page_idx_for_backup;
            fcs_offloading_queue_page__start_after(
                queue->pages + queue->page_idx_to_write_to,
                queue->pages + queue->page_idx_to_read_from);
            queue->page_idx_for_backup = -1;
        }
    }

    fcs_offloading_queue_page__insert(
        queue->pages + queue->page_idx_to_write_to, item);

    queue->num_inserted++;
    queue->num_items_in_queue++;
}

static inline fcs_bool_t fcs_offloading_queue__extract(
    fcs_offloading_queue_t *const queue,
    fcs_offloading_queue_item_t *const return_item)
{
    if (queue->num_items_in_queue == 0)
    {
        *return_item = NULL;
        return FALSE;
    }

    if (!fcs_offloading_queue_page__can_extract(
            queue->pages + queue->page_idx_to_read_from))
    {
        /* Cannot really happen due to the num_items_in_queue check.
         *
         * if (queue->_page_idx_to_read_from->page_index ==
         *     queue->_page_idx_to_write_to->page_index)
        */
        if (queue->pages[queue->page_idx_to_read_from].page_index + 1 ==
            queue->pages[queue->page_idx_to_write_to].page_index)
        {
            queue->page_idx_for_backup = queue->page_idx_to_read_from;
            queue->page_idx_to_read_from = queue->page_idx_to_write_to;
        }
        else
        {
            fcs_offloading_queue_page__read_next_from_disk(
                queue->pages + queue->page_idx_to_read_from,
                queue->offload_dir_path);
        }
    }

    queue->num_items_in_queue--;
    queue->num_extracted++;

    fcs_offloading_queue_page__extract(
        queue->pages + queue->page_idx_to_read_from, return_item);

    return TRUE;
}

#endif

typedef struct
{
    fcs_offloading_queue_t q;
} QueueInC;

SV* _proto_new(int num_items_per_page, const char * offload_dir_path, long queue_id) {
        QueueInC * s;

        New(42, s, 1, QueueInC);

        fcs_offloading_queue__init(&(s->q), strdup(offload_dir_path), queue_id);
        SV*      obj_ref = newSViv(0);
        SV*      obj = newSVrv(obj_ref, "FC_Solve::QueueInC");
        sv_setiv(obj, (IV)s);
        SvREADONLY_on(obj);
        return obj_ref;
}

static inline QueueInC * deref(SV * const obj) {
    return (QueueInC*)SvIV(SvRV(obj));
}

static inline fcs_offloading_queue_t * q(SV * const obj) {
    return &(deref(obj)->q);
}

void insert(SV* obj, int item_i) {
    fcs_offloading_queue_item_t item = (fcs_offloading_queue_item_t)item_i;
    fcs_offloading_queue__insert(q(obj), &item);
}

SV* extract(SV* obj) {
    fcs_offloading_queue_item_t item;

    return (fcs_offloading_queue__extract(q(obj), &item))
    ? newSViv((int)item)
    : &PL_sv_undef;
}

long get_num_inserted(SV* obj) {
    return q(obj)->num_inserted;
}

long get_num_items_in_queue(SV* obj) {
    return q(obj)->num_items_in_queue;
}

long get_num_extracted(SV* obj) {
    return q(obj)->num_extracted;
}

void DESTROY(SV* obj) {
  QueueInC * s = deref(obj);
  free(s->q.offload_dir_path);
  fcs_offloading_queue__destroy(&s->q);
  Safefree(s);
}

EOF

    my $pkg = 'FC_Solve::QueueInC';

    my @workaround_for_a_heisenbug =
        ( $IS_WIN ? ( optimize => '-g' ) : () );

    my $ccflags = "$Config{ccflags} -std=gnu99";
    if ($IS_WIN)
    {
        $ccflags =~ s#(^|\s)-[Of][a-zA-Z0-9_\-]*#$1#gms;
    }

    my @inline_params = (
        C                 => $src,
        name              => $pkg,
        NAME              => $pkg,
        INC               => "-I" . $ENV{FCS_PATH} . " -I" . $ENV{FCS_SRC_PATH},
        CCFLAGS           => $ccflags,
        CLEAN_AFTER_BUILD => 0,
        LIBS              => "-L$ENV{FCS_PATH}",
        @workaround_for_a_heisenbug,
    );

=begin debug

    if ($IS_WIN)
    {
        require Data::Dumper;
        print STDERR "inline_params = <<<<<\n", Data::Dumper::Dumper( \@inline_params ),
            ">>>>>>\n";
    }

=end debug

=cut

    Inline->bind(@inline_params);

    return;
}

__PACKAGE__->load;

sub new
{
    my ( $class, $args ) = @_;

    return FC_Solve::QueueInC::_proto_new(
        $args->{num_items_per_page},
        $args->{offload_dir_path},
        ( $args->{queue_id} || 0 )
    );
}

package main;

my $queue_offload_dir_path =
    File::Spec->catdir( File::Spec->curdir(), "queue-offload-dir" );
mkpath($queue_offload_dir_path);

# TEST:$c=0;
sub run_queue_tests
{
    my ( $blurb_base, $class_name ) = @_;

    {
        my $queue = $class_name->new(
            {
                num_items_per_page => 10,
                offload_dir_path   => $queue_offload_dir_path,
            }
        );

        # TEST:$c++;
        ok( $queue, "$blurb_base - Queue was initialized." );

        # TEST:$c++
        is( $queue->get_num_inserted(),
            0, "$blurb_base - No items were inserted yet." );

        # TEST:$c++
        is( $queue->get_num_items_in_queue(),
            0, "$blurb_base - No items in queue." );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            0, "$blurb_base - no items extracted." );

        $queue->insert(1);

        # TEST:$c++
        is( $queue->get_num_inserted(), 1, "$blurb_base - 1 item." );

        # TEST:$c++
        is( $queue->get_num_items_in_queue(),
            1, "$blurb_base - 1 items in queue." );

        $queue->insert(200);

        # TEST:$c++
        is( $queue->get_num_inserted(), 2, "$blurb_base - 2 item." );

        # TEST:$c++
        is( $queue->get_num_items_in_queue(),
            2, "$blurb_base - 2 items in queue." );

        $queue->insert(33);

        # TEST:$c++
        is( $queue->get_num_inserted(), 3, "$blurb_base - 3 item." );

        # TEST:$c++
        is( $queue->get_num_items_in_queue(),
            3, "$blurb_base - 3 items in queue." );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            0, "$blurb_base - no items extracted." );

        # TEST:$c++
        is( scalar( $queue->extract() ),
            1, "$blurb_base - Extracted 1 from queue." );

        # TEST:$c++;
        is( $queue->get_num_inserted(),
            3, "$blurb_base - 3 Items were inserted so far." );

        # TEST:$c++;
        is( $queue->get_num_items_in_queue(),
            2, "$blurb_base - 2 items in queue (after one extracted." );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            1, "$blurb_base - 1 item was extracted." );

        # TEST:$c++
        is( scalar( $queue->extract() ),
            200, "$blurb_base - Extracted 1 from queue." );

        # TEST:$c++;
        is( $queue->get_num_inserted(),
            3, "$blurb_base - 3 Items were inserted so far." );

        # TEST:$c++;
        is( $queue->get_num_items_in_queue(),
            1, "$blurb_base - 1 items in queue (after two extracted.)" );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            2, "$blurb_base - 2 items were extracted." );

        # Now trying to add an item after a few were extracted and see how
        # the statistics are affected.
        $queue->insert(4);

        # TEST:$c++;
        is( $queue->get_num_inserted(),
            4, "$blurb_base - 4 Items were inserted so far." );

        # TEST:$c++;
        is( $queue->get_num_items_in_queue(), 2,
"$blurb_base - 2 items in queue (after two extracted and one added.)"
        );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            2, "$blurb_base - 2 items were extracted." );
    }

    {
        my $queue = $class_name->new(
            {
                num_items_per_page => 10,
                offload_dir_path   => $queue_offload_dir_path,
            }
        );

        my $map_idx_to_item = sub { my ($idx) = @_; return $idx * 3 + 1; };

        # TEST:$num_items=1000;
        foreach my $item_idx ( 1 .. 1_000 )
        {
            $queue->insert( $map_idx_to_item->($item_idx) );
        }

        foreach my $item_idx ( 1 .. 1_000 )
        {
            # TEST:$c=$c+$num_items;
            is(
                scalar( $queue->extract() ),
                $map_idx_to_item->($item_idx),
                "$blurb_base - Testing the extraction of item no. $item_idx"
            );
        }

        # Now let's test the final statistics.

        # TEST:$c++;
        is( $queue->get_num_inserted(),
            1_000, "$blurb_base - 1,000 items were inserted" );

        # TEST:$c++;
        is( $queue->get_num_items_in_queue(),
            0, "$blurb_base - 0 items in queue." );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            1_000, "$blurb_base - 1,000 items were extracted in total." );

        # Now let's add more items after the queue is empty.

        # TEST:$num_items=100;
        foreach my $item_idx ( 1 .. 100 )
        {
            $queue->insert( $map_idx_to_item->($item_idx) );
        }

        # TEST:$c++;
        is( $queue->get_num_inserted(),
            1_100, "$blurb_base - 1,100 items were inserted" );

        # TEST:$c++;
        is( $queue->get_num_items_in_queue(),
            100, "$blurb_base - 100 items in queue." );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            1_000, "$blurb_base - 1,000 items were extracted in total." );

        foreach my $item_idx ( 1 .. 100 )
        {
            # TEST:$c=$c+$num_items;
            is(
                scalar( $queue->extract() ),
                $map_idx_to_item->($item_idx),
                "$blurb_base - Testing the extraction of item no. $item_idx"
            );
        }

        # TEST:$c++;
        is( $queue->get_num_inserted(),
            1_100, "$blurb_base - 1,100 items were inserted" );

        # TEST:$c++;
        is( $queue->get_num_items_in_queue(),
            0, "$blurb_base - 100 items in queue." );

        # TEST:$c++
        is( $queue->get_num_extracted(),
            1_100, "$blurb_base - 1,100 items were extracted in total." );

    }

    return;
}

# TEST:$run_queue_tests=$c;

# TEST*$run_queue_tests
run_queue_tests( 'C queue', 'FC_Solve::QueueInC' );
