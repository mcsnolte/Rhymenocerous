package Rhymenocerous;

# ABSTRACT: Its lyrics are bottomless

use Moose;
use namespace::autoclean;

with 'Rhymenocerous::Role::CanRhyme';
with 'Rhymenocerous::Role::CanPOS';
with 'Rhymenocerous::Role::CanSyllable';
with 'Rhymenocerous::Role::CanSentence';

=head1 SYNOPSIS

  my $r = Rhymenocerous->new();
  print $r->gen_rhyme('Roses are red, violets are blue,');

=head1 METHODS

=head2 gen_rhyme( $sentence|@words )

Returns a new, random sentence that rhymes with the input and _tries_ to match
the syllable count.

=cut

sub gen_rhyme {
	my $self  = shift;
	my @words = $self->words_for(@_);

	return unless scalar @words && $words[0];

	my $syllables = $self->syllables_for(@words);

	my ($rhyme) = $self->partial_rhymes_for(
		$words[-1],    #
		type     => 'noun',
		limit    => 1,
		order_by => 'random()'
	);

	return $self->sentence_rhyme( $rhyme, $syllables );
}

sub get_word {
	my $self = shift;
	my %opts = @_;

	my $type = $opts{type} or die('Word type not defined');

	# TODO:  try to get a word with $opts{syllables} number of syllables, fallback to any number

	# Get random management speak word
	my $word = $self->dict->{ $type . 's' }[ _random( $#{ $self->dict->{ $type . 's' } }, 0 ) ];

	# Alternate code to pull a random word from the Word table
	#my %pos =
	#  $type eq 'verb'
	#  ? ( verb_usu_participle => 1, adjective => 0 )
	#  : ( $type => 1 );
	#my ($word) = $self->words_with_pos(
	#    %pos,
	#    syllables => scalar $opts{syllables},
	#    limit     => 1,
	#    order_by  => 'random()'
	#);

	return $word;
}

# Lingua::ManagementSpeak words
has dict => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub {
		return {
			pronouns => [qw(I we they)],

			# article
			definite_articles => [qw(the your my our this its)],

			# sub_conjuc
			conjunctions => [
				'after',         'although', 'as',      'as if',       'as long as', 'as though',
				'because',       'before',   'even if', 'even though', 'if',         'if only',
				'in order that', 'now that', 'once',    'rather than', 'since',      'so that',
				'though',        'unless',   'until',   'when',        'whenever',   'where',
				'whereas',       'wherever', 'while'
			],
			power_words => [
				qw(
				  accomplished dealt implemented projected achieved debated improved
				  promoted acquired decided included proofed adjusted defined increased
				  purchased administered delegated indicated qualified advised delivered
				  initiated questioned analyzed demonstrated inspected rated applied
				  designed instructed received appraised determined insured recognized
				  arranged developed interpreted recommended assessed devised interviewed
				  recorded assisted directed introduced recruited assured discovered
				  investigated reduced awarded dispensed joined rehabilitated bought
				  displayed kept related briefed distributed launched renovated brought
				  earned led repaired budgeted edited located reported calculated educated
				  maintained represented cataloged elected managed researched chaired
				  encouraged maximized reviewed changed enlisted measured revised
				  classified ensured mediated selected closed entertained modified served
				  coached established motivated simplified combined evaluated named
				  sketched communicated examined negotiated sold compared excelled
				  observed solved completed executed obtained spearheaded computed
				  exhibited operated specified conceived expanded ordered started
				  concluded expedited organized streamlined conducted explained paid
				  strengthened confronted facilitated participated studied constructed
				  financed perceived suggested continued forecast performed summarized
				  contracted formulated persuaded supervised controlled gained placed
				  targeted convinced gathered planned taught coordinated graded predicted
				  tested corrected greeted prepared trained corresponded guided presented
				  translated counseled handled processed treated created helped produced
				  updated critiqued identified programmed wrote
				  )
			],

			# verb_usu_participle, verb_transitive, verb_instransitive
			verbs => [
				qw(
				  aggregate architect benchmark brand cultivate deliver deploy
				  disintermediate drive e-enable embrace empower enable engage engineer
				  enhance envision evolve expedite exploit extend facilitate generate grow
				  harness implement incentivize incubate innovate integrate iterate
				  leverage maximize mesh monetize morph optimize orchestrate
				  recontextualize reintermediate reinvent repurpose revolutionize scale
				  seize strategize streamline syndicate synergize synthesize target
				  transform transition unleash utilize visualize whiteboard
				  )
			],
			aux_verbs =>
			  [ 'will', 'shall', 'may', 'might', 'can', 'could', 'must', 'ought to', 'should', 'would', 'need to' ],

			adjectives => [
				qw(
				  24/365 24/7 B2B B2C back-end best-of-breed bleeding-edge
				  bricks-and-clicks clicks-and-mortar collaborative compelling
				  cross-platform cross-media customized cutting-edge
				  distributed dot-com dynamic e-business efficient
				  end-to-end enterprise extensible frictionless front-end
				  global granular holistic impactful innovative integrated interactive
				  intuitive killer leading-edge magnetic mission-critical next-generation
				  one-to-one open-source out-of-the-box plug-and-play proactive real-time
				  revolutionary robust scalable seamless sexy sticky strategic synergistic
				  transparent turn-key ubiquitous user-centric value-added vertical
				  viral virtual visionary web-enabled wireless world-class
				  )
			],

			# noun
			nouns => [
				qw(
				  action-items applications architectures bandwidth channels communities
				  content convergence deliverables e-business e-commerce e-markets
				  e-services e-tailers experiences eyeballs functionalities infomediaries
				  infrastructures initiatives interfaces markets methodologies metrics
				  mindshare models networks niches paradigms partnerships platforms
				  portals relationships ROI synergies web-readiness schemas solutions
				  supply-chains systems technologies users vortals
				  )
			],

			#conj_adverbs => [qw(however moreover nevertheless consequently)],
			#conjuntors => [qw(though although notwithstanding yet still)]
		};
	}
);

# from Lingua::ManagementSpeak
sub _random {
	my $high = shift || 5;
	my $low  = shift || 1;
	int( rand( $high - $low + 1 ) ) + $low;
}

# from Lingua::ManagementSpeak
sub words {
	my ( $self, $meta, $rhyme, $syllables ) = @_;

	# Deal with "maybe_n/n_word" meta words
	while ( $meta =~ /maybe[_-](\d+)\/(\d+)[_-](\w+)\S*/ ) {
		my $word = ( _random( $2, $1 ) == $1 ) ? $3 : '';
		if ($word) {
			$meta =~ s/maybe[_-]\d+\/\d+[_-]\w+(\S*)/$word$1/;
		}
		else {
			$meta =~ s/maybe[_-]\d+\/\d+[_-]\w+\S*\s*//;
		}
	}

	# Convert "phrase" into phrase meta words
	$meta =~ s/(\w)\s+phrase/$1, phrase/g;
	$meta =~ s/phrase/conjuntor definite_article noun to_be power_word/g;

	$syllables -= $self->syllables_for($rhyme);
	$meta =~ s/rhyme/$rhyme/;

	while (
		$meta =~ /(
    pronoun|definite_article|sub_conjuc|power_word|verb|aux_verb|
    adjective|noun|conj_adverb|conjuntor|conjunction|adverb
  )/x
	  )
	{
		# If the word is an adverb, we have to pick a verb and add "ing" to it.
		# This is newbie-like code. Should get rewritten eventually.
		my ( $t1, $t2 ) = ( $1, $1 );
		$t2 = 'verb' if ( $t1 eq 'adverb' );

		# Get another word unless we are out of syllables
		my $word = $syllables > 0 ? $self->get_word( type => $t2, syllables => $syllables ) : undef;

		if ($word) {
			$syllables -= $self->syllables_for($word);
			$word =~ s/[e]*$/ing/ if ( $t1 eq 'adverb' );
			$meta =~ s/$t1/$word/;
		}
		else {
			$meta =~ s/$t1\s*//;              # delete it since out of syllables
			$meta =~ s/(^|\s+)[s,]\s+/ /g;    # cleanup
		}
	}

	# Convert "to_be" into the proper conjugated form
	while ( $meta =~ /\b(\w+)\s+to_be/ ) {
		if ( $1 =~ /ess$/ ) {
			$meta =~ s/to_be/is/;
		}
		elsif ( $1 =~ /s$/ ) {
			$meta =~ s/to_be/are/;
		}
		else {
			$meta =~ s/to_be/is/;
		}
	}

	$meta =~ s/^\s+|\s+$//;
	$meta;
}

# repurposed from Lingua::ManagementSpeak
sub sentence_rhyme {
	my $self      = shift;
	my $rhyme     = shift;
	my $syllables = shift;

	my $meta;

	# TODO: pick a good template based on syllable count
	my $type = _random( 7, 1 );

	if ( $type == 1 ) {
		$meta = 'definite_article noun to_be power_word conjunction pronoun power_word '
		  . 'definite_article maybe_1/2_adjective rhyme';
	}
	elsif ( $type == 2 ) {
		$meta =
		    'conjunction pronoun power_word definite_article maybe_1/2_adjective '
		  . 'noun, definite_article maybe_1/2_adjective noun power_word definite_article '
		  . 'maybe_1/2_adjective rhyme';
	}
	elsif ( $type == 3 ) {
		$meta =
		    'pronoun aux_verb verb definite_article maybe_1/2_adjective noun '
		  . 'conjunction definite_article adjective noun aux_verb verb definite_article '
		  . 'maybe_1/2_adjective rhyme';
	}
	elsif ( $type == 4 ) {
		$meta =
		    'conjunction pronoun verb definite_article maybe_1/2_adjective noun, '
		  . 'pronoun can verb definite_article '
		  . 'maybe_1/2_adjective rhyme';
	}
	elsif ( $type == 5 ) {
		$meta =
		    'pronoun aux_verb verb definite_article maybe_1/2_adjective noun '
		  . 'conjunction pronoun verb definite_article '
		  . 'maybe_1/2_adjective rhyme';
	}
	elsif ( $type == 6 ) {
		$meta = 'definite_article noun verbs adjective rhyme';
	}
	elsif ( $type == 7 ) {
		$meta = "definite_article noun to_be a adjective noun conjunctions, conjunctions "
		  . 'definite_article noun verbs definite_article rhyme';
	}

	#$meta = 'maybe_1/4_conj_adverb, ' . $meta;

	return ucfirst( $self->words( $meta, $rhyme, $syllables ) ) . '.';
}

__PACKAGE__->meta->make_immutable;

1;
