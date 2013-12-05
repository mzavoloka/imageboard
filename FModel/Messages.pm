package FModel::Messages;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 
use LittleORM::Clause;
use LittleORM::Filter;

sub _db_table { 'messages' }

has 'date' => ( is => 'rw', isa => 'Str' ); # Decided to stay with Str, because of incompatibility of Moose type DateTime with Postgres timestamp
has 'subject' => ( is => 'rw', isa => 'Str' );
has 'content' => ( is => 'rw', isa => 'Str' );
has 'author' => ( is => 'rw', isa => 'Str' );


1;
