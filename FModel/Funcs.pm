use strict;

package FModel::Funcs;

use FModel::Users;
use DateTime::Format::Strptime;
use DateTime::TimeZone;
use DateTime;

sub ts2dt
{
        my $ts = shift;

        my $strp = DateTime::Format::Strptime -> new( pattern => '%F %T' );
        
        return $strp -> parse_datetime( $ts );
}

sub dt2ts
{
        my $dt = shift;

        my $rv;

        if( $dt )
        {
                my $strp = DateTime::Format::Strptime -> new( pattern => '%F %T' );
                $rv = $strp -> format_datetime( $dt );
        }

        return $rv;
}

sub validate_email
{
        my $email = shift;
        
        my $lower_email = lc( $email );

        my $rv;

        if( $lower_email =~ /.+@.+\..+/i )
        {
                $rv = $email;
        }

        return $rv;
}

sub now
{
        return DateTime -> now( time_zone => 'local' );
}


1;
