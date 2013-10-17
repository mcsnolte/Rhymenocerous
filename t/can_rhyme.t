#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;    # tests => ?;

use Rhymenocerous;
my $r = Rhymenocerous->new();

is_deeply( [ $r->rhymes_for('blue') ], [ 'bleu', 'blew', ] );

is_deeply( [ $r->rhymes_for('orange') ], [] );

is_deeply( [ $r->rhymes_for('key') ],
	[ 'Kee', 'McKee', 'Waikiki', 'kea', 'ki', 'marquee', 'marquis', 'quay', 'ski', 'tiki' ] );

is_deeply( [ $r->exact_rhymes_for('key') ], [ 'Kee', 'kea', 'ki', 'quay', 'ski', ] );

is_deeply( [ grep { m/^w/ } $r->partial_rhymes_for('improvement') ],
	[ 'warrant', 'wasn\'t', 'water-repellent', 'weren\'t', 'wonderment', 'wouldn\'t' ] );

done_testing();

