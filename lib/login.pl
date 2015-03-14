use Modern::Perl;

package mzavoloka_ru::login;

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

        my $output;

        if( my $error_msg = $self -> can_log_user_in() )
        {
                &ar( DYN_USERNAME => $self -> arg( 'username' ) );
                $output = $self -> construct_page( middle_tpl => 'login', error_msg => $error_msg );
        } else
        {
        	$self -> log_user_in( $self -> arg( 'username' ) );
                $output = $self -> ncrd( '/' );
        }

  	return $output;
}

sub can_log_user_in
{
        my ( $self, $username, $password ) = @_;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> arg( 'username' ) and $self -> arg( 'password' ) );

      	if( not $fields_are_filled )
	{
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
      	}
        elsif( not $self -> is_username_exists( $self -> arg( 'username' ) ) or
               not $self -> is_password_correct() )
        {
                $error_msg = 'NO_USER_WITH_SUCH_PASSWORD';
      	}
        elsif( FModel::Users -> get( name => $self -> arg( 'username' ) ) -> banned() )
        {
                $error_msg = 'YOU_ARE_BANNED';
        }

        return $error_msg;
}

sub is_password_correct
{
        my ( $self ) = @_;

        my $correct = FModel::Users -> count( name => $self -> arg( 'username' ), password => $self -> arg( 'password' ) );

        return $correct;
}


1;
