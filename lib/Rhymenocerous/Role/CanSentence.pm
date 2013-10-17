package Rhymenocerous::Role::CanSentence;

# ABSTRACT: Sentence utilities

use Moose::Role;

=head1 METHODS

=head2 words_for( $word|@words )

Crude sentence splitter.

=cut

sub words_for {
	my $self = shift;
	my $sentence = join( ' ', @_ );

	my @words =
	  map { split( /[\.,\?!"]?\s+[\.,\?!"]?/x, $_ ) } $sentence;
	s/^[\.,\?!"\s]+|[\.,\?!"\s]+$// for @words;

	return @words;
}

1;
