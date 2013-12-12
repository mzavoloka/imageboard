use strict;
package TestApp;

use Data::Dumper;
use Carp::Assert;

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'tell_ip' , 'dump_self', 'littleorm', 'sprintf', 'coerce', 'validate_email', 'assert' ] }

sub app_mode_default
{
        my $self = shift;

        return $self -> nctd( 'Hello world!!!' );
}

sub app_mode_tell_ip
{
        my $self = shift;

        my $data = sprintf( "your ip is: %s", $self -> ip() );

        return $self -> nctd( $data );

}

sub app_mode_dump_self
{
        my $self = shift;

        return $self -> nctd( Dumper( $self ) );
}

sub app_mode_littleorm
{
        my $self = shift;

        
        my $user = FModel::Users -> get( id => 80 );
        
        my $data = Dumper( $user );
        $data .= $user -> name();
        $user -> registered( '2014-01-01 00:00:00.000000' );
        $user -> update();
        $data .= "\n";

        $data .= $user -> registered();
        $data .= "\n";

        # my $new_user = FModel::Users -> create( name => 'littleorm', password => 'orm', email => 'little@orm.org', registered => 'now()' );
        # $data .= "\n";
        # $data .= 'New user id: ' . $new_user -> id();

        my $user_to_copy = FModel::Users -> get( name => 'bbb' );
        my $copied_user = $user_to_copy -> copy( _debug => 1 );
        $data .= 'SQL that will execute when calling method copy on user \'bbb\': ' . $copied_user;
        $data .= "\n";

        FModel::Users -> delete ( name => 'ccc' );

        my @sessions = FModel::Sessions -> get();
        $data .= "\n";

        # my $users = FModel::Users -> filter();
        # $data .= Dumper $users;
        # $data .= "\n";

        my $messages = FModel::Users -> f( );
        my @messages_with_users = FModel::Messages -> f( $messages ) -> get_many();
        $data = Dumper( \@messages_with_users );

        return $self -> nctd( $data );
}

sub app_mode_sprintf
{
        my $self = shift;

        my $data = sprintf( '%#.4u' . '-' . '%#.2u' . '-' . '%#.2u' . ' ' . '%#.2u' . ':' . '%#.2u' . ':' . '%#.2u',
                             2013,           9,              3,               0,              8,              13 );

        $data .= "\n";
        $data .= $self -> now();

        return $self -> nctd( $data );
}

{
        package FModel::Test;
        use strict;
        use Moose;
        extends 'LittleORM::GenericID'; 
        use LittleORM::Clause;
        use LittleORM::Filter;
        use DateTime::Format::Strptime;
        
        sub _db_table { 'test' }
        
        # has 'date' => ( is => 'rw',
        #                 metaclass => 'LittleORM::Meta::Attribute',
        #                 isa => 'DateTime',
        #                 # description => { coerce_from => sub { &ts2dt( $_[0] ) },
        #                 #                  coerce_to   => sub { &dt2ts( $_[0] ) } } );
        #                 description => { coerce_from => sub { return &psql_time_to_linux_time( $_[0] ); # &psql_time_to_linux_time( $_[0] )
        #                                                         },
        #                                  coerce_to   => sub { &linux_time_to_psql_time( $_[0] ) } } );

        has 'date' => ( is => 'rw',
                        metaclass => 'LittleORM::Meta::Attribute',
                        isa => 'DateTime',
                        description => { coerce_from => sub { &ts2dt( $_[0] ) },
                                         coerce_to   => sub { &dt2ts( $_[0] ) } } );

        sub ts2dt
        {
                my $ts = shift;
                my $strp = DateTime::Format::Strptime -> new( pattern => '%F%n%T' );
                
                return $strp -> parse_datetime( $ts );
        }
        
        use DateTime::TimeZone;
        use DateTime;
        sub dt2ts
        {
                my $dt = shift;

                my $tz = DateTime::TimeZone -> new( name => 'local' );
                $dt = DateTime -> now();
                my $offset = $tz -> offset_for_datetime( $dt );

                my $strp = DateTime::Format::Strptime -> new( pattern => '%F%n%T' );

                return $strp -> format_datetime( $dt );
        }

        sub epoch2ts
        {
                use DateTime;
                my $epoch = shift;
                my $strp = DateTime::Format::Strptime -> new( pattern => '%s' );
                

                return $strp -> parse_datetime( $epoch );
        }

        sub readable_date
        {
                # my $self = shift;
        	my $date = shift;
        
        	my ( $part1, $part2 ) = split ( 'T', $date );
        	my ( $year, $month, $day ) = split ( '-', $part1 );
        	my ( $time, $milliseconds ) = split ( /\./, $part2 );
        
        	return $day . '.' . $month . '.' . $year . ' ' . $time;
        }
        
        sub psql_time_to_linux_time
        {
                my $psql_time = shift;
                use Time::Local 'timelocal';

        	my ( $part1, $part2 ) = split( ' ', $psql_time );
        	my ( $year, $month, $day ) = split( '-', $part1 );
        	my ( $time, $milliseconds ) = split( /\./, $part2 );
                my ( $hour, $min, $sec ) = split( ':', $time );

                return timelocal( $sec, $min, $hour, $day, $month - 1, $year );
        }

        sub linux_time_to_psql_time
        {
                # my $self = shift;
                my $linux_time = shift || time();
        
                my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( $linux_time );
        
                $year += 1900;
                $mon++;
        
                return sprintf( '%04d' . '-' . '%02d' . '-' . '%02d' . ' ' . '%02d' . ':' . '%02d' . ':' . '%02d',
                                 $year,         $mon,          $mday,         $hour,         $min,          $sec );
        }
}

sub app_mode_coerce
{
        my $self = shift;

        my $output;

        use DateTime;
        $output .= 'DateTime->now(): ' . DateTime -> now();
        $output .= 'Current time is: ' . time();
        $output .= "\n";

        $output .= 'ts2dt():';
        $output .= "\n";
        #$output .= $self -> ts2dt( localtime( time ) );

        $output .= "\n";

        $output .= 'dt2ts():';
        $output .= "\n";
        # $output .= $self -> ts2dt( time );

        $output .= "\n";

        # $output .= $offset;
        # my $row = FModel::Test -> create( date => $dt ); 
        # $output .= '$row -> date( time() )' . $row -> date();
        # $row -> update();
        $output .= "\n";

        my $row = FModel::Test -> get( id => 45 );
        $output .= '$row -> date() : ' . $row -> date();

        $output .= "\n";
        $output .= 'Check Db';
        $output .= "\n";

        # $output .= 'ts2dt( time() ) results in: ' . $self -> ts2dt( localtime( time ) );

        return( $self -> nctd( $output ) );
}

sub linux_time_to_psql_time
{
        my $self = shift;
        my $linux_time = shift || time();

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( $linux_time );

        $year += 1900;
        $mon++;

        return sprintf( '%#.4u' . '-' . '%#.2u' . '-' . '%#.2u' . ' ' . '%#.2u' . ':' . '%#.2u' . ':' . '%#.2u',
                         $year,          $mon,           $mday,          $hour,          $min,           $sec );
}

sub ts2dt
{
        my $self = shift;
        my $ts = shift;

        return DateTime::Format::Strptime -> new( pattern => '%T' ) -> parse_datetime( $ts );
}

sub dt2ts
{
        my $self = shift;
        my $dt = shift;
        
        return DateTime::Format::Strptime -> new( pattern => '%T' ) -> format_datetime( $dt );
}

sub app_mode_validate_email
{
        my $self = shift;
        
        FModel::Users -> create( name => 'hhh', password => 'hhh', email => '*(*&%#', registered => $self -> now() );
        my $output = 'Check Db';
                
        return $self -> nctd( $output );
}

sub app_mode_assert
{
        my $self = shift;

        my $output;

        my $subject = 'testing';
        my $content = 'some text data';
        my $author = 'Not exists!';
        my $thread_id = 'Not a number!';

        assert( $thread_id > 0 );

        FModel::Messages -> create( subject   => $subject,
                                    content   => $content,
                                    author    => $author,
                                    thread_id => $thread_id,
                                    posted    => $self -> now() );

        $output = 'Check Db';

        return $self -> nctd( $output );
}

1;
