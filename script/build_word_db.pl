#!/usr/bin/env perl

use strict;
use warnings;

use Dir::Self;

use lib __DIR__ . "/../lib";

use Rhymenocerous::Schema;
use Path::Class qw/dir/;
use Data::Show;

$ENV{'DBIC_TRACE'} = 1;
my $schema = Rhymenocerous::Schema->gimme();

#`dropdb rhymenocerous`;
#`createdb rhymenocerous`;
$schema->deploy();

# Word => POS
my %pos_words =
  map { my ( $word, $pos ) = split( /\t/, $_ ); uc $word => { pos => $pos, word => $word } }    #
  grep { $_ !~ m/^[A-Z]+$/ }    # skip ALL caps words, they look weird
  grep { length $_ > 1 }        # skip shorties
  dir( __DIR__, '..', 'data', 'pos', )->file('part-of-speech.txt')->slurp( chomp => 1 );

my %phonemes_for;

my @sounds_lines =              #
  grep { $_ !~ m/^;;;/ }        # skip comments
  grep { $_ !~ m/^[A-Z]+$/ }    # skip ALL caps words, they look weird
  grep { length $_ > 1 }        # skip shorties
  dir( __DIR__, '..', 'data' )->file('cmudict.0.7a.def')->slurp( chomp => 1 );

my @sounds;
foreach my $line (@sounds_lines) {
	next unless $line =~ m/^[a-zA-Z0-9]/;

	my ( $word, $phonemes ) = split( '  ', $line, 2 );
	$word =~ s/\(\d+\)//;       # rid pronounciation enumeration

	$phonemes_for{$word} //= $phonemes;

	$word = $pos_words{$word}->{word};
	next unless $word;

	push( @sounds, [ $word, $phonemes ] );
}

#############################
# Parts of Speech

my @words;

my %pos_map = (
	N   => 'noun',
	p   => 'plural',
	h   => 'noun_phrase',
	V   => 'verb_usu_participle',
	t   => 'verb_transitive',
	i   => 'verb_intransitive',
	A   => 'adjective',
	v   => 'adverb',
	C   => 'conjunction',
	P   => 'preposition',
	'!' => 'interjection',
	r   => 'pronoun',
	D   => 'definite_article',
	I   => 'indefinite_article',
	o   => 'nominative',
);

while ( my ( $word, $pos_info_r ) = each %pos_words ) {
	my $phonemes = $phonemes_for{$word};
	next unless $phonemes && $pos_info_r->{word};

	my %word_info = map { $_ => 0 } values %pos_map;
	$word_info{word_value} = $pos_info_r->{word};
	$word_info{syllables}  = ( $phonemes =~ tr/[0-9]// );

	foreach my $pos_char ( split( '', $pos_info_r->{pos} ) ) {
		my $key = $pos_map{$pos_char} or next;
		$word_info{$key} = 1;
	}

	push( @words, \%word_info );
}

$schema->resultset('Word')->populate( [ @words, ] );

$schema->resultset('Sounds')->populate(
	[
		[qw/word_value phonemes/],    # cols
		@sounds,
	]
);

print "done\n";

