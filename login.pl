package localhost::login;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumLogin -> run();
}

package ForumLogin;
use Moose;
extends 'ForumApp';

use Wendy::Templates::TT 'tt';
use Wendy::Shorts 'ar' ;
use Data::Dumper 'Dumper';

sub _run_modes { [ 'default', 'do_login' ] }

sub app_mode_default
{
        my $self = shift;

        my $output = {};
        if( $self -> user() )
        {
                $output = $self -> construct_page( restricted_msg => 'LOGIN_RESTRICTED' );
        } else
        {
                $output = $self -> construct_page( middle_tpl => 'login' );
        }

        return $output;
}

sub app_mode_do_login
{
        my $self = shift;

        my $error_msg = '';
        my $output = {};

        if( $self -> user() )
        {
                $output = $self -> construct_page( restricted_msg => 'LOGIN_RESTRICTED' );
        } else
        {
      	        my $username = $self -> arg( 'username' ) || '';
      	        my $password = $self -> arg( 'password' ) || '';
                my $success = 0;
                
      	        if( $username and $password )
	        {
                        my $user = FModel::Users -> get( name => $username );

                	if( $user -> name() )
                	{
                                my $password_correct = ( $password eq $user -> password() );
                                if( $password_correct )
                                {
                		        $self -> log_user_in( $username );
                                        $success = 1;
                                } else
                                {
                                        $error_msg = 'PASSWORD_INCORRECT';
                                }
                	} else
	        	{
                		$error_msg = 'NO_SUCH_USER';
                	}

      	        } else
	        {
                        $error_msg = 'FIELDS_ARE_NOT_FILLED';
      	        }
                
                &ar( USERNAME => $username );
                if( $success )
                {
                        $output = $self -> ncrd( '/' );
                } else
                {
                        $output = $self -> construct_page( middle_tpl => 'login', error_msg => $error_msg );
                }
        }

  	return $output;
}


1;
