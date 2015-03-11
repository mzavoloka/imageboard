use strict;
use lib "/var/www/wendy/var/hosts/localhost/lib";

package localhost::testapp;

use TestApp;

sub wendy_handler
{
        return TestApp -> run();
}

1;
