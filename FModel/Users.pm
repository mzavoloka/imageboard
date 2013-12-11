use strict;
package FModel::Users;

use FModel::Funcs;
use Moose;
extends 'LittleORM::GenericID';

sub _db_table { 'users' }

has 'name' => ( is => 'rw', isa => 'Str' );

has 'password' => ( is => 'rw', isa => 'Str' );

has 'email' => ( is => 'rw',
                 metaclass => 'LittleORM::Meta::Attribute',
                 isa => 'Str',
                 description => { coerce_to => sub { &FModel::Funcs::validate_email( $_[0] ) } } );

has 'registered' => ( is => 'rw',
                      metaclass => 'LittleORM::Meta::Attribute',
                      isa => 'DateTime',
                      description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                       coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

1;
