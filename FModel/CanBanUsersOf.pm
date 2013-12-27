use strict;

package FModel::CanBanUsersOf;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'can_ban_users_of' }

has 'permission_id' => ( is => 'rw',
                         metaclass => 'LittleORM::Meta::Attribute',
                         isa => 'FModel::Permissions',
                         description => { foreign_key => 'FModel::Permissions' } );

has 'users_of_permission_id' => ( is => 'rw',
                                  metaclass => 'LittleORM::Meta::Attribute',
                                  isa => 'FModel::Permissions',
                                  description => { foreign_key => 'FModel::Permissions' } );


1;
