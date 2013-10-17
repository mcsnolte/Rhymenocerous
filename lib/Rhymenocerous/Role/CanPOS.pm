package Rhymenocerous::Role::CanPOS;

# ABSTRACT: Parts of speech helper

use Moose::Role;
with 'Rhymenocerous::Role::Core';

=head1 METHODS

=head2 pos_for( $word )

Return the parts of speech for the given word.

=cut

sub pos_for {
	my $self = shift;
	my $word = lc shift;    # stored in lowercase

	my $pos_word = $self->schema->resultset('Word')->search(
		{
			'me.word_value' => { -ilike => $word }    #
		},
		{ rows => 1, }
	)->single();

	return unless $pos_word;

	my @pos = sort grep { $pos_word->get_column($_) } $self->schema->resultset('Word')->pos_columns();

	return @pos;
}

=head2 words_with_pos( %opts )

Return words for the given parts of speech

Options can be any column in L<Rhymenocerous::Schema::Result::Word> or
C<limit>.

=cut

sub words_with_pos {
	my $self = shift;
	my %opts = @_;

	my $words_rs = $self->schema->resultset('Word');

	my %filters = map { ( "me.$_" => $opts{$_} ) }    #
	  grep { defined $opts{$_} }                      #
	  $words_rs->result_source->columns;

	if ( $opts{limit} ) {
		$words_rs = $words_rs->search( undef, { rows => $opts{limit} } );
	}

	my @words = map { $_->{word_value} } $words_rs->search(
		\%filters,
		{
			columns      => 'me.word_value',
			group_by     => 'me.word_value',
			order_by     => $opts{'order_by'} // 'me.word_value',
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		}
	)->all();

	return @words;
}

1;
