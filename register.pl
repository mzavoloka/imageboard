package localhost::register;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumRegister -> run();
}

package ForumRegister;
use Moose;
extends 'ForumApp';

use Wendy::Shorts 'ar';
use Data::Dumper 'Dumper';

sub _run_modes { [ 'default', 'do_register' ] };

sub always
{
        my $self = shift;

        my $rv;

        if( $self -> user () )
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

        my $username = $self -> arg( 'username') || '';
      	my $password = $self -> arg( 'password' ) || '';
      	my $email = $self -> arg( 'email' ) || '';
      	my $confirmation = $self -> arg( 'confirmation' ) || '';

        my $error_msg = '';
      	my $password_confirmed = ( $password eq $confirmation );

        # All error checks should be done in special function
        if( $username and $password and $password_confirmed and $self -> is_email_valid( $email )
            and $self -> is_username_valid( $username ) and ( not $self -> is_email_exists( $email ) ) )
	{
	        if( $self -> is_username_exists( $username ) )
                {
                        $error_msg = 'USER_ALREADY_EXISTS';
                } else
	        {
                        $self -> do_register( $username, $password, $email, $confirmation );
                }
      	}
        elsif( not ( $username and $password and $email and $confirmation ) )
        {
        	$error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( not $self -> is_username_valid( $username ) )
        {
                $error_msg = 'INVALID_USERNAME';
        }
        elsif( $email and ( not $self -> is_email_valid( $email ) ) )
        {
                $error_msg = 'INVALID_EMAIL';
        }
        elsif( $email and $self -> is_email_exists( $email ) )
        {
                $error_msg = 'EMAIL_ALREADY_EXISTS';
        }
        elsif( $password and ( not $password_confirmed ) )
	{
        	$error_msg = 'PASSWORD_CONFIRMATION_FAILED';
	} else
	{
                $error_msg = 'UNEXPECTED_ERROR';
      	}

        &ar( USERNAME => $username, 
                EMAIL => $email );
        
        my $output;

        if( $error_msg )
        {
                $output = $self -> construct_page( message_tpl => 'register', error_msg => $error_msg );
        } else
        {
                $output = $self -> ncrd( '/' );
        }

        return $output;
}

sub do_register
{
        my $self = shift;
        my $username = shift;
      	my $password = shift;
      	my $email = shift;

        $username = lc( $username );
        $email = lc( $email );

        FModel::Users -> create( name => $username, password => $password, email => $email, registered => 'now()' );
        $self -> log_user_in( $username );

        return;
}


1;
