use v5.20;
# use strict;

package localhost::root;

sub wendy_handler
{
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

        my $error_msg = $self -> arg( 'error_msg' );
        my $success_msg = $self -> arg( 'success_msg' );
        
        my $threads = $self -> get_threads();

        if( scalar ( @$threads ) )
        {
                &ar( DYN_THREADS => $threads );
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
                my $hash = { DYN_THREAD_ID          => $thread -> id(),
                             DYN_TITLE              => $thread -> title(),
                             DYN_CONTENT            => $thread -> content(),
                             DYN_VOTE               => $thread -> vote(),
                             DYN_VOTE_QUESTION      => $thread -> vote_question(),
                             DYN_VOTING_OPTIONS     => $self -> get_voting_options_for_replace( $thread -> id() ),
                             DYN_PINNED_IMAGE       => $thread -> pinned_image_url(),
                             DYN_AUTHOR             => $thread -> author() -> name(),
                             DYN_AUTHOR_VOTED_FOR   => $thread -> option_title_that_author_voted_for(),
                             DYN_CREATED            => Funcs::readable_date( $thread -> created() ),
                             DYN_MODIFIED_DATE      => Funcs::readable_date( $thread -> modified() ),
                             DYN_MESSAGES           => $self -> get_thread_messages( $thread -> id() ),
                             DYN_CAN_VOTE           => $self -> can_vote(),
                             DYN_CAN_DELETE         => $self -> can_do_action_with_thread( 'delete', $thread -> id() ),
                             DYN_CAN_EDIT           => $self -> can_do_action_with_thread( 'edit', $thread -> id() ),
                             DYN_AUTHOR_AVATAR      => $thread -> author() -> avatar_url(),
                             DYN_AUTHOR_PERMISSIONS => $thread -> author() -> get_special_permission_title() };

                push( @$threads, $hash );
        }

        return $threads;
}

sub get_thread_messages
{
        my ( $self, $thread_id ) = @_;

        my @messages_sorted = FModel::Messages -> get_many( thread => $thread_id, _sortby => 'posted' );
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
                        my $msg_hash = { DYN_MESSAGE_ID         => $message -> id(),
                                         DYN_POSTED             => Funcs::readable_date( $message -> posted() ),
                                         DYN_SUBJECT            => $message -> subject(),
                                         DYN_CONTENT            => $message -> content(),
                                         DYN_PINNED_IMAGE       => $message -> pinned_image_url(),
                                         DYN_AUTHOR             => $message -> author() -> name(),
                                         DYN_AUTHOR_VOTED_FOR   => $message -> option_title_that_author_voted_for(),
                                         DYN_MODIFIED_DATE      => Funcs::readable_date( $message -> modified() ),
                                         DYN_CAN_DELETE         => $self -> can_do_action_with_message( 'delete', $message -> id() ),
                                         DYN_CAN_EDIT           => $self -> can_do_action_with_message( 'edit', $message -> id() ),
                                         DYN_AUTHOR_AVATAR      => $message -> author() -> avatar_url(),
                                         DYN_AUTHOR_PERMISSIONS => $message -> author() -> get_special_permission_title() };

                        push( @$messages, $msg_hash );
                }
        }

        return $messages;
}


1;
