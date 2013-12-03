package FModel::Users;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'users' }

has 'name' => ( is => 'rw', isa => 'Str' );
has 'password' => ( is => 'rw', isa => 'Str' );
has 'email' => ( is => 'rw', isa => 'Str' );
has 'registered' => ( is => 'rw', isa => 'Str' );


1;
