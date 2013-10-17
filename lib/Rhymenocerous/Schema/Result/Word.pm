package Rhymenocerous::Schema::Result::Word;

# ABSTRACT: Table for words

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('word');
__PACKAGE__->add_columns(
	word_value => {
		data_type   => 'varchar',
		is_nullable => 0,
	},

	syllables => {
		data_type   => 'int',
		is_nullable => 0,
	},

	#########################
	# Parts of Speech
	#
	# N	Noun
	noun => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# p	Plural
	plural => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# h	Noun Phrase
	noun_phrase => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# V	Verb (usu participle)
	verb_usu_participle => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# t	Verb (transitive)
	verb_transitive => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# i	Verb (intransitive)
	verb_intransitive => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# A	Adjective
	adjective => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# v	Adverb
	adverb => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# C	Conjunction
	conjunction => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# P	Preposition
	preposition => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# !	Interjection
	interjection => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# r	Pronoun
	pronoun => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# D	Definite Article
	definite_article => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# I	Indefinite Article
	indefinite_article => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	# o	Nominative
	nominative => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},

	#
	# End Parts of Speech
	#########################
);

__PACKAGE__->set_primary_key(qw/word_value/);

__PACKAGE__->has_many(
	sounds => 'Rhymenocerous::Schema::Result::Sounds',
	{ 'foreign.word_value' => 'self.word_value' },
);

1;
