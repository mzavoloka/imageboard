package localhost::profile;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumProfile -> run();
}

package ForumProfile;
use strict;
use Moose;
extends 'ForumApp';

use Wendy::Templates::TT qw( tt );
use Wendy::Db qw( wdbconnect dbprepare wdbprepare );
use Data::Dumper 'Dumper';
use Wendy::Shorts 'ar';

sub _run_modes { [ 'default', 'change_email', 'change_password', 'search' ] };

sub app_mode_default
{
	my $self = shift;

        my $output = {};
        if( $self -> user() )
        {
                my $username = $self -> arg( 'username' ) || $self -> user() || '';
                my $error_msg = $self -> add_profile_data( $username );
                $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg );
        } else
        {
                $output = $self -> construct_page( restricted_msg => 'PROFILE_RESTRICTED' );
        }

  	return $output;
}

sub app_mode_change_email
{
        my $self = shift;

        my $output = {};
        if( $self -> user() )
        {       
                my $email = $self -> arg( 'email' ) || '';
                my $error_msg = $self -> change_email( $email );
                my $success_msg = '';
                unless( $error_msg )
                {
                        $success_msg = 'EMAIL_CHANGED';
                }
                $self -> add_profile_data();
                $output = $self -> construct_page( middle_tpl => 'profile', error_msg => $error_msg, success_msg => $success_msg );
        } else
        {
                $output = $self -> construct_page( restricted_msg => 'PROFILE_RESTRICTED' );
        }

  	return $output;
}

sub app_mode_change_password
{
        my $self = shift;

        my $change_button_pressed = $self -> arg( 'change' ) || '';

        my $output = {};
        if( $self -> user() )
        {
                if( $change_button_pressed )
                {
                        my $current_password = $self -> arg( 'current_password' ) || '';
                        my $new_password = $self -> arg( 'new_password' ) || '';
                        my $new_password_confirmation = $self -> arg( 'new_password_confirmation' ) || '';

                        my $error_msg = $self -> change_password( $current_password, $new_password, $new_password_confirmation );
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
        } else
        {
                $output = $self -> construct_page( restricted_msg => 'PROFILE_RESTRICTED' );
        }

  	return $output;
}

sub add_profile_data
{
        my $self = shift;
        my $user = shift || $self -> user() || '';

        my $error_msg = '';
        my $sth = &dbprepare( "SELECT id, name, registered, email FROM users WHERE name = ?" );
        $sth -> bind_param( 1, $user );
        $sth -> execute();
        my ( $id, $name, $registered, $email ) = $sth -> fetchrow_array();

        if( $user eq $self -> user() )
        {
                &ar( USER_HOME_PROFILE => 1 );
        } 

        if( $id )
        {
                $sth = &dbprepare( "SELECT date FROM messages WHERE author = ?" ); 
                $sth -> bind_param( 1, $user );
                $sth -> execute();
                my $num_of_messages = scalar( @{ $sth -> fetchall_arrayref() } );
                &ar( NAME => $name, ID => $id, REGISTERED => $self -> readable_date( $registered ), EMAIL => $email, NUM_OF_MESSAGES => $num_of_messages );
        }
        else
        {
                $error_msg = 'USER_NOT_FOUND';
        }

        $sth -> finish();

        return $error_msg;
}

sub change_email
{
        my $self = shift;
        my $email = shift;

        my $error_msg = '';

        if( $self -> is_email_valid( $email ) )
        {
                &wdbconnect();
                my $sth = &wdbprepare( "UPDATE users SET email = ? WHERE name = ?" );
                $sth -> bind_param( 1, $email );
                $sth -> bind_param( 2, $self -> user() );
                $sth -> execute();

                $sth -> finish();
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
        my $current_password = shift;
        my $new_password = shift;
        my $new_password_confirmation = shift;

        my $error_msg = '';

        my $all_fields_are_filled = ( ($current_password ne '') and
                                        ( $new_password ne '' ) and
                                        ( $new_password_confirmation ne '' ) );
        if( $all_fields_are_filled )
        {
                my $sth = &dbprepare( "SELECT password FROM users WHERE name = ?" );
                $sth -> bind_param( 1, $self -> user() );
                $sth -> execute();
                my ( $current_password_db ) = $sth -> fetchrow_array();
                my $current_password_correct = ( $current_password eq $current_password_db );
                if( $current_password_correct )
                {
                        my $new_password_confirmed = ( $new_password eq $new_password_confirmation );
                        if ( $new_password_confirmed )
                        {
                                &wdbconnect();
                                my $sth = &wdbprepare( "UPDATE users SET password = ? WHERE name = ?" );
                                $sth -> bind_param( 1, $new_password );
                                $sth -> bind_param( 2, $self -> user() );
                                $sth -> execute();
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
                $sth -> finish();
        }
        else
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }

        return $error_msg;
}


1;
