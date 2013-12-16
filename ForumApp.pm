use strict;

package ForumApp;

use LittleORM::Db 'init';
use FModel::Users;
use FModel::Sessions;
use FModel::Messages;
use FModel::Threads;
use Wendy::Templates::TT 'tt';
use Wendy::Db qw( dbconnect );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use Digest::MD5 'md5_base64';
use DateTime;

use Moose;
extends 'Wendy::App';

has 'user' => ( is => 'rw', isa => 'Str' );
has 'user_id' => ( is => 'rw', isa => 'Int' );
has 'session_expires_after' => ( is => 'rw', isa => 'Int', default => 900 );

sub init
{
        my $self = shift;

        my $rv = '';
        LittleORM::Db -> init( &dbconnect() );

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        } else
        {
                $self -> init_user();
        }

        &lm();

        return $rv;
}

sub cleanup
{
        my $self = shift;
}

sub construct_page
{
        my $self = shift;
        my %args = @_;
        my $middle_tpl = $args{ 'middle_tpl' } || '';
        my $error_msg = $args{ 'error_msg' } || '';
        my $success_msg = $args{ 'success_msg' } || '';
        my $restricted_msg = $args{ 'restricted_msg' } || '';

        &ar( CURRENT_USER => $self -> user() );

        if( $error_msg )
        {
                &ar( ERROR_MSG => &gr( $error_msg ) );
        }

        if( $success_msg )
        {
                &ar( SUCCESS_MSG => &gr( $success_msg ) );
        }

        my $header = &tt( 'header' );
        my $footer = &tt( 'footer' );
        my $middle = '';

        if( $restricted_msg )
        {
                &ar( RESTRICTED_MSG => &gr( $restricted_msg ) );
                $middle = &tt( 'restricted' );
        } else
        {
                $middle = &tt( $middle_tpl );
        }

        &ar( HEADER => $header, MIDDLE => $middle, FOOTER => $footer );

        return $self -> ncd( &tt( 'carcass' ) );
}

sub init_user
{
        my $self = shift;
        my $session_key = $self -> get_cookie( 'session_key' ) || '';

        my $session = FModel::Sessions -> get( session_key => $session_key );

        my $rv = 0;
        
        if( $session )
        {
                my $expired = 0;
                if( $self -> now() gt $session -> expires() )
                {
                        $expired = 1;
                }

                if( $expired )
                {
                        $session -> delete( session_key => $session_key );
                } else
                {
                        $session -> expires( $self -> session_expires() );
                        $rv = $self -> user( $session -> user_id() -> name() );
                        $self -> user_id( $session -> user_id() -> id() );
                        $session -> update();
                }
        }

        return $rv;
}

sub log_user_in
{
        my $self = shift;
        my $username = shift;

        my $session_key = $self -> new_session_key();

        my $user = FModel::Users -> get( name => $username );
        FModel::Sessions -> create( user_id => $user -> id(), expires => $self -> session_expires(), session_key => $session_key );

        $self -> set_cookie( '-name' => 'session_key', '-value' => $session_key );

        $self -> user( $username );
        $self -> user_id( $user -> id() );

        return $session_key;
}

sub log_user_out
{
        my $self = shift;
        my $session_key = $self -> get_cookie( 'session_key' );

        FModel::Sessions -> delete( session_key => $session_key );

        $self -> set_cookie( '-name' => 'session_key', '-value' => '' );

        return;
}

sub now
{
        my $self = shift;
        return DateTime -> now( time_zone => 'local' );
}

sub session_expires
{
        my $self = shift;

        return DateTime -> from_epoch( epoch => time() + $self -> session_expires_after(), time_zone => 'local' );
}

sub now_plus_secs
{
        my $self = shift;
        my $plus = shift || 0;

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time + $plus );

        $year += 1900;
        $mon++;

        return sprintf( '%#.4u' . '-' . '%#.2u' . '-' . '%#.2u' . ' ' . '%#.2u' . ':' . '%#.2u' . ':' . '%#.2u',
                         $year,          $mon,           $mday,          $hour,          $min,           $sec );
}

sub readable_date
{
        my $self = shift;
	my $date = shift;

	my ( $part1, $part2 ) = split ( 'T', $date );
	my ( $year, $month, $day ) = split ( '-', $part1 );
	my ( $time, $milliseconds ) = split ( /\./, $part2 );

	return ( $day . '.' . $month . '.' . $year . ' ' . $time );
}

sub is_email_valid
{
        my $self = shift;
        my $email = shift;
        $email = lc( $email );

        return( $email =~ /.+@.+\..+/i );
}

sub is_email_exists
{
        my $self = shift;
        my $email = shift;

        my $exists = 0;

        if( $self -> is_email_valid( $email ) )
        {
                $email = lc( $email );
                $exists = FModel::Users -> count( email => $email );
        }

        return( $exists );
}

sub is_email_exists_except_user
{
        my $self = shift;
        my $email = shift;
        my $username = shift;

        my $exists = 0;

        if( $self -> is_email_valid( $email ) )
        {
                $email = lc( $email );
                $exists = FModel::Users -> count( email => $email, name => { '!=', $username } );
        }

        return( $exists );
}

sub is_username_valid
{
        my $self = shift;
        my $username = shift;
        $username = lc( $username );

        return( $username =~ /^[a-z0-9_-]{3,16}$/ );
}

sub is_user_exists
{
        my $self = shift;
        my $username = shift;

        my $exists = 0;
        if( $self -> is_username_valid( $username ) )
        {
                $username = lc( $username );
                $exists = FModel::Users -> count( name => $username );
        }

        return( $exists );
}

sub new_session_key
{
        my $self = shift;

        my $key = Digest::MD5::md5_base64( rand() );

        return $key;
}

sub set_cookie
{
	my $self = shift;

	my %args = @_;

	{
		$args{ '-domain' } = '192.168.9.24';
		$args{ '-expires' } ||= '+1d';

	}

	my $cookie = CGI::Cookie -> new( %args );

	push( @{ $self -> out_cookies() }, $cookie );
}

sub trim
{
        my $self = shift;
        my $str = shift;

        if( $str )
        {
                $str =~ s/^\s+|\s+$//g;
        }

        return $str;
}

sub is_thread_exists
{
        my $self = shift;
        my $thread_id = shift || '';

        my $exists = 0;

        if( $thread_id )
        {
                $exists = FModel::Threads -> count( id => $thread_id );
        }

        return $exists;
}

sub is_message_belongs_to_current_user
{
        my $self = shift;
        my $message_id = shift;

        my $belongs = 0;

        if( $self -> user_id() )
        {
                my $message = FModel::Messages -> get( id => $message_id );
                $belongs = ( $self -> user_id() eq $message -> user_id() -> id() );
        }

        return $belongs;
}

sub is_thread_belongs_to_current_user
{
        my $self = shift;
        my $thread_id = shift;

        my $belongs = 0;

        if( $self -> user_id() )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                $belongs = ( $self -> user_id() eq $thread -> user_id() -> id() );
        }

        return $belongs;
}


1;
