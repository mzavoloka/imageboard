use strict;

package FModel::CanDeleteThreadsOf;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'can_delete_threads_of' }

has 'permission_id' => ( is => 'rw',
                         metaclass => 'LittleORM::Meta::Attribute',
                         isa => 'FModel::Permissions',
                         description => { foreign_key => 'FModel::Permissions' } );

has 'threads_of_permission_id' => ( is => 'rw',
                                    metaclass => 'LittleORM::Meta::Attribute',
                                    isa => 'FModel::Permissions',
                                    description => { foreign_key => 'FModel::Permissions' } );


1;
