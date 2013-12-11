package localhost::profile;
use strict;

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

        my $error_msg = $self -> change_email( $email );
        my $success_msg = '';

        unless( $error_msg )
        {
                $success_msg = 'EMAIL_CHANGED';
        }

        $self -> add_profile_data();
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

                my $all_fields_are_filled = ( ($current_password ne '') and
                                                ( $new_password ne '' ) and
                                                ( $new_password_confirmation ne '' ) );
                # All error checks should be done in special function
                my $error_msg = '';

                if( $all_fields_are_filled )
                {
                        my $user = FModel::Users -> get( name => $self -> user() );

                        my $current_password_correct = ( $current_password eq $user -> password() );
                        if( $current_password_correct )
                        {
                                my $new_password_confirmed = ( $new_password eq $new_password_confirmation );
                                if ( $new_password_confirmed )
                                {
                                        $self -> change_password( $user -> name(), $new_password );
                                }
                                else
                                {
                                        $error_msg = 'NEW_PASSWORD_CONFIRMATION_FAILED';
                                }
                        }
                        else
                        {
                                $error_msg = 'CURRENT_PASSWORD_INCORRECT';
                        }
                }
                else
                {
                        $error_msg = 'FIELDS_ARE_NOT_FILLED';
                }

                if( $error_msg )
                {
                        $output = $self -> construct_page( middle_tpl => 'change_password', error_msg => $error_msg );
                } else
                {
                        my $success_msg = 'PASSWORD_CHANGED';
                        $self -> add_profile_data();
                        $output = $self -> construct_page( middle_tpl => 'profile', success_msg => $success_msg );
                }
        } else
        {
                $output = $self -> construct_page( middle_tpl => 'change_password' );
        }

  	return $output;
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

        my $error_msg = '';

        if( $self -> is_email_valid( $email ) )
        {

                my $user = FModel::Users -> get( name => $self -> user() );
                $user -> email( $email );
                $user -> update();
        }
        else
        {
                $error_msg = 'INVALID_EMAIL';
        }

        return $error_msg;
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
