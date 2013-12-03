package localhost::register;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumRegister -> run();
}

package ForumRegister;
use strict;
use Moose;
extends 'ForumApp';

use Wendy::Templates::TT 'tt';
use Wendy::Db qw( wdbconnect wdbprepare dbprepare );
use Wendy::Shorts 'ar';
use Data::Dumper 'Dumper';

sub _run_modes { [ 'default', 'do_register' ] };

sub app_mode_default
{
        my $self = shift;

        my $output = {};

        if( $self -> user() )
        {
                $output = $self -> construct_page( restricted_msg => 'REGISTER_RESTRICTED' );
        } else
        {
                $output = $self -> construct_page( message_tpl => 'register' );
        }

  	return $output;
}

sub app_mode_do_register
{
        my $self = shift;

        my $output = {};

        if( $self -> user() )
        {
                $output = $self -> construct_page( restricted_msg => 'REGISTER_RESTRICTED' );
        } else
        {
                my $username = $self -> arg( 'username') || '';
      	        my $password = $self -> arg( 'password' ) || '';
      	        my $email = $self -> arg( 'email' ) || '';
      	        my $confirmation = $self -> arg( 'confirmation' ) || '';

      	        my $error_msg = $self -> do_register( $username, $password, $email, $confirmation );
                if( $error_msg )
                {
                        $output = $self -> construct_page( message_tpl => 'register', error_msg => $error_msg );
                } else
                {
                        $output = $self -> ncrd( '/' );
                }
        }

        return $output;
}

sub do_register
{
        my $self = shift;
        my $username = shift;
      	my $password = shift;
      	my $email = shift;
      	my $confirmation = shift;

        my $error_msg = '';
      	my $password_confirmed = ( $password eq $confirmation );
        if( $username and $password and $password_confirmed and $self -> is_email_valid( $email ) and $self -> is_username_valid( $username ) )
	{
        	my $sth = &dbprepare( "SELECT id FROM users WHERE name = ?" );
        	$sth -> bind_param( 1, $username );
        	$sth -> execute();
        	my $exists = $sth -> rows();
	        if( $exists )
        	{
                        $error_msg = 'USER_ALREADY_EXISTS';
        	} else
		{
        		&wdbconnect();
        		$sth = &wdbprepare( "INSERT INTO users (name, password, email, registered) VALUES (?, ?, ?, now())" );
        		$sth -> bind_param( 1, $username );
		        $sth -> bind_param( 2, $password );
        		$sth -> bind_param( 3, $email );
        		$sth -> execute();
        		$self -> log_user_in( $username );
        	}
                $sth -> finish();
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

        return $error_msg;
}


1;
