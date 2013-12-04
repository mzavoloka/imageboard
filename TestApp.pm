package TestApp;
use strict;

use Data::Dumper;
use Wendy::Db qw( dbconnect );

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'tell_ip' , 'dump_self', 'littleorm' ] }

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


1;
