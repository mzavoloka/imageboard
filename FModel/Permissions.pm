use strict;
package FModel::Permissions;

use Wendy::Db qw( dbconnect );
use FModel::CanBanUsersOf;
use FModel::CanEditMessagesOf;
use FModel::CanDeleteMessagesOf;
use FModel::CanEditThreadsOf;
use FModel::CanDeleteThreadsOf;
use FModel::Users;
use Data::Dumper 'Dumper';

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


LittleORM::Db -> init( &dbconnect() );

sub can_ban_users_of
{
        my $self = shift;

        my @rows = FModel::CanBanUsersOf -> get_many( permission_id => $self -> id() );

        my @users_of_permission_ids = map { $_ -> users_of_permission_id() -> id() } @rows;

        return @users_of_permission_ids;
}

sub can_edit_messages_of
{
        my $self = shift;

        my @rows = FModel::CanEditMessagesOf -> get_many( permission_id => $self -> id() );

        my @messages_of_permission_ids = map { $_ -> messages_of_permission_id() -> id() } @rows;

        return @messages_of_permission_ids;
}

sub can_edit_threads_of
{
        my $self = shift;

        my @rows = FModel::CanEditThreadsOf -> get_many( permission_id => $self -> id() );

        my @threads_of_permission_ids = map { $_ -> threads_of_permission_id() -> id() } @rows;

        return @threads_of_permission_ids;
}

sub can_delete_messages_of
{
        my $self = shift;

        my @rows = FModel::CanDeleteMessagesOf -> get_many( permission_id => $self -> id() );

        my @messages_of_permission_ids = map { $_ -> messages_of_permission_id() -> id() } @rows;

        return @messages_of_permission_ids;
}

sub can_delete_threads_of
{
        my $self = shift;

        my @rows = FModel::CanDeleteThreadsOf -> get_many( permission_id => $self -> id() );

        my @threads_of_permission_ids = map { $_ -> threads_of_permission_id() -> id() } @rows;

        return @threads_of_permission_ids;
}


1;
