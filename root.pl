use strict;

package localhost::root;

sub wendy_handler()
{
        my $self = shift;
        return ForumMainpage -> run();
}

package ForumMainpage;
use Moose;
extends 'ForumApp';

use Data::Dumper 'Dumper';
use Wendy::Shorts 'ar';

sub _run_modes { [ 'default' ] };

sub app_mode_default
{
	my $self = shift;
        
        my $threads = $self -> get_threads();

        if( scalar ( @$threads ) )
        {
                &ar( THREADS => $threads );
        }

        my $output = $self -> construct_page( middle_tpl => 'mainpage' );

  	return $output;
}

sub get_threads
{
        my $self = shift;

        my @threads_sorted = FModel::Threads -> get_many( _sortby => { created => 'DESC' } );
        my $threads = [];

        for my $thread ( @threads_sorted )
        {
                my $hash = { THREAD_ID => $thread -> id(),
                             TITLE     => $thread -> title(),
                             CONTENT   => $thread -> content(),
                             AUTHOR    => $thread -> author() -> name(),
                             CREATED   => $self -> readable_date( $thread -> created() ),
                             MESSAGES  => $self -> get_thread_messages( $thread -> id() ) };
                push( $threads, $hash );
        }

        return $threads;
}

sub get_thread_messages
{
        my $self = shift;
        my $thread_id = shift;

        my @messages_sorted = sort { $b -> posted() cmp $a -> posted() } FModel::Messages -> get_many( thread_id => $thread_id );
        my $messages = [];
         
        for my $message ( @messages_sorted ) 
        {
                my $msg_hash = { POSTED  => $self -> readable_date( $message -> posted() ),
                                 SUBJECT => $message -> subject(),
                                 CONTENT => $message -> content(),
                                 AUTHOR  => $message -> author() -> name() };
                push( $messages, $msg_hash );
        }

        return $messages;
}


1;
