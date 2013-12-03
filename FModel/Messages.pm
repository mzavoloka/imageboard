package FModel::Messages;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'messages' }

has 'date' => ( is => 'rw', isa => 'Str' );
has 'subject' => ( is => 'rw', isa => 'Str' );
has 'content' => ( is => 'rw', isa => 'Str' );
has 'author' => ( is => 'rw', isa => 'Str' );


1;
