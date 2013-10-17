package Rhymenocerous::Schema::Result::Sounds;

# ABSTRACT: Table for pronunciations

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('sounds');
__PACKAGE__->add_columns(
	word_value => {
		data_type   => 'varchar',
		is_nullable => 0,
	},
	phonemes => {
		data_type   => 'varchar',
		is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key(qw/word_value phonemes/);

__PACKAGE__->belongs_to(
	word                 => 'Rhymenocerous::Schema::Result::Word',
	{ 'foreign.word_value' => 'self.word_value' },
);

1;
