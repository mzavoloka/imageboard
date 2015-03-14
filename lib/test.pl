package localhost::test;
use strict;

use Wendy::Templates::TT;
use Wendy::Templates;
use Data::Dumper;

sub wendy_handler
{
        my $WOBJ = shift;

        my @dates = ( '2013-11-25 11:14:18.758259', '2013-11-27 15:41:43.884595', '2013-11-25 17:10:51.997123', '2013-11-27 15:52:45.625414' );

        return { data => join( ", ", sort @dates ) };
}

1;
