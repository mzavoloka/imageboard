use strict;

package localhost::adminka_users;

sub wendy_handler
{
        return ForumAdminkaUsers -> run();
}

package ForumAdminkaUsers;
use Wendy::Shorts qw( ar );
use Wendy::Templates::TT 'tt';
use Carp::Assert 'assert';
use File::Copy 'cp';
use URI qw( new query_from as_string );
use Data::Dumper 'Dumper';
use ForumConst;

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'search' ] };


sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( not $self -> can_use_adminka() )
        {
                $rv = $self -> construct_page( restricted_msg => 'ADMINKA_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_search
{
        my $self = shift;

        my $output = $self -> show_users();

        return $output;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> show_user_edit_form();

        return $output;
}

sub show_user_edit_form
{
        my $self = shift;

        my $id = $self -> arg( 'id' );
        
        $self -> fill_user_edit_form_params();

        my $output = $self -> construct_page( middle_tpl => 'adminka_user_edit' );

        return $output;
}

sub show_users
{
        my ( $self, %params ) = @_;

        my $page = int( $self -> arg( 'page' ) || $params{ 'page' } ) || 1;

        my $users_on_page = ForumConst -> users_on_page();
        my $users = $self -> get_users();
        my $count_of_users = scalar $users;

        my $show_from = ( $page - 1 ) * $users_on_page;
        my $show_to = Funcs::min_of( $show_from + $users_on_page, $count_of_users );

        &ar( DYN_USERS => $users,
             DYN_PERMISSIONS => $self -> get_permissions_for_dropdown(),
             DYN_NUM_OF_ADMINKA_USERS_COLS => ForumConst -> num_of_adminka_users_cols(),
             DYN_ARROWUP_IMAGE_URL => ForumConst -> arrowup_image_url(),
             DYN_ARROWDOWN_IMAGE_URL => ForumConst -> arrowdown_image_url(),
             DYN_ARROW_IMAGE_WIDTH => ForumConst -> arrow_image_width(),
             DYN_ARROW_IMAGE_HEIGHT => ForumConst -> arrow_image_height() );

        my $output = $self -> construct_page( middle_tpl => 'adminka_users' );

        return $output;
}

sub get_users
{
        my ( $self, %sort_params ) = @_;

        if( not %sort_params )
        {
                %sort_params = ( name => 'ASC' );
        }

        my @users_in_db = FModel::Users -> get_many( _sortby => [ %sort_params ] );

        my @users = ();

        for my $user ( @users_in_db )
        {
                my $hash = { DYN_ID   => $user -> id(),
                             DYN_NAME => $user -> name() };

                if( $user eq $self -> user() )
                {
                        $hash -> { 'DYN_THATS_YOU' } = 1;
                }
                push( @users, $hash );
        }

        return \@users;
}

sub fill_user_edit_form_params
{
        my $self = shift;

        my $id = $self -> arg( 'id' );

        my $user = FModel::Users -> get( id => $id );

        if( $id eq $self -> user() -> id() )
        {
                &ar( DYN_THATS_YOU => 1 );
        }

        my $num_of_messages = FModel::Messages -> count( author => $user );

        my $num_of_threads = FModel::Threads -> count( author => $user );

        &ar( DYN_ID              => $user -> id(),
             DYN_NAME            => $user -> name(),
             DYN_PASSWORD        => $user -> password(),
             DYN_EMAIL           => $user -> email(),
             DYN_REGISTERED      => Funcs::readable_date( $user -> registered() ),
             DYN_NUM_OF_MESSAGES => $num_of_messages,
             DYN_NUM_OF_THREADS  => $num_of_threads,
             DYN_AVATAR          => $user -> avatar_url(),
             DYN_CAN_BAN         => $self -> can_do_action_with_user( 'ban', $user -> id() ),
             DYN_BANNED          => $user -> banned(),
             DYN_PERMISSIONS     => $self -> get_permissions_for_dropdown( $user ) );

        return;
}

sub get_permissions_for_dropdown
{
        my ( $self, $user ) = @_;

        my @permissions = FModel::Permissions -> get_many( _sortby => 'title' );

        my @permissions_for_dropdown = ();
        
        for my $permission ( @permissions )
        {
                my $hash = { DYN_ID => $permission -> id(),
                             DYN_TITLE => $permission -> title() };

                if( ( $self -> arg( 'permissions' ) eq $permission ) or ( $user and ( $user -> permission() eq $permission ) ) )
                {
                        $hash -> { 'DYN_CURRENT' } = 1;
                }
                
                push( @permissions_for_dropdown, $hash );
        }

        return \@permissions_for_dropdown;
}


1;
