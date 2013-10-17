#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;    # tests => ?;

use Rhymenocerous;
my $r = Rhymenocerous->new();

is_deeply [ $r->words_for('This is my sentence. ') ],      [qw/This is my sentence/];
is_deeply [ $r->words_for('This is\'nt my "sentence."') ], [qw/This is'nt my sentence/];

done_testing();

