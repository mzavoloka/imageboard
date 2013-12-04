package FModel::Users;
use strict;
use Moose;
extends 'LittleORM::GenericID';
use LittleORM::Clause;
use LittleORM::Filter;

sub _db_table { 'users' }

has 'name' => ( is => 'rw', isa => 'Str' );
has 'password' => ( is => 'rw', isa => 'Str' );
has 'email' => ( is => 'rw', isa => 'Str' );
has 'registered' => ( is => 'rw', isa => 'Str' );

has 'id' => ( metaclass => 'LittleORM::Meta::Attribute',
              isa => 'Int',
              is => 'rw',
              description => { primary_key => 1, db_field_type => 'int' } );


1;
