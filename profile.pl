use strict;

package localhost::profile;

sub wendy_handler
{
        return ForumProfile -> run();
}

package ForumProfile;
use Moose;
extends 'ForumApp';

use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr );
use File::Copy 'cp';
use ForumConst qw( avatars_dir_abs );

sub _run_modes { [ 'default', 'change_email', 'change_password', 'search', 'upload_avatar', 'ban', 'unban' ] };

sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( not $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'PROFILE_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
	my $self = shift;

        my $username = $self -> arg( 'username' ) || $self -> user() -> name() || '';

        my $error_msg = '';

        if( $self -> is_username_exists( $username ) )
        {
                my $user = FModel::Users -> get( name => $username );
                $self -> add_profile_data( $user -> id() );
        } else
        {
                $error_msg = 'USER_NOT_FOUND';
		&ar( DONT_SHOW_PROFILE_INFO => 1 );
        }

        my $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg );

  	return $output;
}

sub app_mode_change_email
{
        my $self = shift;

        my $output;

        if( my $error_msg = $self -> can_change_email() )
        {
                $self -> add_profile_data( $self -> user() -> id() );
                $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg );
        } else
        {
                $self -> change_email();
                $self -> add_profile_data( $self -> user() -> id() );
                $output = $self -> construct_page( middle_tpl => 'profile', success_msg => 'EMAIL_CHANGED' );
        }

  	return $output;
}

sub can_change_email
{
        my $self = shift;

        my $email = $self -> arg( 'email' ) || '';

        my $error_msg = '';

        my $email_valid = $self -> is_email_valid( $email );

        if( not $email_valid )
        {
                $error_msg = 'INVALID_EMAIL';
        }
        elsif( $email_valid and $self -> is_email_exists_except_user( $email, $self -> user() -> id() ) )
        {
                $error_msg = 'EMAIL_ALREADY_EXISTS';
        }

        return $error_msg;
}

sub app_mode_change_password
{
        my $self = shift;

        my $output;

        my $change_button_pressed = $self -> arg( 'change' ) || '';

        if( $change_button_pressed )
        {
                my $current_password = $self -> arg( 'current_password' ) || '';
                my $new_password = $self -> arg( 'new_password' ) || '';
                my $new_password_confirmation = $self -> arg( 'new_password_confirmation' ) || '';

                if( my $error_msg = $self -> can_change_password( $current_password, $new_password, $new_password_confirmation ) )
                {
                        $output = $self -> construct_page( middle_tpl => 'change_password', error_msg => $error_msg );
                } else
                {
                        $self -> change_password( $self -> user() -> id(), $new_password );
                        $self -> add_profile_data( $self -> user() -> id() );
                        $output = $self -> construct_page( middle_tpl => 'profile', success_msg => 'PASSWORD_CHANGED' );
                }
        } else
        {
                $output = $self -> construct_page( middle_tpl => 'change_password' );
        }

  	return $output;
}

sub can_change_password
{
        my $self = shift;
        my $current_password = shift;
        my $new_password = shift;
        my $new_password_confirmation = shift;

        my $error_msg = '';

        my $fields_are_filled = ( ($current_password ne '') and
                                  ( $new_password ne '' ) and
                                  ( $new_password_confirmation ne '' ) );

        my $user;
        my $current_password_correct;
        my $password_in_db;

        if( $fields_are_filled )
        {
                $user = FModel::Users -> get( id => $self -> user() -> id() );
                $password_in_db = $user -> password();
                $current_password_correct = ( $current_password eq $password_in_db );
        }

        my $new_password_confirmed = ( $new_password eq $new_password_confirmation );

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $fields_are_filled and ( not $current_password_correct ) )
        {
                $error_msg = 'CURRENT_PASSWORD_INCORRECT';
        }
        elsif( $fields_are_filled and $current_password_correct and ( not $new_password_confirmed ) )
        {
                $error_msg = 'NEW_PASSWORD_CONFIRMATION_FAILED';
        }

        return $error_msg;
}

sub app_mode_upload_avatar
{
        my $self = shift;

        my $avatar = $self -> upload( 'avatar' );

        my $output;

        if( my $error_msg = $self -> can_upload_avatar( $avatar ) )
        {
                $self -> add_profile_data( $self -> user() -> id() );
                $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg );
        } else
        {
                my $filename = $self -> user() -> id();

                my $filepath = ForumConst -> avatars_dir_abs() . $filename;

                if( cp( $avatar, $filepath ) )
                {
                        my $user = FModel::Users -> get( id => $self -> user() -> id() );
                        $user -> avatar( $filename );
                        $user -> update();

                        $self -> add_profile_data( $self -> user() -> id() );
                        $output = $self -> construct_page( middle_tpl => 'profile', success_msg => 'AVATAR_UPLOADED' );
                } else
                {
                        my $error_msg = 'AVATAR_NOT_UPLOADED' . "\n$!";
                        $self -> add_profile_data( $self -> user() -> id() );
                        $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg );
                }
        }

        return $output;
}

sub can_upload_avatar
{
        my $self = shift;
        my $avatar = shift || '';

        my $error_msg = '';

        my $filesize = -s $avatar;

        if( not $avatar )
        {
                $error_msg = 'AVATAR_FILE_NOT_CHOSEN';
        }
        elsif( $avatar and ( CGI::uploadInfo( $avatar ) -> { 'Content-Type' } ne 'image/jpeg' ) ) # Add macros for this thing with list of correct filetypes
        {
                $error_msg = 'AVATAR_INCORRECT_FILETYPE';
        }
        elsif( $avatar and $filesize > &gr( 'AVATAR_MAX_SIZE' ) )
        {
                $error_msg = 'AVATAR_FILESIZE_TOO_BIG';
        }

        return $error_msg;
}

sub add_profile_data
{
        my $self = shift;
        my $user_id = shift;

        my $user = FModel::Users -> get( id => $user_id );

        if( $user -> name() eq $self -> user() -> name() )
        {
                &ar( USER_HOME_PROFILE => 1 );
        }

        my $num_of_messages = FModel::Messages -> count( user_id => $user -> id() );

        my $num_of_threads = FModel::Threads -> count( user_id => $user -> id() );

        &ar( NAME => $user -> name(), ID => $user -> id(), REGISTERED => $self -> readable_date( $user -> registered() ),
             EMAIL => $user -> email(), NUM_OF_MESSAGES => $num_of_messages, NUM_OF_THREADS => $num_of_threads,
             AVATAR => $user -> get_avatar_src(), USER_ID => $user -> id(),
             CAN_BAN => $self -> can_do_action_with_user( 'ban', $user -> id() ), BANNED => $user -> banned(),
             PERMISSIONS => $user -> get_special_permission_title() );

        return;
}

sub change_email
{
        my $self = shift;

        my $email = $self -> arg( 'email' ) || '';

        $email = lc( $email );

        my $user = FModel::Users -> get( id => $self -> user() -> id() );
        $user -> email( $email );
        $user -> update();

        return;
}

sub change_password
{
        my $self = shift;
        my $user_id = shift;
        my $new_password = shift;

        my $user = FModel::Users -> get( id => $user_id );
        $user -> password( $new_password );
        $user -> update();

        return;
}

sub app_mode_ban
{
        my $self = shift;

        my $user_id = $self -> arg( 'user_id' );

        my $output;

        if( $self -> can_do_action_with_user( 'ban', $user_id ) )
        {
                $self -> ban( $user_id );

                $self -> add_profile_data( $user_id );
                $output = $self -> construct_page( middle_tpl => 'profile' ); 
        }
        else
        {
                &ar( 'DONT_SHOW_PROFILE_INFO' => 1 );
                $output = $self -> construct_page( middle_tpl => 'profile', error_msg => 'CANNOT_BAN_USER' );
        }

        return $output;
}

sub ban
{
        my $self = shift;
        my $user_id = shift;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_user_id_provided( $user_id ) )
        {
                my $user = FModel::Users -> get( id => $user_id );
                $user -> banned( 1 );
                $user -> update();
                $success = 1;
        }

        return $success;
}

sub app_mode_unban
{
        my $self = shift;

        my $user_id = $self -> arg( 'user_id' );

        my $output;

        if( $self -> can_do_action_with_user( 'unban', $user_id ) )
        {
                $self -> unban( $user_id );

                $self -> add_profile_data( $user_id );
                $output = $self -> construct_page( middle_tpl => 'profile' ); 
        }
        else
        {
                &ar( 'DONT_SHOW_PROFILE_INFO' => 1 );
                $output = $self -> construct_page( middle_tpl => 'profile', error_msg => 'CANNOT_UNBAN_USER' );
        }

        return $output;
}

sub unban
{
        my $self = shift;
        my $user_id = shift;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_user_id_provided( $user_id ) )
        {
                my $user = FModel::Users -> get( id => $user_id );
                $user -> banned( 0 );
                $user -> update();
                $success = 1;
        }

        return $success;
}


1;
