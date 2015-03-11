use strict;

package FModel::CanDeleteMessagesOf;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'can_delete_messages_of' }

has 'permission' => ( is => 'rw',
                         metaclass => 'LittleORM::Meta::Attribute',
                         isa => 'FModel::Permissions',
                         description => { foreign_key => 'yes',
                                          db_field => 'permission_id' } );

has 'messages_of_permission' => ( is => 'rw',
                                     metaclass => 'LittleORM::Meta::Attribute',
                                     isa => 'FModel::Permissions',
                                     description => { foreign_key => 'yes',
                                                      db_field => 'messages_of_permission_id' } );


1;
