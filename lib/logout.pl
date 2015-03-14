use Modern::Perl;

package mzavoloka_ru::logout;

sub wendy_handler
{
        return ForumLogout -> run();
}

package ForumLogout;
use Moose;
extends 'ForumApp';

sub app_mode_default
{
        my $self = shift;

        $self -> log_user_out();
        
        return $self -> ncrd( '/' );
}


1;
