package Shlomif::DocBookClean;

use strict;
use warnings;

sub cleanup_docbook
{
    my ($str_ref) = @_;

    # It's a kludge
    $$str_ref =~ s#<head profile="">#<head>#g;
    $$str_ref =~
s# (?:xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"|xml:space="preserve")([ >]|/>)#$1#g;
    $$str_ref =~ s{ type="(?:1|disc)"}{}g;
    $$str_ref =~ s{<hr[^/]*/>}{<hr />}g;
    $$str_ref =~ s{ target="_top"}{}g;
    $$str_ref =~ s{ shape="rect"}{}g;
    $$str_ref =~ s{ align="left"}{}g;
    $$str_ref =~ s{ align="right"}{}g;
    $$str_ref =~ s{ valign="top"}{}g;
    $$str_ref =~ s{ border="0"}{}g;
    $$str_ref =~ s{ summary="[^"]*"}{}g;

    return;
}

1;
__END__

=head1 COPYRIGHT & LICENSE

Copyright 2018 by Shlomi Fish

This program is distributed under the MIT / Expat License:
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
