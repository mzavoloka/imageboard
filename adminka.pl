use strict;

package localhost::adminka;

sub wendy_handler
{
        return ForumAdminka -> run();
}

package ForumAdminka;
use Wendy::Shorts qw( ar );
use Wendy::Templates::TT 'tt';
use Carp::Assert 'assert';
use File::Copy 'cp';
use URI qw( new query_from as_string );
use Data::Dumper 'Dumper';
use ForumConst;

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default' ] };


sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( not $self -> can_use_adminka() )
        {
                $rv = $self -> construct_page( restricted_msg => 'ADMINKA_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> show_adminka();

        return $output;
}

sub show_adminka
{
        my $self = shift;

        my $output = $self -> construct_page( middle_tpl => 'adminka' );

        return $output;
}


1;
