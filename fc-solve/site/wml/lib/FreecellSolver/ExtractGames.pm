package FreecellSolver::ExtractGames;

use strict;
use warnings;
use IO::All qw/ io /;
use CGI qw/ escapeHTML /;
use File::Basename qw/ dirname /;

use MooX qw/ late /;

has 'games' => (is => 'ro', default => sub {
        my @lines = io->file(dirname(__FILE__).'/../../../../source/USAGE.txt')->chomp->getlines;
        my @ret;
        foreach my $l (@lines)
        {
            if ($l =~ /\A--game \[game\]/ .. $l =~ /\AExamples/)
            {
                if (my ($id, $name) = ($l =~ m#\A\|\+([a-zA-Z_]+)\+\s+\|([A-Za-z' \(\)]*)\z#))
                {
                    push @ret, {id => $id, name => $name};
                }
            }
        }
        return \@ret;
    });

sub calc_html
{
    my $self = shift;

    return qq#<label for="game_type">Game Type:</label><select id="game_type">#
        . join('', map { my $sel = $_->{id} eq 'freecell' ? qq# selected="selected"# : ''; qq#<option value="$_->{id}"$sel>@{[escapeHTML($_->{name})]}</option># } @{$self->games()})
        . "</select>";

    return;
}

1;