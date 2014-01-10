use strict;

package localhost::login;

sub wendy_handler
{
        return ForumLogin -> run();
}

package ForumLogin;
use Moose;
extends 'ForumApp';

use Wendy::Shorts 'ar' ;
use Data::Dumper 'Dumper';

sub _run_modes { [ 'default', 'do_login' ] }

sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'LOGIN_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> construct_page( middle_tpl => 'login' );

        return $output;
}

sub app_mode_do_login
{
        my $self = shift;

      	my $username = $self -> arg( 'username' );
      	my $password = $self -> arg( 'password' );

        my $output;

        if( my $error_msg = $self -> can_log_user_in( $username, $password ) )
        {
                &ar( USERNAME => $username );
                $output = $self -> construct_page( middle_tpl => 'login', error_msg => $error_msg );
        } else
        {
        	$self -> log_user_in( $username );
                $output = $self -> ncrd( '/' );
        }

  	return $output;
}

sub can_log_user_in
{
        my ( $self, $username, $password ) = @_;

        my $error_msg = '';

        my $fields_are_filled = ( $username and $password );

        my $user;
        my $user_exists;
        my $password_correct;

        if( $fields_are_filled )
        {
                $user = FModel::Users -> get( name => $username );
                $password_correct = $self -> is_password_correct( $password, $username );
        }

      	if( not $fields_are_filled )
	{
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
      	}
        elsif( not $password_correct )
	{
        	$error_msg = 'NO_USER_WITH_SUCH_PASSWORD';
      	}
        elsif( $user -> banned() )
        {
                $error_msg = 'YOU_ARE_BANNED';
        }

        return $error_msg;
}

sub is_password_correct
{
        my ( $self, $password, $username ) = @_;

        my $correct = FModel::Users -> count( name => $username, password => $password );

        return $correct;
}


1;
