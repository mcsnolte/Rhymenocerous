#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;    # tests => ?;

use Rhymenocerous;
my $r = Rhymenocerous->new();

is $r->syllables_for('improvement'),             3;
is $r->syllables_for('the dog ate my homework'), 6;
is $r->syllables_for(qw/databases is plural/), 7;
is $r->syllables_for('Roses are red, violets are blue'), 9;

done_testing();

