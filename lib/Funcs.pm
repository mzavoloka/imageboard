use Modern::Perl;

package Funcs;

use FModel::Users;
use DateTime::Format::Strptime;
use DateTime::TimeZone;
use DateTime;

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

sub is_datetime_valid
{
        my $date = shift;

        my $valid = 1;

        if( $date ne '' )
        {
                my $strp = DateTime::Format::Strptime -> new( pattern => '%Y-%m-%d %T' );

                if( not $strp -> parse_datetime( $date ) )
                {
                        $valid = 0;
                }
        }

        return $valid;
}

sub is_natural_number
{
        my $something = shift;

        my $is_natural = 0;

        if( $something =~ /^(\d+)$/ and $something != 0 )
        {
                $is_natural = 1;
        }

        return $is_natural;
}

sub is_form_field_value_contains_natural_number_or_nothing
{
        my $form_field_value = shift;

        my $trimmed_val = &trim( $form_field_value );

        my $contains = '';

        if( $trimmed_val eq '' )
        {
                $contains = 1;
        }
        else
        {
                $contains = &is_natural_number( $trimmed_val );
        }

        return $contains;
}

sub is_id_field_value_valid
{
        my $id_field_value = shift;

        return &is_form_field_value_contains_natural_number_or_nothing( $id_field_value );
}

sub is_date_valid_format
{
        my $date = shift;

        return( $date =~ /^\d\d\d\d-\d\d-\d\d$/ );
}

sub is_date_valid
{
        my $date = shift;
        
        my $valid = 1;

        my $strp = DateTime::Format::Strptime -> new( pattern => '%Y-%m-%d' );

        if( $date and ( ( not &is_date_valid_format( $date ) ) or ( not $strp -> parse_datetime( $date ) ) ) )
        {
                $valid = 0;
        }

        return $valid;
}


1;
