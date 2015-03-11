use strict;

package FModel::CanDeleteThreadsOf;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'can_delete_threads_of' }

has 'permission' => ( is => 'rw',
                      metaclass => 'LittleORM::Meta::Attribute',
                      isa => 'FModel::Permissions',
                      description => { foreign_key => 'yes',
                                       db_field => 'permission_id' } );

has 'threads_of_permission' => ( is => 'rw',
                                    metaclass => 'LittleORM::Meta::Attribute',
                                    isa => 'FModel::Permissions',
                                    description => { foreign_key => 'FModel::Permissions',
                                                     db_field => 'threads_of_permission_id' } );


1;
