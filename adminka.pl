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

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> nctd( "THIS IS ADMINKA!!!" );

        return $output;
}
