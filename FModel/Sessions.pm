package FModel::Sessions;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 
use LittleORM::Clause;
use LittleORM::Filter;

sub _db_table { 'sessions' }

has 'username' => ( is => 'rw', isa => 'Str' );
has 'expires' => ( is => 'rw', isa => 'Str' ); # Decided to stay with Str, because of incompatibility of Moose type DateTime with Postgres timestamp
has 'session_key' => ( is => 'rw', isa => 'Str' );


1;
