#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 28;

use Test::Differences qw(eq_or_diff);

use File::Spec;

use File::Path qw(mkpath);

use lib './t/lib';
use FC_Solve::DepthMultiQueuePrototype;
# use Games::Solitaire::FC_Solve::QueueInC;

my $queue_offload_dir_path = File::Spec->catdir(
    File::Spec->curdir(), "depth-multi-queue-offload-dir"
);
mkpath($queue_offload_dir_path);

# TEST:$c=0;
sub run_queue_tests
{
    my ($blurb_base, $class_name) = @_;

    {
        my $queue = $class_name->new(
            {
                num_items_per_page => 10,
                offload_dir_path => $queue_offload_dir_path,
                first_depth => 100,
                first_item => 1,
            }
        );

        # TEST:$c++;
        ok ($queue, "$blurb_base - Queue was initialized.");

        # TEST:$c++
        is ($queue->get_num_inserted(), 1, "$blurb_base - One item inserted.");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 1, "$blurb_base - One item in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 0, "$blurb_base - no items extracted.");

        $queue->insert(100, 22);

        # TEST:$c++
        is ($queue->get_num_inserted(), 2, "$blurb_base - two items inserted.");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 2, "$blurb_base - Two items in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 0, "$blurb_base - no items extracted.");

        $queue->insert(101, 303);

        # TEST:$c++
        is ($queue->get_num_inserted(), 3, "$blurb_base - 3 items inserted.");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 3, "$blurb_base - 3 items in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 0, "$blurb_base - no items extracted.");

        # TEST:$c++
        eq_or_diff(
            [$queue->extract()],
            [100, 1],
            "First item extracted.",
        );

        # TEST:$c++
        is ($queue->get_num_inserted(), 3, "$blurb_base - 3 items inserted.");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 2, "$blurb_base - 2 items in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 1, "$blurb_base - 1 items extracted.");

        # TEST:$c++
        eq_or_diff(
            [$queue->extract()],
            [100, 22],
            "Second item extracted.",
        );

        # TEST:$c++
        is ($queue->get_num_inserted(), 3, "$blurb_base - 3 items inserted.");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 1, "$blurb_base - 1 items in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 2, "$blurb_base - 2 items extracted.");

        # TEST:$c++
        eq_or_diff(
            [$queue->extract()],
            [101, 303],
            "Second item extracted.",
        );

        # TEST:$c++
        is ($queue->get_num_inserted(), 3, "$blurb_base - 3 items inserted.");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 0, "$blurb_base - 0 items in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 3, "$blurb_base - 3 items extracted.");
    }

    {
        my $queue = $class_name->new(
            {
                num_items_per_page => 10,
                offload_dir_path => $queue_offload_dir_path,
                first_depth => 50,
                first_item => 1,
            }
        );

        # TEST:$c++;
        ok ($queue, "$blurb_base - Queue was initialized.");

        $queue->insert(100, 2209);

        # TEST:$c++
        eq_or_diff(
            [$queue->extract()],
            [50, 1],
            "First item extracted.",
        );

        # TEST:$c++
        eq_or_diff(
            [$queue->extract()],
            [100, 2209],
            "Non consecutive depths.",
        );

        # TEST:$c++
        is ($queue->get_num_inserted(), 2, "$blurb_base - Nonconsecutive inserted");
        # TEST:$c++
        is ($queue->get_num_items_in_queue(), 0, "$blurb_base - Nonconsecutive items in queue.");

        # TEST:$c++
        is ($queue->get_num_extracted(), 2, "$blurb_base - Nonconsecutive extracted.");
    }

    return;
}
# TEST:$run_queue_tests=$c;

# TEST*$run_queue_tests
run_queue_tests('Perl queue', 'FC_Solve::DepthMultiQueuePrototype');
#====TEST*$run_queue_tests
# run_queue_tests('C queue', 'Games::Solitaire::FC_Solve::QueueInC');
