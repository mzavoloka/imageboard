use strict;

package localhost::register;

sub wendy_handler
{
        return ForumRegister -> run();
}

package ForumRegister;
use Moose;
extends 'ForumApp';

use Wendy::Shorts 'ar';
use Data::Dumper 'Dumper';

sub _run_modes { [ 'default', 'do_register' ] };

sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( defined $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'REGISTER_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> construct_page( message_tpl => 'register' );

  	return $output;
}

sub app_mode_do_register
{
        my $self = shift;

        my $username     = $self -> arg( 'username') || '';
      	my $email        = $self -> arg( 'email' ) || '';
      	my $password     = $self -> arg( 'password' ) || '';
      	my $confirmation = $self -> arg( 'confirmation' ) || '';

        my $output;

        if( my $error_msg = $self -> can_register_new_user( $username, $email, $confirmation, $password ) )
        {
                &ar( USERNAME => $username, EMAIL => $email );
                $output = $self -> construct_page( message_tpl => 'register', error_msg => $error_msg );
      	} else
        {
                $self -> do_register( $username, $password, $email, $confirmation );
                $output = $self -> ncrd( '/' );
        }

        return $output;
}

sub can_register_new_user
{
        my $self = shift;
        my $username = shift;
        my $email = shift;
        my $password = shift;
        my $confirmation = shift;
        
        my $error_msg = '';

        my $fields_are_filled = ( $username and $email and $password and $confirmation );

        my $valid_username;
        my $user_exists;
        my $valid_email;
        my $email_exists;
        my $password_confirmed;

        if( $fields_are_filled )
        {
                $valid_username = $self -> is_username_valid( $username );

                $user_exists = $self -> is_username_exists( $username );

                $valid_email = $self -> is_email_valid( $email );

                $email_exists = $self -> is_email_exists( $email );

      	        $password_confirmed = ( $password eq $confirmation );
        }
        
        if( not $fields_are_filled )
        {
        	$error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $fields_are_filled and ( not $valid_username ) )
        {
                $error_msg = 'INVALID_USERNAME';
        }
        elsif( $fields_are_filled and $valid_username and $user_exists )
        {
                $error_msg = 'USER_ALREADY_EXISTS';
        }
        elsif( $fields_are_filled and $valid_username and ( not $user_exists ) and ( not $valid_email ) )
        {
                $error_msg = 'INVALID_EMAIL';
        }
        elsif( $fields_are_filled and $valid_username and ( not $user_exists ) and $valid_email and $email_exists )
        {
                $error_msg = 'EMAIL_ALREADY_EXISTS';
        }
        elsif( $fields_are_filled and $valid_username and ( not $user_exists ) and $valid_email and ( not $email_exists ) and ( not $password_confirmed ) )
        {
        	$error_msg = 'PASSWORD_CONFIRMATION_FAILED';
        }

        return $error_msg;
}

sub do_register
{
        my $self = shift;
        my $username = shift;
      	my $password = shift;
      	my $email = shift;

        $username = lc( $username );
        $email = lc( $email );

        FModel::Users -> create( name => $username, password => $password, email => $email, registered => $self -> now() );

        $self -> log_user_in( $username );

        return;
}


1;
