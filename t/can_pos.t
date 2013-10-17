#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;    # tests => ?;

use Rhymenocerous;
my $r = Rhymenocerous->new();

is_deeply(
	[ $r->pos_for('blue') ],    #
	[ 'adjective', 'noun', 'verb_usu_participle', ],
);
is_deeply(
	[ $r->pos_for('apple') ],    #
	['noun']
);

done_testing();

