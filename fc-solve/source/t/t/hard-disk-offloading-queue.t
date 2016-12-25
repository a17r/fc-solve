#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

package FC_Solve::QueueInC;

use Config;
use Inline;

my $IS_WIN = ( $^O eq "MSWin32" );

sub load {
    my ($self) = @_;

    my $src = <<'EOF';
#include <string.h>

typedef struct
{
    const char *string_ptr;
} fcs_offloading_queue_t;

typedef struct
{
    fcs_offloading_queue_t q;
} QueueInC;

SV* _proto_new(const char * string_ptr) {
        QueueInC * s;

        New(42, s, 1, QueueInC);

        s->q.string_ptr = strdup(string_ptr);
        SV*      obj_ref = newSViv(0);
        SV*      obj = newSVrv(obj_ref, "FC_Solve::QueueInC");
        sv_setiv(obj, (IV)s);
        SvREADONLY_on(obj);
        return obj_ref;
}

void DESTROY(SV* obj) {
  QueueInC * s = (QueueInC*)SvIV(SvRV(obj));
  free((void*)s->q.string_ptr);
  Safefree(s);
}

EOF

    my $pkg = 'FC_Solve::QueueInC';

    my @workaround_for_a_heisenbug =
      ( $IS_WIN ? ( optimize => '-g' ) : () );

    my $ccflags = "$Config{ccflags} -std=gnu99";
    if ($IS_WIN) {
        $ccflags =~ s#(^|\s)-[Of][a-zA-Z0-9_\-]*#$1#gms;
    }

    Inline->bind(
        C                 => $src,
        name              => $pkg,
        NAME              => $pkg,
        CCFLAGS           => $ccflags,
        CLEAN_AFTER_BUILD => 0,
        @workaround_for_a_heisenbug,
    );

    return;
}

__PACKAGE__->load;

package main;

my $str = "./foobar/queue-offload-dir";
{
    my $queue = FC_Solve::QueueInC::_proto_new($str);
}

{
    my $queue = FC_Solve::QueueInC::_proto_new($str);

    my $map_idx_to_item = sub { my ($idx) = @_; return $idx * 3 + 1; };
}

# TEST
pass("Placeholder test");

=head1 COPYRIGHT & LICENSE

Copyright 2016 by Shlomi Fish

This program is distributed under the MIT/Expat License:
L<http://www.opensource.org/licenses/mit-license.php>

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
