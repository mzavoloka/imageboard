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
has 'registered' => ( is => 'rw', isa => 'Str' ); # Decided to stay with Str, because of incompatibility of Moose type DateTime with Postgres timestamp


1;
