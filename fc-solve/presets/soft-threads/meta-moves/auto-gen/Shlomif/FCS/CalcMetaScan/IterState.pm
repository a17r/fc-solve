package Shlomif::FCS::CalcMetaScan::IterState;

use strict;
use warnings;

use PDL ();

use base 'Shlomif::FCS::CalcMetaScan::Base';

use vars (qw(@fields %fields_map));
@fields = (qw(
    _main
    _num_solved
    _quota
    _scan_idx
));

use Exception::Class
(
    'Shlomif::FCS::CalcMetaScan::Error::OutOfQuotas'
);

%fields_map = (map { $_ => 1 } @fields);

__PACKAGE__->mk_acc_ref(\@fields);

sub _init
{
    my $self = shift;

    my $args = shift;

    $self->_quota( $args->{'quota'} );
    $self->_num_solved( $args->{'num_solved'} );
    $self->_scan_idx( $args->{'scan_idx'} );

    return 0;
}

sub attach_to
{
    my $self = shift;
    my $main_obj = shift;

    $self->_main($main_obj);

    return;
}

sub get_chosen_struct
{
    my $self = shift;
    return
        Shlomif::FCS::CalcMetaScan::ScanRun->new(
            {
                iters => $self->_quota(), 
                scan => $self->_scan_idx() 
            }
        );
}

sub detach
{
    my $self = shift;
    $self->_main(undef);
}

sub idx_slice
{
    my $self = shift;

    my $scans_data = $self->_main()->_scans_data();

    my @dims = $scans_data->dims();

    return $scans_data->slice(
        join(",",
            ":", $self->_scan_idx(), (("(0)") x (@dims-2))
        )
    );
}

sub update_total_iters
{
    my $state = shift;

    # $r is the result of this scan.
    my $r = $state->idx_slice();
    
    # Add the total iterations for all the states that were solved by
    # this scan.
    $state->_main()->_add_to_total_iters(
        PDL::sum((($r <= $state->_quota()) & ($r > 0)) * $r)
    );
    
    # Find all the states that weren't solved.
    my $indexes = PDL::which(($r > $state->_quota()) | ($r < 0));
    
    # Add the iterations for all the states that have not been solved
    # yet.
    $state->_main()->_add_to_total_iters($indexes->nelem() * $state->_quota());
    
    # Keep only the states that have not been solved yet.
    $state->_main()->_scans_data(
        $state->_main()->_scans_data()->dice($indexes, "X")->copy()
    );
}

sub update_idx_slice
{
    my $state = shift;
    my $r = $state->idx_slice()->copy();
    # $r cannot be 0, because the ones that were 0, were already solved
    # in $state->update_total_iters().
    my $idx_slice = $state->idx_slice();
    $idx_slice .= 
        (($r > 0) * ($r - $state->_quota())) + 
        (($r < 0) * ($r                  ));
}

sub _mark_as_used
{
    my $state = shift;
    $state->_main()->_selected_scans()->[$state->_scan_idx()]->mark_as_used();

    return;
}

sub _add_chosen
{
    my $state = shift;

    push @{$state->_main()->chosen_scans()}, $state->get_chosen_struct();

    return;
}

sub _update_total_boards_solved
{
    my $state = shift;

    $state->_main()->add('_total_boards_solved', $state->_num_solved());

    return;
}

sub _trace_wrapper
{
    my $state = shift;

    $state->_main()->_trace(
        {
            'iters_quota' => $state->_quota(),
            'selected_scan_idx' => $state->_scan_idx(),
            'total_boards_solved' => $state->_main()->_total_boards_solved(),
        }
    );

    return;
}

sub register_params
{
    my $state = shift;

    $state->_add_chosen();
    $state->_mark_as_used();
    $state->_update_total_boards_solved();
    $state->_trace_wrapper();

    return;
}

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2010 Shlomi Fish

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

1;
