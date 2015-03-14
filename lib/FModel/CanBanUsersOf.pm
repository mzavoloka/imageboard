use Modern::Perl;

package FModel::CanBanUsersOf;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'can_ban_users_of' }

has 'permission' => ( is => 'rw',
                      metaclass => 'LittleORM::Meta::Attribute',
                      isa => 'FModel::Permissions',
                      description => { foreign_key => 'yes',
                                       db_field => 'permission_id' } );

has 'users_of_permission' => ( is => 'rw',
                               metaclass => 'LittleORM::Meta::Attribute',
                               isa => 'FModel::Permissions',
                               description => { foreign_key => 'yes',
                                                db_field => 'users_of_permission_id' } );


1;
