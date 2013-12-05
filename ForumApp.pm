package ForumApp;
use strict;

use LittleORM::Db 'init';
use FModel::Users;
use FModel::Sessions;
use FModel::Messages;
use Wendy::Templates::TT 'tt';
use Wendy::Db qw( dbconnect );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use String::Random qw( random_regex random_string );
use Digest::MD5 'md5_base64';

use Moose;
extends 'Wendy::App';

has 'user' => ( is => 'rw', isa => 'Str' );
has 'session_key_in_cookie' => ( is => 'rw', isa => 'Str', default => 'HHUIGKJFHsdfuioewr1234' );
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
        my $session_key = $self -> get_cookie( 'session_key' );

        my $session = FModel::Sessions -> get( session_key => $session_key );

        my $rv = 0;

        if( $session )
        {
                my $expired = 0;
                if( ( $session -> expires() cmp $self -> now() ) == -1 )
                {
                        $expired = 1;
                }

                if( $expired )
                {
                        $session -> delete( session_key => $session_key );
                } else
                {
                        $session -> expires( $self -> session_expires() );
                        $rv = $self -> user( $session -> username() );
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

        FModel::Sessions -> create( username => $username, expires => $self -> session_expires(), session_key => $session_key );

        $self -> set_cookie( '-name' => 'session_key', '-value' => $session_key );

        my $tmp = CGI::Cookie -> new( '-name' => 'session_key', '-value' => $session_key );
        $self -> wobj() -> { 'COOKIES' } -> { 'session_key' } = $tmp;

        $self -> init_user();

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
        return $self -> now_plus_secs( 0 );
}

sub session_expires
{
        my $self = shift;
        return $self -> now_plus_secs( $self -> session_expires_after() );
}

sub now_plus_secs
{
        my $self = shift;
        my $plus = shift || 0;

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time + $plus );

        $year += 1900;
        $mon++;

        if( $mon < 10 )
        {
                $mon = '0'.$mon;
        }

        if( $mday < 10 )
        {
                $mday = '0'.$mday;
        }

        my $rv = $year . '-' . $mon . '-' . $mday . ' ' . $hour . ':' . $min . ':' . $sec;

        return $rv;
}

sub readable_date
{
        my $self = shift;
	my $date = shift;

	my ( $part1, $part2 ) = split ( ' ', $date );
	my ( $year, $month, $day ) = split ( '-', $part1 );
	my ( $time, $milliseconds ) = split ( /\./, $part2 );

	return ( $day . '.' . $month . '.' . $year . ' ' . $time );
}

sub is_email_valid
{
        my $self = shift;
        my $email = shift;
        return ( $email =~ /.+@.+\..+/i );
}

sub is_email_exists
{
        my $self = shift;
        my $email = shift;

        my $exists = FModel::Users -> count( email => $email );

        return ( $exists );
}

sub is_username_valid
{
        my $self = shift;
        my $username = shift;
        return ( $username =~ /^[a-z0-9_-]{3,16}$/ );
}

sub new_session_key
{
        my $self = shift;

        my $key = Digest::MD5::md5_base64( rand() );

        return $key;
}


1;
