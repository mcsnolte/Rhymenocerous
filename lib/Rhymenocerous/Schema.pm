package Rhymenocerous::Schema;

# ABSTRACT: The DBIC schema

use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces();

sub gimme {
	return __PACKAGE__->connect( 'dbi:Pg:dbname=rhymenocerous', '', '' );
}

1;
