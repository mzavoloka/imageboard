use strict;
package FModel::Permissions;

use FModel::Funcs;
use Moose;
extends 'LittleORM::GenericID';

sub _db_table { 'permissions' }

has 'title' => ( is => 'rw', isa => 'Str' );

has 'post_messages' => ( is => 'rw', isa => 'Bool' );

has 'edit_messages' => ( is => 'rw', isa => 'Bool' );

has 'delete_messages' => ( is => 'rw', isa => 'Bool' );

has 'create_threads' => ( is => 'rw', isa => 'Bool' );

has 'edit_threads' => ( is => 'rw', isa => 'Bool' );

has 'delete_threads' => ( is => 'rw', isa => 'Bool' );

has 'edit_messages_of' => ( is => 'rw', isa => 'Str' );

has 'delete_messages_of' => ( is => 'rw', isa => 'Str' );

has 'edit_threads_of' => ( is => 'rw', isa => 'Str' );

has 'delete_threads_of' => ( is => 'rw', isa => 'Str' );

has 'ban_users' => ( is => 'rw', isa => 'Str' );


1;
