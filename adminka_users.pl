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
use Scalar::Util 'looks_like_number';

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'edit_user', 'search', 'cancel_search', 'do_edit_user', 'cancel_changes', 'create_user', 'do_create_user', 'delete_user' ] };


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

        my $output;

        if( my $error_msg = $self -> check_if_can_search() )
        {
                $output = $self -> show_users( error_msg => $error_msg );
        }
        else
        {
                $output = $self -> show_users();
        }

        return $output;
}

sub app_mode_default
{
        my $self = shift;

        $self -> mode( 'edit_user' );

        my $output = $self -> app_mode_edit_user();

        return $output;
}

sub app_mode_edit_user
{
        my ( $self, %params ) = @_;

        my $output = $self -> show_user_edit_form_with_db_values( success_msg => $params{ 'success_msg' } );

        return $output;
}

sub app_mode_do_edit_user
{
        my $self = shift;

        my $output;

        if( my $error_msg = $self -> check_if_can_edit_user() )
        {
                $output = $self -> show_user_edit_form_with_args_values( error_msg => $error_msg );
        }
        else
        {
                $self -> do_edit_user();
                $output = $self -> show_user_edit_form_with_db_values( success_msg => 'USER_SUCCESSFULLY_EDITED' );
        }

        return $output;
}

sub check_if_can_edit_user
{
        my $self = shift;

        my $error_msg = '';

        my $fields_are_filled = Funcs::trim( $self -> arg( 'id' ) ) and
                                Funcs::trim( $self -> arg( 'name' ) ) and
                                Funcs::trim( $self -> arg( 'password' ) ) and
                                Funcs::trim( $self -> arg( 'email' ) ) and
                                Funcs::trim( $self -> arg( 'registered' ) ) and
                                Funcs::trim( $self -> arg( 'permissions' ) );

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( my $id_error = $self -> check_if_can_edit_id() )
        {
                $error_msg = $id_error;
        }
        elsif( my $name_error = $self -> check_if_can_edit_name() )
        {
                $error_msg = $name_error;
        }
        elsif( my $password_error = $self -> check_if_can_edit_password() )
        {
                $error_msg = $password_error;
        }
        elsif( my $email_error = $self -> check_if_can_edit_email() )
        {
                $error_msg = $email_error;
        }
        elsif( my $permissions_error = $self -> check_if_can_edit_permissions() )
        {
                $error_msg = $permissions_error;
        }
        elsif( not $self -> is_registered_date_valid() )
        {
                $error_msg = 'INVALID_REGISTERED_DATE';
        }
        elsif( my $avatar_error = $self -> check_avatar_image() )
        {
                $error_msg = $avatar_error;
        }

        return $error_msg;
}

sub check_if_can_edit_id
{
        my $self = shift;

        my $error_msg = '';

        if( not &Funcs::is_id_field_value_valid( $self -> arg( 'id' ) ) )
        {
                $error_msg = 'INVALID_ID';
        }
        elsif( $self -> is_user_id_exists_except_id_of_currently_edited_user() )
        {
                $error_msg = 'USER_ID_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub is_user_id_exists_except_id_of_currently_edited_user
{
        my $self = shift;

        my $exists = 0;

        if( $self -> arg( 'id' ) != $self -> get_currently_edited_user() -> id() )
        {
                $exists = $self -> is_user_exists( $self -> arg( 'id' ) );
        }

        return $exists;
}

sub check_if_can_edit_name
{
        my $self = shift;
        
        my $error_msg = '';
        
        if( not $self -> is_username_valid( $self -> arg( 'name' ) ) )
        {
                $error_msg = 'INVALID_USERNAME';
        }
        elsif( $self -> is_username_exists_except_username_of_currently_edited_user() )
        {
                $error_msg = 'USERNAME_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub is_username_exists_except_username_of_currently_edited_user
{
        my $self = shift;

        my $exists = FModel::Users -> count( name => $self -> arg( 'name' ), name => { '!=', $self -> get_currently_edited_user() -> name() } );

        return $exists;
}

sub check_if_can_edit_password
{
        my $self = shift;

        my $error_msg = '';

        if( not $self -> is_password_valid( $self -> arg( 'password' ) ) )
        {
                $error_msg = 'PASSWORD_INVALID';
        }

        return $error_msg;
}

sub check_if_can_edit_email
{
        my $self = shift;

        my $error_msg;

        if( not $self -> is_email_valid( $self -> arg( 'email' ) ) )
        {
                $error_msg = 'INVALID_EMAIL';
        }
        elsif( not $self -> is_email_exists_except_email_of_currently_edited_user() )
        {
                $error_msg = 'EMAIL_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub is_email_exists_except_email_of_currently_edited_user
{
        my $self = shift;

        my $exists = FModel::Users -> count( email => $self -> arg( 'email' ), name => { '!=', $self -> get_currently_edited_user() -> email() } );

        return $exists;
}

{
        my $currently_edited_user;

        sub get_currently_edited_user
        {
                my $self = shift;

                # Если кэшировать таким образом, то иногда получается ошибка - если отредактировать одного пользователя и перейти к редактированию другого, то
                # этот метод будет отдавать предыдущего пользователя. Лечится просто рестартом сервера - это сбрасывает кэш.
                # Но я думал, что каждый раз делается новый инстанс приложения, и поэтому такого происходить не должно.
                #
                # if( not $currently_edited_user ) 
                {
                        $currently_edited_user = FModel::Users -> get( id => $self -> arg( 'currently_edited_user_id' ) );
                }

                return $currently_edited_user;
        }
}

sub check_if_can_edit_permissions
{
        my $self = shift;

        my $error_msg = '';

        if( not &Funcs::is_id_field_value_valid( $self -> arg( 'permissions' ) ) )
        {
                $error_msg = 'INVALID_PERMISSIONS_ID';
        }
        elsif( not $self -> do_permissions_exist( $self -> arg( 'permissions' ) ) )
        {
                $error_msg = 'NO_SUCH_PERMISSIONS';
        }

        return $error_msg;
}

sub do_permissions_exist
{
        my ( $self, $id ) = @_;

        my $exist = FModel::Permissions -> count( id => $id );

        return $exist;
}

sub is_registered_date_valid
{
        my $self = shift;

        my $valid = 1;

        if( not &Funcs::is_datetime_valid( $self -> arg( 'registered' ) ) )
        {
                $valid = 0;
        }

        return $valid;
}

sub do_edit_user
{
        my $self = shift;

        my $dbh = LittleORM::Db -> get_write_dbh();
        $dbh -> begin_work();
        
        my $user = $self -> get_currently_edited_user();

        $user -> id( $self -> arg( 'id' ) );
        $user -> name( $self -> arg( 'name' ) );
        $user -> password( $self -> arg( 'password' ) );
        $user -> email( $self -> arg( 'email' ) );

        my $permission = FModel::Permissions -> get( id => $self -> arg( 'permissions' ) );
        $user -> permission( $permission );

        my $strp = DateTime::Format::Strptime -> new( pattern => '%Y-%m-%d %T' );
        $user -> registered( $strp -> parse_datetime( $self -> arg( 'registered' ) ) );

        $user -> banned( $self -> arg( 'banned' ) ? 1 : 0 );

        $user -> update();

        $self -> upload_avatar();

        assert( $dbh -> commit() );

        return;
}

sub upload_avatar
{
        my $self = shift;

        my $avatar = $self -> upload( 'avatar' );

        my $filename = $self -> arg( 'id' );

        my $filepath = File::Spec -> catfile( ForumConst -> avatars_dir_abs(), $filename );

        if( cp( $avatar, $filepath ) )
        {
                my $user = FModel::Users -> get( id => $self -> arg( 'id' ) );
                $user -> avatar( $filename );
                $user -> update();
        }

        return;
}

sub check_avatar_image
{
        my ( $self, $image ) = @_;

        my $error_msg = '';

        my $image = $self -> upload( 'avatar' );

        my $filesize = -s $image;

        if( $image and not $self -> is_image_has_proper_filetype( $image ) )
        {
                $error_msg = 'AVATAR_INCORRECT_FILETYPE';
        }
        elsif( $image and $filesize > ForumConst -> avatar_max_filesize() )
        {
                $error_msg = 'AVATAR_FILESIZE_TOO_BIG';
        }

        return $error_msg;
}

sub app_mode_cancel_search
{
        my $self = shift;

        my $output = $self -> show_users_with_no_search_params();

        return $output;
}

sub app_mode_cancel_changes
{
        my $self = shift;

        my $output = $self -> show_user_edit_form_with_db_values();

        return $output;
}

sub show_user_edit_form_with_args_values
{
        my ( $self, %params ) = @_;

        my $output;

        if( my $id_error = $self -> check_if_proper_user_id_provided( $self -> arg( 'currently_edited_user_id' ) ) )
        {
                &ar( DYN_DONT_SHOW_USER_EDIT_FIELDS => 1 );
                $output = $self -> construct_page( middle_tpl => 'adminka_user_edit', error_msg => $id_error );
        }
        else
        {
                $self -> fill_user_edit_form_params_from_args();
                $output = $self -> construct_page( middle_tpl => 'adminka_user_edit', error_msg => $params{ 'error_msg' } );
        }

        return $output;
}

sub show_user_edit_form_with_db_values
{
        my ( $self, %params ) = @_;

        my $output;

        if( my $id_error = $self -> check_if_proper_user_id_provided( $self -> arg( 'currently_edited_user_id' ) || $self -> arg( 'id' ) ) )
        {
                &ar( DYN_DONT_SHOW_USER_EDIT_FIELDS => 1 );
                $output = $self -> construct_page( middle_tpl => 'adminka_user_edit', error_msg => $id_error );
        }
        else
        {
                $self -> fill_user_edit_form_params_from_db();
                $output = $self -> construct_page( middle_tpl => 'adminka_user_edit', success_msg => $params{ 'success_msg' } );
        }

        return $output;
}

sub check_if_can_search
{
        my $self = shift;

        my $error_msg = '';

        if( not &Funcs::is_id_field_value_valid( $self -> arg( 'id' ) ) )
        {
                $error_msg = 'INVALID_ID';
        }
        elsif( my $registered_error = $self -> check_if_registered_fields_valid() )
        {
                $error_msg = $registered_error;
        }
        elsif( my $num_of_messages_error = $self -> check_if_num_of_messages_fields_valid() )
        {
                $error_msg = $num_of_messages_error;
        }
        elsif( my $num_of_threads_error = $self -> check_if_num_of_threads_fields_valid() )
        {
                $error_msg = $num_of_threads_error;
        }

        return $error_msg;
}

sub check_if_registered_fields_valid
{
        my $self = shift;

        my $from = &Funcs::trim( $self -> arg( 'registered_from' ) );
        my $to   = &Funcs::trim( $self -> arg( 'registered_to' ) );
        
        my $error_msg = '';

        if( not &Funcs::is_date_valid( $from ) )
        {
                $error_msg = 'INVALID_REGISTERED_FROM';
        }
        elsif( not &Funcs::is_date_valid( $to ) )
        {
                $error_msg = 'INVALID_REGISTERED_TO';
        }
        elsif( $to ne '' and $from gt $to )
        {
                $error_msg = 'REGISTERED_FROM_COULD_NOT_BE_GREATER_THAN_TO';
        }

        return $error_msg;
}

sub check_if_num_of_messages_fields_valid
{
        my $self = shift;

        my $from = &Funcs::trim( $self -> arg( 'num_of_messages_from' ) );
        my $to   = &Funcs::trim( $self -> arg( 'num_of_messages_to' ) );
        
        my $error_msg = '';

        if( $from =~ /\D/ )
        {
                $error_msg = 'NUM_OF_MESSAGES_FROM_INVALID';
        }
        elsif( $to =~ /\D/ )
        {
                $error_msg = 'NUM_OF_MESSAGES_TO_INVALID';
        }
        elsif( $to ne '' and $from > $to )
        {
                $error_msg = 'NUM_OF_MESSAGES_FROM_COULD_NOT_BE_GREATER_THAN_TO';
        }
        
        return $error_msg;
}

sub check_if_num_of_threads_fields_valid
{
        my $self = shift;

        my $from = &Funcs::trim( $self -> arg( 'num_of_threads_from' ) );
        my $to   = &Funcs::trim( $self -> arg( 'num_of_threads_to' ) );
        
        my $error_msg = '';

        if( $from =~ /\D/ )
        {
                $error_msg = 'NUM_OF_THREADS_FROM_INVALID';
        }
        elsif( $to =~ /\D/ )
        {
                $error_msg = 'NUM_OF_THREADS_TO_INVALID';
        }
        elsif( $to ne '' and $from > $to )
        {
                $error_msg = 'NUM_OF_THREADS_FROM_COULD_NOT_BE_GREATER_THAN_TO';
        }
        
        return $error_msg;
}

sub show_users
{
        my ( $self, %params ) = @_;

        my $users = {};

        if( not $params{ 'error_msg' } )
        {
                my $page = int( $self -> arg( 'page' ) || $params{ 'page' } ) || 1;
                my $users_on_page = ForumConst -> users_on_page();
                $users = $self -> search_and_get_found_users_for_replace();
                my $count_of_users = scalar $users;

                my $show_from = ( $page - 1 ) * $users_on_page;
                my $show_to = Funcs::min_of( $show_from + $users_on_page, $count_of_users );
        }

        &ar( DYN_ID => $self -> arg( 'id' ),
             DYN_NAME => $self -> arg( 'name' ),
             DYN_EMAIL => $self -> arg( 'email' ),
             DYN_PASSWORD => $self -> arg( 'password' ),
             DYN_BANNED => $self -> arg( 'banned' ),
             DYN_REGISTERED_FROM => $self -> arg( 'registered_from' ),
             DYN_REGISTERED_TO => $self -> arg( 'registered_to' ),
             DYN_NUM_OF_MESSAGES_FROM => $self -> arg( 'num_of_messages_from' ),
             DYN_NUM_OF_MESSAGES_TO => $self -> arg( 'num_of_messages_to' ),
             DYN_NUM_OF_THREADS_FROM => $self -> arg( 'num_of_threads_from' ),
             DYN_NUM_OF_THREADS_TO => $self -> arg( 'num_of_threads_to' ),
             DYN_USERS => $users,
             DYN_PERMISSIONS => $self -> get_permissions_for_dropdown( selected_id => $self -> arg( 'permissions' ) ),
             DYN_ICON_DELETE_URL => ForumConst -> icon_delete_url(),
             DYN_NUM_OF_ADMINKA_USERS_COLS => ForumConst -> num_of_adminka_users_cols(),
             DYN_ARROWUP_IMAGE_URL => ForumConst -> arrowup_image_url(),
             DYN_ARROWDOWN_IMAGE_URL => ForumConst -> arrowdown_image_url(),
             DYN_ARROW_IMAGE_WIDTH => ForumConst -> arrow_image_width(),
             DYN_ARROW_IMAGE_HEIGHT => ForumConst -> arrow_image_height() );

        my $output = $self -> construct_page( middle_tpl => 'adminka_users', error_msg => $params{ 'error_msg' } );

        return $output;
}

sub show_users_with_no_search_params
{
        my ( $self, %params ) = @_;

        my $page = int( $self -> arg( 'page' ) || $params{ 'page' } ) || 1;

        my $users_on_page = ForumConst -> users_on_page();
        my $users = $self -> get_all_users();
        my $count_of_users = scalar $users;

        my $show_from = ( $page - 1 ) * $users_on_page;
        my $show_to = Funcs::min_of( $show_from + $users_on_page, $count_of_users );

        &ar( DYN_ID => '',
             DYN_NAME => '',
             DYN_EMAIL => '',
             DYN_PASSWORD => '',
             DYN_BANNED => 0,
             DYN_REGISTERED_FROM => '',
             DYN_REGISTERED_TO => '',
             DYN_NUM_OF_MESSAGES_FROM => '',
             DYN_NUM_OF_MESSAGES_TO => '',
             DYN_NUM_OF_THREADS_FROM => '',
             DYN_NUM_OF_THREADS_TO => '',
             DYN_ICON_DELETE_URL => ForumConst -> icon_delete_url(),
             DYN_USERS => $users,
             DYN_PERMISSIONS => $self -> get_permissions_for_dropdown(),
             DYN_NUM_OF_ADMINKA_USERS_COLS => ForumConst -> num_of_adminka_users_cols(),
             DYN_ARROWUP_IMAGE_URL => ForumConst -> arrowup_image_url(),
             DYN_ARROWDOWN_IMAGE_URL => ForumConst -> arrowdown_image_url(),
             DYN_ARROW_IMAGE_WIDTH => ForumConst -> arrow_image_width(),
             DYN_ARROW_IMAGE_HEIGHT => ForumConst -> arrow_image_height() );

        my $output = $self -> construct_page( middle_tpl => 'adminka_users' );

        return $output;
}


sub get_all_users
{
        my ( $self, %sort_params ) = @_;

        if( not %sort_params )
        {
                %sort_params = ( name => 'ASC' );
        }

        my @all_users_in_db = FModel::Users -> get_many( _sortby => [ %sort_params ] );

        my $users = $self -> get_users_for_replace( \@all_users_in_db );

        return $users;
}

sub search_and_get_found_users_for_replace
{
        my ( $self, %sort_params ) = @_;

        my $found_users = $self -> search_users( %sort_params );
        my $users_for_replace = $self -> get_users_for_replace( $found_users );

        return $users_for_replace;
}

sub get_users_for_replace
{
        my ( $self, $users ) = @_;

        my @users_for_replace = ();

        for my $user ( @$users )
        {
                my $hash = { DYN_ID     => $user -> id(),
                             DYN_NAME   => $user -> name(),
                             DYN_EMAIL  => $user -> email(),
                             DYN_PERMISSIONS => $user -> permission() -> title(),
                             DYN_REGISTERED => $user -> registered() -> dmy( '.' ),
                             DYN_NUM_OF_MESSAGES => $user -> get_num_of_messages(),
                             DYN_NUM_OF_THREADS => $user -> get_num_of_threads(),
                             DYN_BANNED => $user -> banned(),
                             DYN_SPECIAL_PERMISSION => ( not $user -> is_regular() ),
                             DYN_THATS_YOU => ( $user -> id() eq $self -> user() -> id() ) };

                push( @users_for_replace, $hash );
        }

        return \@users_for_replace;
}

sub search_users
{
        my ( $self, %sort_params ) = @_;

        if( not %sort_params )
        {
                %sort_params = ( name => 'ASC' );
        }

        my @found_users_matching_simple_search_params = FModel::Users -> get_many( $self -> get_search_conditions_for_orm(),
                                                                                   _sortby => [ %sort_params ] );

        my $found_users = [];

        my $complex_search_params_are_set = !!( int( $self -> arg( 'num_of_messages_from' ) ) or int( $self -> arg( 'num_of_messages_to' ) ) or
                                                int( $self -> arg( 'num_of_threads_from' ) ) or int( $self -> arg( 'num_of_threads_to' ) ) );

        if( $complex_search_params_are_set )
        {
                for my $user ( @found_users_matching_simple_search_params )
                {
                        if( $self -> does_num_of_messages_matches( $user ) and $self -> does_num_of_threads_matches( $user ) )
                        {
                                push( @$found_users, $user );
                        }
                }
        }
        else
        {
                $found_users = \@found_users_matching_simple_search_params;
        }

        return $found_users;
}

sub get_search_conditions_for_orm
{
        my $self = shift;

        my @search_conditions = ();

        if( $self -> arg( 'id' ) )
        {
                push( @search_conditions, ( 'id' => $self -> arg( 'id' ) ) );
        }
        if( $self -> arg( 'name' ) )
        {
                push( @search_conditions, $self -> like_param( 'name' ) );
        }
        if( $self -> arg( 'password' ) )
        {
                push( @search_conditions, $self -> like_param( 'password' ) );
        }
        if( $self -> arg( 'email' ) )
        {
                push( @search_conditions, $self -> like_param( 'email' ) );
        }
        if( $self -> arg( 'permissions' ) )
        {
                push( @search_conditions, ( 'permission' => int( $self -> arg( 'permissions' ) ) ) );
        }
        if( $self -> arg( 'banned' ) )
        {
                push( @search_conditions, ( 'banned' => int( $self -> arg( 'banned' ) ) ) );
        }
        if( $self -> arg( 'registered_from' ) or $self -> arg( 'registered_to' ) )
        {
                push( @search_conditions, $self -> date_param( 'registered' ) );
        }

        return @search_conditions;
}

sub date_param
{
        my ( $self, $param_name ) = @_;

        my $from = $self -> arg( $param_name . '_from' );
        my $to   = $self -> arg( $param_name . '_to'   );

        my $strp = DateTime::Format::Strptime -> new( pattern => '%Y-%m-%d' );

        my @conditions = ();

        if( $from ) 
        {
                push( @conditions, ( $param_name => { '>=', $strp -> parse_datetime( $from ) } ) );
        }
        if( $to )
        {
                push( @conditions, ( $param_name => { '<=', $strp -> parse_datetime( $to ) -> add( days => 1 ) } ) );
        }

        return @conditions;
}

sub does_num_of_messages_matches
{
        my ( $self, $user ) = @_;

        my $matches = 0;

        if( my $from = $self -> arg( 'num_of_messages_from' ) or my $to = $self -> arg( 'num_of_messages_to' ) )
        {
                $matches = $self -> is_num_in_range( $user -> get_num_of_messages(), $from, $to );
        }
        else
        {
                $matches = 1;
        }

        return $matches;
}

sub does_num_of_threads_matches
{
        my ( $self, $user ) = @_;

        my $matches = 0;

        if( my $from = $self -> arg( 'num_of_threads_from' ) or my $to = $self -> arg( 'num_of_threads_to' ) )
        {
                $matches = $self -> is_num_in_range( $user -> get_num_of_threads(), $from, $to );
        }
        else
        {
                $matches = 1;
        }

        return $matches;
}

sub is_num_in_range
{
        my ( $self, $num, $from, $to ) = @_;

        my $in_range = 0;

        my $from_matches = 0;
        if( $from )
        {
                if( $num >= $from )
                {
                        $from_matches = 1;
                }
        }
        else
        {
                $from_matches = 1;
        }

        my $to_matches = 0;
        if( $to )
        {
                if( $num <= $to )
                {
                        $to_matches = 1;
                }
        }
        else
        {
                $to_matches = 1;
        }

        if( $from_matches and $to_matches )
        {
                $in_range = 1;
        }

        return $in_range;
}

sub like_param
{
        my ( $self, $param_name ) = @_;

        my @condition = ( $param_name => { 'LIKE', "%" . $self -> arg( $param_name ) . "%" } );

        return @condition;
}

sub fill_user_edit_form_params_from_db
{
        my $self = shift;

        my $id = $self -> arg( 'currently_edited_user_id' ) || $self -> arg( 'id' );

        my $user = FModel::Users -> get( id => $id );

        if( $id eq $self -> user() -> id() )
        {
                &ar( DYN_THATS_YOU => 1 );
        }

        &ar( DYN_CURRENTLY_EDITED_USER_ID => $user -> id(),
             DYN_ID              => $user -> id(),
             DYN_NAME            => $user -> name(),
             DYN_PASSWORD        => $user -> password(),
             DYN_EMAIL           => $user -> email(),
             DYN_REGISTERED      => $user -> registered() -> strftime( '%Y-%m-%d %T' ),
             DYN_NUM_OF_MESSAGES => $user -> get_num_of_messages(),
             DYN_NUM_OF_THREADS  => $user -> get_num_of_threads(),
             DYN_AVATAR          => $user -> avatar_url(),
             DYN_BANNED          => $user -> banned(),
             DYN_PERMISSIONS     => $self -> get_permissions_for_dropdown( selected_id => $user -> permission() -> id() ) );

        return;
}

sub fill_user_edit_form_params_from_args
{
        my $self = shift;

        &ar( DYN_CURRENTLY_EDITED_USER_ID => $self -> arg( 'currently_edited_user_id' ),
             DYN_ID              => $self -> arg( 'id' ),
             DYN_NAME            => $self -> arg( 'name' ),
             DYN_PASSWORD        => $self -> arg( 'password' ),
             DYN_EMAIL           => $self -> arg( 'email' ),
             DYN_REGISTERED      => $self -> arg( 'registered' ),
             DYN_NUM_OF_MESSAGES => $self -> get_currently_edited_user() -> get_num_of_messages(),
             DYN_NUM_OF_THREADS  => $self -> get_currently_edited_user() -> get_num_of_threads(),
             DYN_AVATAR          => $self -> get_currently_edited_user() -> avatar_url(),
             DYN_BANNED          => $self -> arg( 'banned' ),
             DYN_PERMISSIONS     => $self -> get_permissions_for_dropdown( selected_id => $self -> arg( 'permissions' ) ) );

        return;
}

sub get_permissions_for_dropdown
{
        my ( $self, %params ) = @_;

        my $selected_id = $params{ 'selected_id' } || 0;

        my @permissions = FModel::Permissions -> get_many( _sortby => 'title' );

        my @permissions_for_dropdown = ();
        
        for my $permission ( @permissions )
        {
                my $hash = { DYN_ID => $permission -> id(),
                             DYN_TITLE => $permission -> title() };

                if( $selected_id eq $permission -> id() )
                {
                        $hash -> { 'DYN_CURRENT' } = 1;
                }
                
                push( @permissions_for_dropdown, $hash );
        }

        return \@permissions_for_dropdown;
}

sub app_mode_delete_user
{
        my $self = shift;

        my $output;

        if( my $error_msg = $self -> check_if_proper_user_id_provided( $self -> arg( 'id' ) ) )
        {
                $output = $self -> construct_page( error_msg => $error_msg );
                $self -> do_delete();
        }
        else
        {
                $self -> mode( 'search' );
                $output = $self -> app_mode_search();
        }

        return $output;
}

sub do_delete
{
        my $self = shift;

        my $user = FModel::Users -> get( $self -> arg( 'id' ) );
        $user -> deleted( 1 );
        $user -> update();

        return;
}

sub app_mode_create_user
{
        my $self = shift;

        &ar( DYN_PERMISSIONS => $self -> get_permissions_for_dropdown( selected_id => $self -> arg( 'permissions' ) ) );

        my $output = $self -> construct_page( middle_tpl => 'adminka_user_create' );

        return $output;
}

sub app_mode_do_create_user
{
        my $self = shift;

        my $output;

        if( my $error_msg = $self -> check_if_can_create_user() )
        {
                $output = $self -> construct_page( middle_tpl => 'adminka_user_create', error_msg => $error_msg );
        }
        else
        {
                if( $self -> do_create_user() )
                {
                        $self -> arg( 'currently_edited_user' ) = $self -> arg( 'id' );
                        $self -> mode( 'edit_user' );
                        $output = $self -> app_mode_edit_user( success_msg => 'USER_SUCCESSFULLY_CREATED' );
                }
                else
                {
                        $output = $self -> construct_page( error_msg => 'UNEXPECTED_ERROR' );
                }
        }

        return $output;
}

sub check_if_can_create_user
{
        my $self = shift;

        my $error_msg = '';

        my $fields_are_filled = Funcs::trim( $self -> arg( 'id' ) ) and
                                Funcs::trim( $self -> arg( 'name' ) ) and
                                Funcs::trim( $self -> arg( 'password' ) ) and
                                Funcs::trim( $self -> arg( 'email' ) ) and
                                Funcs::trim( $self -> arg( 'registered' ) ) and
                                Funcs::trim( $self -> arg( 'permissions' ) );

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( my $id_error = $self -> check_if_can_create_id() )
        {
                $error_msg = $id_error;
        }
        elsif( my $name_error = $self -> check_if_can_create_name() )
        {
                $error_msg = $name_error;
        }
        elsif( my $password_error = $self -> check_if_can_create_password() )
        {
                $error_msg = $password_error;
        }
        elsif( my $email_error = $self -> check_if_can_create_email() )
        {
                $error_msg = $email_error;
        }
        elsif( my $permissions_error = $self -> check_if_can_create_permissions() )
        {
                $error_msg = $permissions_error;
        }
        elsif( not $self -> is_registered_date_valid() )
        {
                $error_msg = 'INVALID_REGISTERED_DATE';
        }
        elsif( my $avatar_error = $self -> check_avatar_image() )
        {
                $error_msg = $avatar_error;
        }

        return $error_msg;
}

sub check_if_can_create_id
{
        my $self = shift;

        my $error_msg = '';

        if( not &Funcs::is_id_field_value_valid( $self -> arg( 'id' ) ) )
        {
                $error_msg = 'INVALID_ID';
        }
        elsif( $self -> is_user_exists( $self -> arg( 'id' ) )
        {
                $error_msg = 'USER_ID_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub check_if_can_create_name
{
        my $self = shift;
        
        my $error_msg = '';
        
        if( not $self -> is_username_valid( $self -> arg( 'name' ) ) )
        {
                $error_msg = 'INVALID_USERNAME';
        }
        elsif( $self -> is_username_exists() )
        {
                $error_msg = 'USERNAME_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub check_if_can_create_password
{
        my $self = shift;

        my $error_msg = '';

        if( not $self -> is_password_valid( $self -> arg( 'password' ) ) )
        {
                $error_msg = 'PASSWORD_INVALID';
        }

        return $error_msg;
}

sub check_if_can_create_email
{
        my $self = shift;

        my $error_msg;

        if( not $self -> is_email_valid( $self -> arg( 'email' ) ) )
        {
                $error_msg = 'INVALID_EMAIL';
        }
        elsif( not $self -> is_email_exists( $self -> arg( 'email' ) )
        {
                $error_msg = 'EMAIL_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub check_if_can_create_permissions
{
        my $self = shift;

        my $error_msg = '';

        if( not &Funcs::is_id_field_value_valid( $self -> arg( 'permissions' ) ) )
        {
                $error_msg = 'INVALID_PERMISSIONS_ID';
        }
        elsif( not $self -> do_permissions_exist( $self -> arg( 'permissions' ) ) )
        {
                $error_msg = 'NO_SUCH_PERMISSIONS';
        }

        return $error_msg;
}

sub do_create


1;
