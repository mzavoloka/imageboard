package FModel::Threads;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 
use LittleORM::Clause;
use LittleORM::Filter;

sub _db_table { 'threads' }

has 'title' => ( is => 'rw', isa => 'Str' );

has 'created' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'DateTime',
                   description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                    coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'content' => ( is => 'rw', isa => 'Str' );

has 'user_id' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'FModel::Users',
                   description => { foreign_key => 'FModel::Users',
                                    foreign_key_attr_name => 'id' } );

has 'updated' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'DateTime',
                   description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                    coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'modified_date' => ( is => 'rw',
                         metaclass => 'LittleORM::Meta::Attribute',
                         isa => 'DateTime',
                         description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                          coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'modified' => ( is => 'rw', isa => 'Bool' );


1;
