#!/usr/bin/perl

use strict;
use warnings;

use Games::Solitaire::Verify::Solution::ExpandMultiCardMoves::Lax;

# make_pysol_freecell_board.py -F -t 24 | fc-solve -sam -sel -p -t
my $input_text = <<'END_OF_SOL';
-=-=-=-=-=-=-=-=-=-=-=-

Foundations: H-0 C-0 D-0 S-0
Freecells:
: 4C 2C 9C 8C QS 4S 2H
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D AS
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S AD 8H JD
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 3 to the foundations

Foundations: H-0 C-0 D-0 S-A
Freecells:
: 4C 2C 9C 8C QS 4S 2H
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S AD 8H JD
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 6 to freecell 0

Foundations: H-0 C-0 D-0 S-A
Freecells:  JD
: 4C 2C 9C 8C QS 4S 2H
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S AD 8H
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 6 to freecell 1

Foundations: H-0 C-0 D-0 S-A
Freecells:  JD  8H
: 4C 2C 9C 8C QS 4S 2H
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S AD
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 6 to the foundations

Foundations: H-0 C-0 D-A S-A
Freecells:  JD  8H
: 4C 2C 9C 8C QS 4S 2H
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 0 to freecell 2

Foundations: H-0 C-0 D-A S-A
Freecells:  JD  8H  2H
: 4C 2C 9C 8C QS 4S
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 0 to freecell 3

Foundations: H-0 C-0 D-A S-A
Freecells:  JD  8H  2H  4S
: 4C 2C 9C 8C QS
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S
: 7S 6C 7D 4D 8S 9D


====================

Move a card from freecell 0 to stack 0

Foundations: H-0 C-0 D-A S-A
Freecells:      8H  2H  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S 6S
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 6 to freecell 0

Foundations: H-0 C-0 D-A S-A
Freecells:  6S  8H  2H  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH 5S
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 6 to stack 3

Foundations: H-0 C-0 D-A S-A
Freecells:  6S  8H  2H  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: AH
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 6 to the foundations

Foundations: H-A C-0 D-A S-A
Freecells:  6S  8H  2H  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
:
: 7S 6C 7D 4D 8S 9D


====================

Move a card from freecell 2 to the foundations

Foundations: H-2 C-0 D-A S-A
Freecells:  6S  8H      4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H 4H QD
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
:
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 1 to freecell 2

Foundations: H-2 C-0 D-A S-A
Freecells:  6S  8H  QD  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H 4H
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
:
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 1 to stack 6

Foundations: H-2 C-0 D-A S-A
Freecells:  6S  8H  QD  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC 3H
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: 4H
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 1 to the foundations

Foundations: H-3 C-0 D-A S-A
Freecells:  6S  8H  QD  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
: 4H
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 6 to the foundations

Foundations: H-4 C-0 D-A S-A
Freecells:  6S  8H  QD  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C AC
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
:
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 1 to the foundations

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H  QD  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC 7C
:
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 5 to stack 6

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H  QD  4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC
: 7C
: 7S 6C 7D 4D 8S 9D


====================

Move a card from freecell 2 to stack 5

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H      4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D
: 7H JS KH TS KC QD
: 7C
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 6 to stack 4

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H      4S
: 4C 2C 9C 8C QS JD
: 5H QH 3C
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D 7C
: 7H JS KH TS KC QD
:
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 1 to freecell 2

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 5H QH
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D 7C
: 7H JS KH TS KC QD
:
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 1 to stack 6

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 5H
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D 7C
: 7H JS KH TS KC QD
: QH
: 7S 6C 7D 4D 8S 9D


====================

Move a card from freecell 3 to stack 1

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H  3C
: 4C 2C 9C 8C QS JD
: 5H 4S
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D 7C
: 7H JS KH TS KC QD
: QH
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 1 to freecell 3

Foundations: H-4 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 5H
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D 7C
: 7H JS KH TS KC QD
: QH
: 7S 6C 7D 4D 8S 9D


====================

Move a card from stack 1 to the foundations

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
:
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH 6D 5S
: 2D KD TH TC TD 8D 7C
: 7H JS KH TS KC QD
: QH
: 7S 6C 7D 4D 8S 9D


====================

Move 2 cards from stack 3 to stack 4

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
:
: QC 9S 6H 9H 3S KS 3D
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD
: QH
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 2 to stack 1

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD
: QH
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 6 to stack 2

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD
:
: 7S 6C 7D 4D 8S 9D


====================

Move 1 cards from stack 7 to stack 6

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD
: 9D
: 7S 6C 7D 4D 8S


====================

Move 1 cards from stack 7 to stack 6

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H  3C  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD
: 9D 8S
: 7S 6C 7D 4D


====================

Move a card from freecell 2 to stack 7

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H      4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD
: 9D 8S
: 7S 6C 7D 4D 3C


====================

Move 2 cards from stack 7 to stack 4

Foundations: H-5 C-A D-A S-A
Freecells:  6S  8H      4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD
: 9D 8S
: 7S 6C 7D


====================

Move a card from freecell 0 to stack 7

Foundations: H-5 C-A D-A S-A
Freecells:      8H      4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C JH
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 3 to freecell 2

Foundations: H-5 C-A D-A S-A
Freecells:      8H  JH  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC 5C
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 3 to freecell 0

Foundations: H-5 C-A D-A S-A
Freecells:  5C  8H  JH  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S JC
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD
: 9D 8S
: 7S 6C 7D 6S


====================

Move 1 cards from stack 3 to stack 5

Foundations: H-5 C-A D-A S-A
Freecells:  5C  8H  JH  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 2S
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 3 to the foundations

Foundations: H-5 C-A D-A S-2
Freecells:  5C  8H  JH  4S
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from freecell 3 to stack 3

Foundations: H-5 C-A D-A S-2
Freecells:  5C  8H  JH
: 4C 2C 9C 8C QS JD
: 3D
: QC 9S 6H 9H 3S KS QH
: 5D 4S
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move 1 cards from stack 1 to stack 3

Foundations: H-5 C-A D-A S-2
Freecells:  5C  8H  JH
: 4C 2C 9C 8C QS JD
:
: QC 9S 6H 9H 3S KS QH
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 2 to freecell 3

Foundations: H-5 C-A D-A S-2
Freecells:  5C  8H  JH  QH
: 4C 2C 9C 8C QS JD
:
: QC 9S 6H 9H 3S KS
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move 1 cards from stack 2 to stack 1

Foundations: H-5 C-A D-A S-2
Freecells:  5C  8H  JH  QH
: 4C 2C 9C 8C QS JD
: KS
: QC 9S 6H 9H 3S
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 2 to the foundations

Foundations: H-5 C-A D-A S-3
Freecells:  5C  8H  JH  QH
: 4C 2C 9C 8C QS JD
: KS
: QC 9S 6H 9H
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from freecell 3 to stack 1

Foundations: H-5 C-A D-A S-3
Freecells:  5C  8H  JH
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H 9H
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 2 to freecell 3

Foundations: H-5 C-A D-A S-3
Freecells:  5C  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from freecell 0 to stack 2

Foundations: H-5 C-A D-A S-3
Freecells:      8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H 5C
: 5D 4S 3D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 3 to freecell 0

Foundations: H-5 C-A D-A S-3
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H 5C
: 5D 4S
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 3 to the foundations

Foundations: H-5 C-A D-A S-4
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H 5C
: 5D
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move 1 cards from stack 3 to stack 7

Foundations: H-5 C-A D-A S-4
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H 5C
:
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S 5D


====================

Move 1 cards from stack 2 to stack 3

Foundations: H-5 C-A D-A S-4
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 6H
: 5C
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S 5D


====================

Move a card from stack 2 to the foundations

Foundations: H-6 C-A D-A S-4
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S
: 5C
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S 5D


====================

Move a card from freecell 1 to stack 2

Foundations: H-6 C-A D-A S-4
Freecells:  3D      JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C
: 2D KD TH TC TD 8D 7C 6D 5S 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S 5D


====================

Move 2 cards from stack 4 to stack 3

Foundations: H-6 C-A D-A S-4
Freecells:  3D      JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D 5S
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S 5D


====================

Move a card from stack 4 to the foundations

Foundations: H-6 C-A D-A S-5
Freecells:  3D      JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S 5D


====================

Move a card from stack 7 to freecell 1

Foundations: H-6 C-A D-A S-5
Freecells:  3D  5D  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D 6S


====================

Move a card from stack 7 to the foundations

Foundations: H-6 C-A D-A S-6
Freecells:  3D  5D  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S
: 7S 6C 7D


====================

Move 1 cards from stack 7 to stack 6

Foundations: H-6 C-A D-A S-6
Freecells:  3D  5D  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D
: 7S 6C


====================

Move a card from freecell 1 to stack 7

Foundations: H-6 C-A D-A S-6
Freecells:  3D      JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D
: 7S 6C 5D


====================

Move 2 cards from stack 7 to stack 6

Foundations: H-6 C-A D-A S-6
Freecells:  3D      JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
: 7S


====================

Move a card from stack 7 to the foundations

Foundations: H-6 C-A D-A S-7
Freecells:  3D      JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S 8H
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
:


====================

Move a card from stack 2 to freecell 1

Foundations: H-6 C-A D-A S-7
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC 9S
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
:


====================

Move 1 cards from stack 2 to stack 7

Foundations: H-6 C-A D-A S-7
Freecells:  3D  8H  JH  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
: 9S


====================

Move a card from freecell 2 to stack 2

Foundations: H-6 C-A D-A S-7
Freecells:  3D  8H      9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
: 9S


====================

Move a card from freecell 1 to stack 7

Foundations: H-6 C-A D-A S-7
Freecells:  3D          9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
: 5C 4D 3C
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move 3 cards from stack 3 to stack 4

Foundations: H-6 C-A D-A S-7
Freecells:  3D          9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
:
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS KC QD JC
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 5 to freecell 2

Foundations: H-6 C-A D-A S-7
Freecells:  3D      JC  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
:
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS KC QD
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 5 to freecell 1

Foundations: H-6 C-A D-A S-7
Freecells:  3D  QD  JC  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
:
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS KC
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move 1 cards from stack 5 to stack 3

Foundations: H-6 C-A D-A S-7
Freecells:  3D  QD  JC  9H
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
: KC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from freecell 3 to stack 5

Foundations: H-6 C-A D-A S-7
Freecells:  3D  QD  JC
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
: KC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from freecell 1 to stack 3

Foundations: H-6 C-A D-A S-7
Freecells:  3D      JC
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from freecell 2 to stack 3

Foundations: H-6 C-A D-A S-7
Freecells:  3D
: 4C 2C 9C 8C QS JD
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 0 to freecell 3

Foundations: H-6 C-A D-A S-7
Freecells:  3D          JD
: 4C 2C 9C 8C QS
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 0 to freecell 1

Foundations: H-6 C-A D-A S-7
Freecells:  3D  QS      JD
: 4C 2C 9C 8C
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move 1 cards from stack 0 to stack 5

Foundations: H-6 C-A D-A S-7
Freecells:  3D  QS      JD
: 4C 2C 9C
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 0 to freecell 2

Foundations: H-6 C-A D-A S-7
Freecells:  3D  QS  9C  JD
: 4C 2C
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 0 to the foundations

Foundations: H-6 C-2 D-A S-7
Freecells:  3D  QS  9C  JD
: 4C
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D 3C
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 4 to the foundations

Foundations: H-6 C-3 D-A S-7
Freecells:  3D  QS  9C  JD
: 4C
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 0 to the foundations

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS  9C  JD
:
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from freecell 0 to stack 0

Foundations: H-6 C-4 D-A S-7
Freecells:      QS  9C  JD
: 3D
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move 1 cards from stack 3 to stack 1

Foundations: H-6 C-4 D-A S-7
Freecells:      QS  9C  JD
: 3D
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from stack 0 to freecell 0

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS  9C  JD
:
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move a card from freecell 2 to stack 0

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS      JD
: 9C
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S 8H


====================

Move 1 cards from stack 7 to stack 0

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS      JD
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S


====================

Move 1 cards from stack 1 to stack 3

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS      JD
: 9C 8H
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 9S


====================

Move a card from stack 7 to freecell 2

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS  9S  JD
: 9C 8H
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
:


====================

Move a card from freecell 0 to stack 7

Foundations: H-6 C-4 D-A S-7
Freecells:      QS  9S  JD
: 9C 8H
: KS QH
: QC JH
: KC QD JC
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 3D


====================

Move 1 cards from stack 3 to stack 1

Foundations: H-6 C-4 D-A S-7
Freecells:      QS  9S  JD
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: 3D


====================

Move a card from stack 7 to freecell 0

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  QS  9S  JD
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
:


====================

Move a card from freecell 1 to stack 7

Foundations: H-6 C-4 D-A S-7
Freecells:  3D      9S  JD
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: QS


====================

Move a card from freecell 3 to stack 7

Foundations: H-6 C-4 D-A S-7
Freecells:  3D      9S
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C 4D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: QS JD


====================

Move a card from stack 4 to freecell 1

Foundations: H-6 C-4 D-A S-7
Freecells:  3D  4D  9S
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D 5C
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: QS JD


====================

Move a card from stack 4 to the foundations

Foundations: H-6 C-5 D-A S-7
Freecells:  3D  4D  9S
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C 5D
: QS JD


====================

Move a card from stack 6 to freecell 3

Foundations: H-6 C-5 D-A S-7
Freecells:  3D  4D  9S  5D
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS 9H 8C
: 9D 8S 7D 6C
: QS JD


====================

Move a card from stack 6 to the foundations

Foundations: H-6 C-6 D-A S-7
Freecells:  3D  4D  9S  5D
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS 9H 8C
: 9D 8S 7D
: QS JD


====================

Move 1 cards from stack 6 to stack 5

Foundations: H-6 C-6 D-A S-7
Freecells:  3D  4D  9S  5D
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS 9H 8C 7D
: 9D 8S
: QS JD


====================

Move a card from stack 6 to the foundations

Foundations: H-6 C-6 D-A S-8
Freecells:  3D  4D  9S  5D
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS 9H 8C 7D
: 9D
: QS JD


====================

Move a card from freecell 2 to the foundations

Foundations: H-6 C-6 D-A S-9
Freecells:  3D  4D      5D
: 9C 8H
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D 7C 6D
: 7H JS KH TS 9H 8C 7D
: 9D
: QS JD


====================

Move 2 cards from stack 4 to stack 0

Foundations: H-6 C-6 D-A S-9
Freecells:  3D  4D      5D
: 9C 8H 7C 6D
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD 8D
: 7H JS KH TS 9H 8C 7D
: 9D
: QS JD


====================

Move a card from stack 4 to freecell 2

Foundations: H-6 C-6 D-A S-9
Freecells:  3D  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC
: QC JH
: KC QD
: 2D KD TH TC TD
: 7H JS KH TS 9H 8C 7D
: 9D
: QS JD


====================

Move 1 cards from stack 4 to stack 1

Foundations: H-6 C-6 D-A S-9
Freecells:  3D  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH
: KC QD
: 2D KD TH TC
: 7H JS KH TS 9H 8C 7D
: 9D
: QS JD


====================

Move 1 cards from stack 4 to stack 2

Foundations: H-6 C-6 D-A S-9
Freecells:  3D  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC
: KC QD
: 2D KD TH
: 7H JS KH TS 9H 8C 7D
: 9D
: QS JD


====================

Move 1 cards from stack 6 to stack 2

Foundations: H-6 C-6 D-A S-9
Freecells:  3D  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D
: KC QD
: 2D KD TH
: 7H JS KH TS 9H 8C 7D
:
: QS JD


====================

Move a card from freecell 0 to stack 6

Foundations: H-6 C-6 D-A S-9
Freecells:      4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D
: KC QD
: 2D KD TH
: 7H JS KH TS 9H 8C 7D
: 3D
: QS JD


====================

Move 2 cards from stack 5 to stack 2

Foundations: H-6 C-6 D-A S-9
Freecells:      4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
: 2D KD TH
: 7H JS KH TS 9H
: 3D
: QS JD


====================

Move 2 cards from stack 5 to stack 7

Foundations: H-6 C-6 D-A S-9
Freecells:      4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
: 2D KD TH
: 7H JS KH
: 3D
: QS JD TS 9H


====================

Move a card from stack 5 to freecell 0

Foundations: H-6 C-6 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
: 2D KD TH
: 7H JS
: 3D
: QS JD TS 9H


====================

Move 1 cards from stack 5 to stack 3

Foundations: H-6 C-6 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD TH
: 7H
: 3D
: QS JD TS 9H


====================

Move a card from stack 5 to the foundations

Foundations: H-7 C-6 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C 8H 7C 6D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD TH
:
: 3D
: QS JD TS 9H


====================

Move 1 cards from stack 0 to stack 5

Foundations: H-7 C-6 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C 8H 7C
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD TH
: 6D
: 3D
: QS JD TS 9H


====================

Move a card from stack 0 to the foundations

Foundations: H-7 C-7 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C 8H
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD TH
: 6D
: 3D
: QS JD TS 9H


====================

Move a card from stack 0 to the foundations

Foundations: H-8 C-7 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD TH
: 6D
: 3D
: QS JD TS 9H


====================

Move a card from stack 7 to the foundations

Foundations: H-9 C-7 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD TH
: 6D
: 3D
: QS JD TS


====================

Move a card from stack 4 to the foundations

Foundations: H-T C-7 D-A S-9
Freecells:  KH  4D  8D  5D
: 9C
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD
: 6D
: 3D
: QS JD TS


====================

Move a card from stack 7 to the foundations

Foundations: H-T C-7 D-A S-T
Freecells:  KH  4D  8D  5D
: 9C
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD JS
: 2D KD
: 6D
: 3D
: QS JD


====================

Move a card from stack 3 to the foundations

Foundations: H-T C-7 D-A S-J
Freecells:  KH  4D  8D  5D
: 9C
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
: 2D KD
: 6D
: 3D
: QS JD


====================

Move a card from freecell 2 to stack 0

Foundations: H-T C-7 D-A S-J
Freecells:  KH  4D      5D
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
: 2D KD
: 6D
: 3D
: QS JD


====================

Move a card from stack 4 to freecell 2

Foundations: H-T C-7 D-A S-J
Freecells:  KH  4D  KD  5D
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
: 2D
: 6D
: 3D
: QS JD


====================

Move a card from stack 4 to the foundations

Foundations: H-T C-7 D-2 S-J
Freecells:  KH  4D  KD  5D
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
:
: 6D
: 3D
: QS JD


====================

Move a card from stack 6 to the foundations

Foundations: H-T C-7 D-3 S-J
Freecells:  KH  4D  KD  5D
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
:
: 6D
:
: QS JD


====================

Move a card from freecell 1 to the foundations

Foundations: H-T C-7 D-4 S-J
Freecells:  KH      KD  5D
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
:
: 6D
:
: QS JD


====================

Move a card from freecell 3 to the foundations

Foundations: H-T C-7 D-5 S-J
Freecells:  KH      KD
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
:
: 6D
:
: QS JD


====================

Move a card from stack 5 to the foundations

Foundations: H-T C-7 D-6 S-J
Freecells:  KH      KD
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C 7D
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 2 to the foundations

Foundations: H-T C-7 D-7 S-J
Freecells:  KH      KD
: 9C 8D
: KS QH JC TD
: QC JH TC 9D 8C
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 0 to the foundations

Foundations: H-T C-7 D-8 S-J
Freecells:  KH      KD
: 9C
: KS QH JC TD
: QC JH TC 9D 8C
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 2 to the foundations

Foundations: H-T C-8 D-8 S-J
Freecells:  KH      KD
: 9C
: KS QH JC TD
: QC JH TC 9D
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 0 to the foundations

Foundations: H-T C-9 D-8 S-J
Freecells:  KH      KD
:
: KS QH JC TD
: QC JH TC 9D
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 2 to the foundations

Foundations: H-T C-9 D-9 S-J
Freecells:  KH      KD
:
: KS QH JC TD
: QC JH TC
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 2 to the foundations

Foundations: H-T C-T D-9 S-J
Freecells:  KH      KD
:
: KS QH JC TD
: QC JH
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 2 to the foundations

Foundations: H-J C-T D-9 S-J
Freecells:  KH      KD
:
: KS QH JC TD
: QC
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 1 to the foundations

Foundations: H-J C-T D-T S-J
Freecells:  KH      KD
:
: KS QH JC
: QC
: KC QD
:
:
:
: QS JD


====================

Move a card from stack 7 to the foundations

Foundations: H-J C-T D-J S-J
Freecells:  KH      KD
:
: KS QH JC
: QC
: KC QD
:
:
:
: QS


====================

Move a card from stack 7 to the foundations

Foundations: H-J C-T D-J S-Q
Freecells:  KH      KD
:
: KS QH JC
: QC
: KC QD
:
:
:
:


====================

Move a card from stack 3 to the foundations

Foundations: H-J C-T D-Q S-Q
Freecells:  KH      KD
:
: KS QH JC
: QC
: KC
:
:
:
:


====================

Move a card from stack 1 to the foundations

Foundations: H-J C-J D-Q S-Q
Freecells:  KH      KD
:
: KS QH
: QC
: KC
:
:
:
:


====================

Move a card from stack 2 to the foundations

Foundations: H-J C-Q D-Q S-Q
Freecells:  KH      KD
:
: KS QH
:
: KC
:
:
:
:


====================

Move a card from stack 3 to the foundations

Foundations: H-J C-K D-Q S-Q
Freecells:  KH      KD
:
: KS QH
:
:
:
:
:
:


====================

Move a card from stack 1 to the foundations

Foundations: H-Q C-K D-Q S-Q
Freecells:  KH      KD
:
: KS
:
:
:
:
:
:


====================

Move a card from stack 1 to the foundations

Foundations: H-Q C-K D-Q S-K
Freecells:  KH      KD
:
:
:
:
:
:
:
:


====================

Move a card from freecell 0 to the foundations

Foundations: H-K C-K D-Q S-K
Freecells:          KD
:
:
:
:
:
:
:
:


====================

Move a card from freecell 2 to the foundations

Foundations: H-K C-K D-K S-K
Freecells:
:
:
:
:
:
:
:
:


====================

This game is solveable.
Total number of states checked is 137.
This scan generated 191 states.
END_OF_SOL

open my $fh, '<', \$input_text;
my $solution = Games::Solitaire::Verify::Solution::ExpandMultiCardMoves::Lax->new(
    {
        input_fh => $fh,
        variant => "freecell",
        output_fh => \*STDOUT,
    },
);

my $verdict = $solution->verify();
if ($verdict)
{
    print STDERR $verdict;
    print STDERR "Solution is Wrong.\n";
    die "Solution is wrong.";
}
