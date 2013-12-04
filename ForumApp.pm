package ForumApp;
use strict;

use LittleORM::Db;
use FModel::Users;
use FModel::Sessions;
use FModel::Messages;
use Wendy::Templates::TT 'tt';
use Wendy::Db qw( wdbprepare dbprepare wdbconnect dbconnect );
use Wendy::Db qw( dbconnect );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use String::Random qw( random_regex random_string );
use Digest::MD5 'md5_base64';

use Moose;
extends 'Wendy::App';

has 'user' => ( is => 'rw', isa => 'Str' );
has 'session_key_in_cookie' => ( is => 'rw', isa => 'Str' , default => 'HHUIGKJFHsdfuioewr1234' );

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
        # $self -> { 'DBH' } -> close();
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
        
        my $output = {};
        $output -> { 'data' } = &tt( 'carcass' );
        $output -> { 'nocache' } = 1;

        return $output;
}

sub init_user
{
        my $self = shift;
        my $session_key = $self -> get_cookie( 'session_key' );

        my $session = FModel::Sessions -> get( session_key => $session_key );

        my $rv = 0;

        if( $session )
        {
                my $expired = $self -> compare_dates( $session -> expires(), $self -> now(), 'desc' );

                if( $expired == 1 )
                {
                        $session -> delete( session_key => $session_key );
                } else
                {
                        $session -> expires( $self -> extend_session_to() );
                        $rv = $self -> user( $session -> username() );
                }
                $session -> update();
        }

        return $rv;
}

sub log_user_in
{
        my $self = shift;
        my $username = shift;

        my $session_key = $self -> new_session_key();

        &wdbconnect();
        my $sth = &wdbprepare( "INSERT INTO sessions ( username, expires, session_key ) VALUES ( ?, now() + ( INTERVAL '10 minutes' ), ? )
                RETURNING id" );
        $sth -> bind_param( 1, $username );
        $sth -> bind_param( 2, $session_key );
        $sth -> execute();
        $sth -> fetchrow_array();

        $sth -> finish();

        $self -> set_cookie( '-name' => 'session_key', '-value' => $session_key );

        my $tmp = CGI::Cookie -> new( '-name' => 'session_key', '-value' => $session_key );
        $self -> wobj() -> { 'COOKIES' } -> { 'session_key' } = $tmp;
        $self -> init_user();

        return $session_key;
}

sub log_user_out
{
        my $self = shift;

        &wdbconnect();
        my $sth = &wdbprepare( "DELETE FROM sessions WHERE username = ?" );
        $sth -> bind_param( 1, $self -> init_user() );
        $sth -> execute();

        $self -> set_cookie( '-name' => 'session_key', '-value' => '' );

        return;
}

# deprecated
sub compare_dates
{
        my $self = shift;
        my $first_date_with_timezone = shift;
 	my $second_date_with_timezone = shift;
        my $order = shift || 'asc';
 
        my ( $first_date, $timezone_fd ) = split( /\+/, $first_date_with_timezone );
        my ( $second_date, $timezone_sd ) = split( /\+/, $second_date_with_timezone );

 	my ( $part1_fd, $part2_fd ) = split( ' ', $first_date );
 	my ( $year, $month, $day ) = split( '-', $part1_fd );
        my $milliseconds;
 	( $part2_fd, $milliseconds ) = split( /\./, $part2_fd );
 	my ( $hours, $minutes, $seconds ) = split( ':', $part2_fd );
 	my @first_date_priority_desc = ( $year, $month, $day, $hours, $minutes, $seconds, $milliseconds );
 
 	my ( $part1_sd, $part2_sd ) = split( ' ', $second_date );
 	( $year, $month, $day ) = split( '-', $part1_sd );
 	( $part2_sd, $milliseconds ) = split( /\./, $part2_sd );
 	( $hours, $minutes, $seconds ) = split( ':', $part2_sd );
 	my @second_date_priority_desc = ( $year, $month, $day, $hours, $minutes, $seconds, $milliseconds );
 
        my $rv = 0;

 	for my $index ( 0 .. ( scalar( @first_date_priority_desc ) - 1 ) )
 	{
                if( $order eq 'asc' )
                {
 		        if( $first_date_priority_desc[ $index ] <=> $second_date_priority_desc[ $index ] )
 		        {
 			        return $first_date_priority_desc[ $index ] <=> $second_date_priority_desc[ $index ];
                                last;
 		        }
                } elsif ( $order eq 'desc' )
                {
 		        if( $second_date_priority_desc[ $index ] <=> $first_date_priority_desc[ $index ] )
 		        {
 			        return $second_date_priority_desc[ $index ] <=> $first_date_priority_desc[ $index ];
                                last;
 		        }
                }
 	}

 	return $rv;
}

sub now
{
        my $self = shift;
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
        $year += 1900;
        $mon++;
        my $now = $year . '-' . $mon . '-' . $mday . ' ' . $hour . ':' . $min . ':' . $sec;
        return $now;
}

sub extend_session_to
{
        my $self = shift;
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
        $year += 1900;
        $mon++;
        $min += 30;
        my $extend_to = $year . '-' . $mon . '-' . $mday . ' ' . $hour . ':' . $min . ':' . $sec;

        return;
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
