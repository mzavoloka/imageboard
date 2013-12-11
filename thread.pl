package localhost::thread;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumThread -> run();
}

package ForumThread;
use Wendy::Shorts 'ar';

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'create' ] };

has 'title_length' => ( is => 'rw', isa => 'Int', default => 100 );

# Показывает тред
sub app_mode_default
{
        my $self = shift;
        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        
        my $thread = FModel::Threads -> get( id => $thread_id );

        $self -> construct_page( middle_tpl => 'thread' );
}

# Показывает форму создания нового треда
sub app_mode_create
{
        my $self = shift;

        my $title = $self -> arg( 'title' );
        my $content = $self -> arg( 'content' );
        my $create_thread_pre = $self -> arg( 'create_thread' );
        my $error_msg = '';
        my $output;
        if( $title and $content )
        {
                if( $self -> is_title_length_accepatable( $title ) )
                {
                        $self -> create_thread( $title, $content );
                        $output = $self -> ncrd( '/' );
                } else
                {
                        $error_msg = 'TITLE_TOO_LONG';
                }
        } else
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }

        if( $error_msg )
        {
                &ar( TITLE => $title, CONTENT => $content );
                $output = $self -> construct_page( middle_tpl => 'thread_create', error_msg => $error_msg );
        }

        return $output;
}

sub is_title_length_accepatable
{
        my $self = shift;
        my $title = shift;
        
        my $acceptable = 1;

        if( length( $title ) > $self -> title_length() )
        {
                $acceptable = 0;
        }

        return $acceptable;
}

sub create_thread
{
        my $self = shift;

        my $title = shift;
        my $content = shift;

        FModel::Threads -> create( title => $title, content => $content, author => $self -> user(), created => 'now()' );

        return;
}


1;
