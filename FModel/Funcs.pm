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

        my $strp = DateTime::Format::Strptime -> new( pattern => '%F %T' );

        return $strp -> format_datetime( $dt );
}

sub validate_email
{
        my $email = shift;
        $email = lc( $email );

        my $rv;

        if( $email =~ /.+@.+\..+/i )
        {
                $rv = $email;
        } else
        {
                $rv = {}; # костыль
        }

        return $rv;
}


1;
