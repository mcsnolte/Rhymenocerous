package Rhymenocerous::Schema::ResultSet::Word;

# ABSTRACT: Word resultset

use base 'DBIx::Class::ResultSet';

sub pos_columns {
	return (
		'noun',              'plural',    'noun_phrase',      'verb_usu_participle', 'verb_transitive',
		'verb_intransitive', 'adjective', 'adverb',           'conjunction',         'preposition',
		'interjection',      'pronoun',   'definite_article', 'indefinite_article',  'nominative',
	);
}

1;
