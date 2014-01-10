use strict;

package Funcs;

use FModel::Users;
use DateTime::Format::Strptime;
use DateTime::TimeZone;
use DateTime;
use Carp 'croak';

sub trim
{
        my $str = shift;

        if( $str )
        {
                $str =~ s/^\s+|\s+$//g;
        }

        return $str;
}

sub now
{
        return DateTime -> now( time_zone => 'local' );
}

sub max_of
{
        my @numbers = @_;

        my $max = shift( @numbers );

        for my $num ( @numbers )
        {
                if( $num > $max )
                {
                        $max = $num;
                }
        }

        return $max;
}

sub min_of
{
        my @numbers = @_;

        my $min = shift( @numbers );

        for my $num ( @numbers )
        {
                if( $num < $min )
                {
                        $min = $num;
                }
        }

        return $min;
}

sub readable_date
{
	my $date = shift;

        my $readable = '';

        if( $date )
        {
	        my ( $part1, $part2 ) = split ( 'T', $date );
	        my ( $year, $month, $day ) = split ( '-', $part1 );
	        my ( $time, $milliseconds ) = split ( /\./, $part2 );

                $readable = $day . '.' . $month . '.' . $year . ' ' . $time;

        }

	return $readable;
}


1;
