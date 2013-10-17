package Rhymenocerous::Role::CanSyllable;

# ABSTRACT: Syllable utilities

use Moose::Role;
with 'Rhymenocerous::Role::Core';

use Lingua::EN::Syllable;

=head1 METHODS

=head2 syllables_for( $word|@words )

Return the total syllable count for C<@words>.

Uses the guesstimated count calculated by script/build_word_db.pl or fallsback
to using L<Linguage::EN::Syllable>.

=cut

sub syllables_for {
	my $self  = shift;
	my @words = @_;

	my %syllables = map { $_->word_value => $_->syllables }    #
	  $self->schema->resultset('Word')->search(
		{
			'me.word_value' => { -ilike => \@words },          #
		},
		{ columns => [qw/word_value syllables/], }
	  )->all();

	my $total = 0;
	foreach my $word (@words) {

		# use what's in DB but fallback to L::EN::Syllable
		$total += $syllables{$word} // syllable($word);
	}

	return $total;
}

1;
