use strict;

package TestApp;
use Moose;
extends 'Wendy::App';

sub _run_modes { [ 'default', 'tell_ip' , 'dump_self' ] }

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

        use Data::Dumper;
        return $self -> nctd( Dumper( $self -> arg( 'mode' ) ) );
}

1;
