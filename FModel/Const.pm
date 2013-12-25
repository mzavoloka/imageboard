use strict;
package FModel::Const;

use FModel::Funcs;
use Moose;
extends 'LittleORM::GenericID';

sub _db_table { 'const' }

has 'name' => ( is => 'rw', isa => 'Str' );

has 'value' => ( is => 'rw', isa => 'Str' );


1;
