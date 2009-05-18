#!/usr/bin/perl -w

use strict;
#use File::stat;

use PDL;
use PDL::IO::FastRaw;

use MyInput;


my $start_board = 1;

my $num_boards = 32000;

my $script_filename = "-";

my $trace = 0;

my $rle = 1;

if (scalar(@ARGV))
{
    while (my $arg = shift(@ARGV))
    {
        if ($arg eq "-o")
        {
            $script_filename = shift;
        }
        elsif ($arg eq "-n")
        {
            $num_boards = shift;
        }
        elsif ($arg eq "-t")
        {
            $trace = 1;
        }
        elsif ($arg eq "--norle")
        {
            $rle = 0;
        }
        elsif ($arg eq "-s")
        {
            $start_board = shift;
        }
    }
}

my $sel_scans = MyInput::get_selected_scan_list($start_board, $num_boards);
my @selected_scans = @$sel_scans;
    
#my $scans_data = [];
#my $scans_data = zeroes($num_boards, scalar(@selected_scans));

my $scans_data = MyInput::get_scans_data($start_board, $num_boards, \@selected_scans);

my $orig_scans_data = $scans_data->copy();

my @quotas = ((350) x 500);
my @chosen_scans = ();

my $total = 0;
my $q = 0;
my $total_iters = 0;

foreach my $q_more (@quotas)
{
    $q += $q_more;
    my $num_solved = sumover(($scans_data <= $q) & ($scans_data > 0));
    my ($min, $max, $min_ind, $max_ind) = minmaximum($num_solved);
    if ($max == 0)
    {
        next;
    }
    if (0)
    {
        my $orig_max = $max;
        while ($max == $orig_max)
        {
            $q--;
            $num_solved = sumover(($scans_data <= $q) & ($scans_data > 0));
            ($min, $max, $min_ind, $max_ind) = minmaximum($num_solved);
        }
        $q++;
        $num_solved = sumover(($scans_data <= $q) & ($scans_data > 0));
        ($min, $max, $min_ind, $max_ind) = minmaximum($num_solved);
    }   
    push @chosen_scans, { 'q' => $q, 'ind' => $max_ind };
    $total += $max;
    print "$q \@ $max_ind ($total solved)\n";
    my $this_scan_result = ($scans_data->slice(":,$max_ind"));
    $total_iters += sum((($this_scan_result <= $q) & ($this_scan_result > 0)) * $this_scan_result);
    my $indexes = which(($this_scan_result > $q) | ($this_scan_result < 0));
    
    $total_iters += ($indexes->nelem() * $q);
    if ($total == $num_boards)
    {
        print "Solved all!\n";
        last;
    }    
    
    $scans_data = $scans_data->dice($indexes, "X")->copy();
    $this_scan_result = $scans_data->slice(":,$max_ind")->copy();
    #$scans_data->slice(":,$max_ind") *= 0;
    $scans_data->slice(":,$max_ind") .= (($this_scan_result - $q) * ($this_scan_result > 0)) +
        ($this_scan_result * ($this_scan_result < 0));

    $q = 0;
}

# print "scans_data = " , $scans_data, "\n";
print "total_iters = $total_iters\n";

if ($script_filename eq "-")
{
    open SCRIPT, ">&STDOUT";
}
else
{
    open SCRIPT, ">$script_filename";    
}

if ($rle)
{
    my (@a);
    my $scan = shift(@chosen_scans);

    while (my $next_scan = shift(@chosen_scans))
    {
        if ($next_scan->{'ind'} == $scan->{'ind'})
        {
            $scan->{'q'} += $next_scan->{'q'};
        }
        else
        {
            push @a, $scan;
            $scan = $next_scan;
        }
    }
    push @a, $scan;
    @chosen_scans = @a;
}

# Construct the command line
my $cmd_line = "freecell-solver-range-parallel-solve $start_board " . ($start_board + $num_boards - 1) . " 1 \\\n" .
    join(" -nst \\\n", map { $_->{'cmd_line'} . " -step 500 --st-name " . $_->{'id'} } @selected_scans) . " \\\n" .
    "--prelude \"" . join(",", map { $_->{'q'} . "\@" . $selected_scans[$_->{'ind'}]->{'id'} } @chosen_scans) ."\"";
    
print SCRIPT $cmd_line;
print SCRIPT "\n\n\n";

close(SCRIPT);

# Analyze the results

if ($trace)
{
    foreach my $board (1 .. $num_boards)
    {
        my $total_iters = 0;
        my @info = list($orig_scans_data->slice(($board-1).",:"));
        print ("\@info=". join(",", @info). "\n");
        foreach my $s (@chosen_scans)
        {
            if (($info[$s->{'ind'}] > 0) && ($info[$s->{'ind'}] <= $s->{'q'}))
            {
                $total_iters += $info[$s->{'ind'}];
                last;
            }
            else
            {
                if ($info[$s->{'ind'}] > 0)
                {
                    $info[$s->{'ind'}] -= $s->{'q'};
                }
                $total_iters += $s->{'q'};
            }
        }
        print (($board+$start_board-1) . ": $total_iters\n");
    }
}
