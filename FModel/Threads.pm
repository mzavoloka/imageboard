package FModel::Threads;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 
use LittleORM::Clause;
use LittleORM::Filter;

sub _db_table { 'threads' }

has 'title' => ( is => 'rw', isa => 'Str' );
has 'content' => ( is => 'rw', isa => 'Str' );
has 'created' => ( is => 'rw', isa => 'Str' );


1;
