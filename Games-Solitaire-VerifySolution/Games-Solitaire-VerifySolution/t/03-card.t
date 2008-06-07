#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 18;
use Games::Solitaire::VerifySolution::Card;

{
    my $card = Games::Solitaire::VerifySolution::Card->new(
        {
            string => "AH",
        },
    );

    # TEST
    is ($card->rank(), 1, "Rank of AH is 1");

    # TEST
    is ($card->suit(), "H", "Suit of AH is Hearts");

    # TEST
    is ($card->color(), "red", "Color of AH is red");
}

{
    my $card = Games::Solitaire::VerifySolution::Card->new(
        {
            string => "QC",
        },
    );

    # TEST
    is ($card->rank(), 12, "Rank of QC is 12");

    # TEST
    is ($card->suit(), "C", "Suit of QC is Clubs");

    # TEST
    is ($card->color(), "black", "Color of QC is black");
}

{
    my $card = Games::Solitaire::VerifySolution::Card->new(
        {
            string => "KS",
        },
    );

    # TEST
    is ($card->rank(), 13, "Rank of KS is 13");

    # TEST
    is ($card->suit(), "S", "Suit of KS is Spades");

    # TEST
    is ($card->color(), "black", "Color of KS is black");
}

{
    my $card = Games::Solitaire::VerifySolution::Card->new(
        {
            string => "5H",
        },
    );

    # TEST
    is ($card->rank(), 5, "Rank of 5H is 5");

    # TEST
    is ($card->suit(), "H", "Suit of 5H is Hearts");

    # TEST
    is ($card->color(), "red", "Color of 5H is red");
}

{
    my $card = Games::Solitaire::VerifySolution::Card->new(
        {
            string => "5H",
        },
    );

    # TEST
    is ($card->rank(), 5, "Rank of 5H is 5");

    # TEST
    is ($card->suit(), "H", "Suit of 5H is Hearts");

    # TEST
    is ($card->color(), "red", "Color of 5H is red");

    my $copy = $card->clone();

    $card->rank(1);
    $card->suit("C");

    # TEST
    is ($copy->rank(), 5, "Rank of copy is 5");

    # TEST
    is ($copy->suit(), "H", "Suit of copy is Hearts");

    # TEST
    is ($copy->color(), "red", "Color of copy is red");

}
