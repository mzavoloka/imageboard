package FModel::Messages;
use strict;

use FModel::Funcs;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'messages' }

has 'subject' => ( is => 'rw', isa => 'Str' );

has 'content' => ( is => 'rw', isa => 'Str' );

has 'author' => ( is => 'rw',
                  metaclass => 'LittleORM::Meta::Attribute',
                  isa => 'FModel::Users',
                  description => { foreign_key => 'FModel::Users',
                                   foreign_key_attr_name => 'name' } );

has 'posted' => ( is => 'rw',
                  metaclass => 'LittleORM::Meta::Attribute',
                  isa => 'DateTime',
                  description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                   coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has thread_id => ( is => 'rw', isa => 'Int' );


1;
