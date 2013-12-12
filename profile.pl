use strict;

package localhost::profile;

sub wendy_handler
{
        my $self = shift;
        return ForumProfile -> run();
}

package ForumProfile;
use Moose;
extends 'ForumApp';

use Data::Dumper 'Dumper';
use Wendy::Shorts 'ar';

sub _run_modes { [ 'default', 'change_email', 'change_password', 'search' ] };

sub always
{
        my $self = shift;

        my $rv;

        unless( $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'PROFILE_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
	my $self = shift;

        my $username = $self -> arg( 'username' ) || $self -> user() || '';

        my $error_msg = '';
        if( $self -> is_user_exists( $username ) )
        {
                $self -> add_profile_data( $username );
        } else
        {
                $error_msg = 'USER_NOT_FOUND';
        }

        my $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg );

  	return $output;
}

sub app_mode_change_email
{
        my $self = shift;

        my $email = $self -> arg( 'email' ) || '';
        $email = lc( $email );

        my $error_msg = '';
        my $success_msg = '';

        if( $self -> is_email_valid( $email ) )
        {
                $self -> change_email( $email );
                $success_msg = 'EMAIL_CHANGED';
        }
        else
        {
                $error_msg = 'INVALID_EMAIL';
        }

        $self -> add_profile_data( $self -> user() );
        my $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg, success_msg => $success_msg );

  	return $output;
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

                if( my $error_msg = $self -> can_change_password( $current_password, $new_password, $new_password_confirmation, $self -> user() ) )
                {
                        $output = $self -> construct_page( middle_tpl => 'change_password', error_msg => $error_msg );
                } else
                {
                        $self -> change_password( $self -> user(), $new_password );
                        $self -> add_profile_data( $self -> user() );
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
        my $username = shift;

        my $error_msg = '';

        my $fields_are_filled = ( ($current_password ne '') and
                                      ( $new_password ne '' ) and
                                      ( $new_password_confirmation ne '' ) );

        my $user = FModel::Users -> get( name => $self -> user() );
        my $password_in_db = $user -> password();
        my $current_password_correct = ( $current_password eq $password_in_db );

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

sub add_profile_data
{
        my $self = shift;
        my $username = shift;

        my $user = FModel::Users -> get( name => $username );

        if( $user -> name() eq $self -> user() )
        {
                &ar( USER_HOME_PROFILE => 1 );
        } 

        my $num_of_messages = FModel::Messages -> count( author => $user );

        &ar( NAME => $user -> name(), ID => $user -> id(), REGISTERED => $self -> readable_date( $user -> registered() ), 
             EMAIL => $user -> email(), NUM_OF_MESSAGES => $num_of_messages );

        return;
}

sub change_email
{
        my $self = shift;
        my $email = shift;
        $email = lc( $email );

        my $user = FModel::Users -> get( name => $self -> user() );
        $user -> email( $email );
        $user -> update();

        return;
}

sub change_password
{
        my $self = shift;
        my $username = shift;
        my $new_password = shift;

        my $user = FModel::Users -> get( name => $username );
        $user -> password( $new_password );
        $user -> update();

        return;
}


1;
