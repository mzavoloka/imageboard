use Modern::Perl;

package mzavoloka_ru::register;

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
        elsif( $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'REGISTER_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> construct_page( middle_tpl => 'register' );

  	return $output;
}

sub app_mode_do_register
{
        my $self = shift;

        my $username = $self -> arg( 'username' );
      	my $email    = $self -> arg( 'email' );

        my $output;

        if( my $error_msg = $self -> can_register() )
        {
                &ar( USERNAME => $username, EMAIL => $email );
                $output = $self -> construct_page( middle_tpl => 'register', error_msg => $error_msg );
      	} else
        {
                $self -> do_register();
                $output = $self -> ncrd( '/' );
        }

        return $output;
}

sub can_register
{
        my $self = shift;

        my $username     = $self -> arg( 'username');
      	my $email        = $self -> arg( 'email' );
      	my $password     = $self -> arg( 'password' );
      	my $confirmation = $self -> arg( 'confirmation' );
        
        my $error_msg = '';

        my $fields_are_filled = ( $username and $email and $password and $confirmation );

        if( not $fields_are_filled )
        {
        	$error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( not $self -> is_username_valid( $username ) )
        {
                $error_msg = 'INVALID_USERNAME';
        }
        elsif( $self -> is_username_exists( $username ) )
        {
                $error_msg = 'USER_ALREADY_EXISTS';
        }
        elsif( not $self -> is_email_valid( $email ) )
        {
                $error_msg = 'INVALID_EMAIL';
        }
        elsif( $self -> is_email_exists( $email ) )
        {
                $error_msg = 'EMAIL_ALREADY_EXISTS';
        }
        elsif( not ( $password eq $confirmation ) )
        {
        	$error_msg = 'PASSWORD_CONFIRMATION_FAILED';
        }

        return $error_msg;
}

sub do_register
{
        my $self = shift;

        my $username = $self -> arg( 'username');
      	my $email    = $self -> arg( 'email' );
      	my $password = $self -> arg( 'password' );
        
        $username = lc( $username );
        $email = lc( $email );

        FModel::Users -> create( name => $username, password => $password, email => $email, registered => Funcs::now() );

        $self -> log_user_in( $username );

        return;
}


1;
