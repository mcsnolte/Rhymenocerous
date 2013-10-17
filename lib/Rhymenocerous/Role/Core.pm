package Rhymenocerous::Role::Core;

# ABSTRACT: Core role for easy access

use Moose::Role;
use MooseX::ClassAttribute;

class_has schema => (
	is      => 'ro',
	isa     => 'DBIx::Class::Schema',
	lazy    => 1,
	default => sub {
		require Rhymenocerous::Schema;

		return Rhymenocerous::Schema->gimme();
	}
);

1;

