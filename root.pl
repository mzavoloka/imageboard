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

        my $error_msg = $self -> arg( 'error_msg' ) || '';
        my $success_msg = $self -> arg( 'success_msg' ) || '';
        
        my $threads = $self -> get_threads();

        if( scalar ( @$threads ) )
        {
                &ar( THREADS => $threads );
        }

        my $output = $self -> construct_page( middle_tpl => 'mainpage', error_msg => $error_msg, success_msg => $success_msg );

  	return $output;
}

sub get_threads
{
        my $self = shift;

        my @threads_sorted = FModel::Threads -> get_many( _sortby => { updated => 'DESC' } );
        my $threads = [];

        for my $thread ( @threads_sorted )
        {
                my $hash = { THREAD_ID     => $thread -> id(),
                             TITLE         => $thread -> title(),
                             CONTENT       => $thread -> content(),
                             AUTHOR        => $thread -> user_id() -> name(),
                             CREATED       => $self -> readable_date( $thread -> created() ),
                             MESSAGES      => $self -> get_thread_messages( $thread -> id() ),
                             CAN_DELETE    => $self -> can_do_action_with_thread( 'delete', $thread -> id() ),
                             CAN_EDIT      => $self -> can_do_action_with_thread( 'edit', $thread -> id() ),
                             AUTHOR_AVATAR => $self -> get_user_avatar_src( $thread -> user_id() -> id() ),
                             AUTHOR_PERMISSIONS => $self -> get_user_special_permissions ( $thread -> user_id() -> id() ) };

                if( $thread -> modified() )
                {
                        $hash -> { 'MODIFIED' } = 1;
                        $hash -> { 'MODIFIED_DATE' } = $self -> readable_date( $thread -> modified_date() );
                }

                push( $threads, $hash );
        }

        return $threads;
}

sub get_thread_messages
{
        my $self = shift;
        my $thread_id = shift;

        my @messages_sorted = FModel::Messages -> get_many( thread_id => $thread_id, _sortby => 'posted' );
        my $messages = [];

        if( @messages_sorted )
        {
                my $index = $#messages_sorted - 2;

                if( $index < 0 )
                {
                        $index = 0;
                }

                for( $index; $index <= $#messages_sorted; $index++ )
                {
                        my $message = $messages_sorted[ $index ];
                        my $msg_hash = { MESSAGE_ID => $message -> id(),
                                         POSTED     => $self -> readable_date( $message -> posted() ),
                                         SUBJECT    => $message -> subject(),
                                         CONTENT    => $message -> content(),
                                         AUTHOR     => $message -> user_id() -> name(),
                                         CAN_DELETE => $self -> can_do_action_with_message( 'delete', $message -> id() ),
                                         CAN_EDIT   => $self -> can_do_action_with_message( 'edit', $message -> id() ),
                                         AUTHOR_AVATAR => $self -> get_user_avatar_src( $message -> user_id() -> id() ),
                                         AUTHOR_PERMISSIONS => $self -> get_user_special_permissions ( $message -> user_id() -> id() ) };

                        if( $message -> modified() )
                        {
                                $msg_hash -> { 'MODIFIED' } = 1;
                                $msg_hash -> { 'MODIFIED_DATE' } = $self -> readable_date( $message -> modified_date() );
                        }

                        push( $messages, $msg_hash );
                }
        }

        return $messages;
}

1;
