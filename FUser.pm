use strict;

package localhost::FUser;

use Moose;

{
        my $user = undef;

        sub init_user
        {
                if ( not $WOBJ -> { "CUR_USER" } )
                {
                        my $cookies = $WOBJ -> { "REQREC" } -> headers_in() -> get( "Cookie" );
                        for my $param ( split( ";", $cookies ) )
                        {
                                my ( $name, $val ) = split( "=", $param );
                                if ( $name eq "user" and $val )
                                {
                                        $WOBJ -> { "CUR_USER" } = $val;
                                        last;
                                }
                        }
                }

                return $user;
        }
}
