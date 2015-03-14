use Modern::Perl;
use lib "/var/www/wendy/var/hosts/mzavoloka_ru/lib";

package mzavoloka_ru::testapp;

use TestApp;

sub wendy_handler
{
        return TestApp -> run();
}

1;
