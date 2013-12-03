use strict;

package ForumApp;

use Wendy::Templates::TT 'tt';
use Wendy::Db ( 'wdbprepare', 'dbprepare', 'wdbconnect' );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use String::Random qw(random_regex random_string);

use Moose;
extends 'Wendy::App';

has 'user' => ( is => 'rw', isa => 'Str' );
has 'session_key_in_cookie' => ( is => 'rw', isa => 'Str' , default => 'HHUIGKJFHsdfuioewr1234' );

sub init
{
        my $self = shift;

        my $rv = '';
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

        my $sth = &dbprepare( "SELECT username, expires, now() FROM sessions WHERE session_key = ?" );
        $sth -> bind_param( 1, $session_key );
        $sth -> execute();
        my ( $username, $expires, $now ) = $sth -> fetchrow_array();

        my $rv = 0;
        if( $username )
        {
                my $expired = $self -> compare_dates( $expires, $now, 'desc' );

                &wdbconnect();
                if( $expired == 1 )
                {
                        $sth = &wdbprepare( "DELETE FROM sessions WHERE session_key = ?" );
                        $sth -> bind_param( 1, $session_key );
                        $sth -> execute();
                } else
                {
                        $sth = &dbprepare( "UPDATE sessions SET expires = now() + ( INTERVAL '10 minutes') WHERE session_key = ?" );
                        $sth -> bind_param( 1, $session_key );
                        $sth -> execute();
                        $rv = $self -> user( $username );
                }
        }

        $sth -> finish();

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
        my $sth = &dbprepare( " SELECT email FROM users WHERE email = ? " );
        $sth -> bind_param( 1, $email );
        my ( $email_exists ) = $sth -> fetchrow_array();
        return ( $email_exists );
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
        my $string = '';

        for my $i ( 1 .. 32 )
        {
                my $random_bool = int( rand( 2 ) % 2 );
                if( $random_bool )
                {
                        $string .= random_regex('\d');
                } else
                {
                        $string .= random_string('.');
                }
        }

        return $string;
}

1;
