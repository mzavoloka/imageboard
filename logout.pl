package localhost::logout;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumLogout -> run();
}

package ForumLogout;
use strict;

use Moose;
extends 'ForumApp';

sub app_mode_default
{
        my $self = shift;

        $self -> log_user_out();
        
        return $self -> ncrd( '/' );
}
