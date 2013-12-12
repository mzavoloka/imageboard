use strict;

package localhost::login;

sub wendy_handler
{
        my $self = shift;
        return ForumLogin -> run();
}

package ForumLogin;
use Moose;
extends 'ForumApp';

use Wendy::Shorts 'ar' ;
use Data::Dumper 'Dumper';

sub _run_modes { [ 'default', 'do_login' ] }

sub always
{
        my $self = shift;

        my $rv;

        if( $self -> user () )
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
        my $self = shift;
        my $username = shift;
        my $password = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $username and $password );

        my $user = FModel::Users -> get( name => $username );
        
        my $user_exists = $self -> is_user_exists( $username );

        my $password_correct = $self -> is_password_correct( $password, $username );

      	if( not $fields_are_filled )
	{
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
      	}
        elsif( $fields_are_filled and ( not $user_exists ) )
	{
        	$error_msg = 'NO_SUCH_USER';
      	}
        elsif( $fields_are_filled and $user_exists and ( not $password_correct ) )
        {
                $error_msg = 'PASSWORD_INCORRECT';
        }

        return $error_msg;
}

sub is_password_correct
{
        my $self = shift;
        my $password = shift;
        my $username = shift;

        my $correct = 0;

        if( $self -> is_user_exists( $username ) )
        {
                my $user = FModel::Users -> get( name => $username );
                my $password_in_db = $user -> password();

                $correct = ( $password eq $password_in_db );
        }

        return $correct;
}


1;
