package FModel::Messages;
use strict;

use FModel::Funcs;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'messages' }

has 'subject' => ( is => 'rw', isa => 'Str' );

has 'content' => ( is => 'rw', isa => 'Str' );

has 'user_id' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'FModel::Users',
                   description => { foreign_key => 'FModel::Users',
                                    foreign_key_attr_name => 'id' } );

has 'posted' => ( is => 'rw',
                  metaclass => 'LittleORM::Meta::Attribute',
                  isa => 'DateTime',
                  description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                   coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'thread_id' => ( is => 'rw',
                     metaclass => 'LittleORM::Meta::Attribute',
                     isa => 'FModel::Threads',
                     description => { foreign_key => 'FModel::Threads',
                                      foreign_key_attr_name => 'id' } );

has 'modified_date' => ( is => 'rw',
                         metaclass => 'LittleORM::Meta::Attribute',
                         isa => 'DateTime',
                         description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                          coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'modified' => ( is => 'rw', isa => 'Bool' );

has 'pinned_img' => ( is => 'rw', isa => 'Str' );


1;
