package FModel::Sessions;
use strict;

use FModel::Funcs;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'sessions' }

has 'user_id' => ( is => 'rw',
                 metaclass => 'LittleORM::Meta::Attribute',
                 isa => 'FModel::Users',
                 description => { foreign_key => 'FModel::Users',
                                  foreign_key_attr_name => 'id' } );

has 'session_key' => ( is => 'rw', isa => 'Str' );

has 'expires' => ( is => 'rw',
                metaclass => 'LittleORM::Meta::Attribute',
                isa => 'DateTime',
                description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                 coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );


1;
