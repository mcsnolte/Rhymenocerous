package Rhymenocerous::Role::CanRhyme;

# ABSTRACT: Rhyme helper

use Moose::Role;
with 'Rhymenocerous::Role::Core';

=head1 METHODS

=head2 rhymes_for( $word )

Return words that end-rhyme with C<$word>.

=cut

sub rhymes_for {
	my $self = shift;
	my $word = shift;

	$word =~ s/[\."\?!'*()]$//g;

	my @sounds = $self->schema->resultset('Sounds')->search(
		{
			'me.word_value' => { -ilike => $word }    #
		},
	)->get_column('phonemes')->all();

	my @words = $self->schema->resultset('Sounds')->search(
		{
			'me.phonemes' => {
				-ilike => [
					map {
						'%' . $_                      # ends with this sound
					} @sounds
				]
			},
			'me.word_value' => { '!=' => $word },
		},
		{
			distinct => 1,
			order_by => 'me.word_value',
		}
	)->get_column('word_value')->all();

	return @words;
}

=head2 rhymes_for( $word )

Return words that rhyme exactly with C<$word>.

=cut

sub exact_rhymes_for {
	my $self = shift;
	my $word = shift;

	$word =~ s/[\."\?!'*()]$//g;

	my @sounds = $self->schema->resultset('Sounds')->search(
		{
			'me.word_value' => { -ilike => $word }    #
		},
	)->get_column('phonemes')->all();

	my $syllables = $self->schema->resultset('Word')->search(
		{
			'me.word_value' => { -ilike => $word }    #
		},
		{ rows => 1, }
	)->get_column('syllables')->first();

	my @words = $self->schema->resultset('Sounds')->search(
		{
			'me.phonemes' => {
				-ilike => [
					map {
						'%' . $_                      # ends with this sound
					} @sounds
				]
			},
			'me.word_value'  => { '!=' => $word },
			'word.syllables' => $syllables,
		},
		{
			join     => 'word',
			distinct => 1,
			order_by => 'me.word_value',
		}
	)->get_column('word_value')->all();

	return @words;
}

=head2 partial_rhymes_for( $word, %opts? )

Return words that partial-rhyme with C<$word>.

Options can be type (e.g. part of speech), syllables, limit, or order_by.

=cut

sub partial_rhymes_for {
	my $self = shift;
	my $word = shift;
	my %opts = @_;

	$word =~ s/[\."\?!'*()]$//g;

	my $sounds_rs = $self->schema->resultset('Sounds');

	my @sounds = $sounds_rs->search(
		{
			'me.word_value' => { -ilike => $word }    #
		},
	)->get_column('phonemes')->all();

	# Get last "number" sound
	my @partials;
	foreach my $sound (@sounds) {
		if ( $sound =~ m/.*([A-Z]{2}\d.*)/ ) {
			push @partials, $1;
		}
	}

	if ( $opts{type} ) {
		$sounds_rs = $sounds_rs->search( { "word.$opts{type}" => 1 }, { join => 'word' } );
	}
	if ( $opts{syllables} ) {
		$sounds_rs = $sounds_rs->search( { "word.syllables" => $opts{syllables} }, { join => 'word' } );
	}
	if ( $opts{limit} ) {
		$sounds_rs = $sounds_rs->search( undef, { rows => $opts{limit} } );
	}

	my @words = map { $_->{'word_value'} } $sounds_rs->search(
		{
			'me.phonemes' => {
				-ilike => [
					map {
						'%' . $_    # ends with this sound
					} @partials
				]
			},
			'me.word_value' => { '!=' => $word },
		},
		{
			columns      => 'me.word_value',
			group_by     => 'me.word_value',
			order_by     => $opts{order_by} // 'me.word_value',
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		}
	)->all();

	return @words;
}

1;
