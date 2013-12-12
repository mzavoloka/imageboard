use strict;

package localhost::thread;

sub wendy_handler
{
        my $self = shift;
        return ForumThread -> run();
}

package ForumThread;
use Wendy::Shorts qw( ar gr lm );
use Carp::Assert 'assert';

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'create', 'reply' ] };

sub always
{
        my $self = shift;

        my $rv;

        unless( $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'PROFILE_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;
        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        
        assert( $thread_id > 0 );

        my $output;

        &ar( THREAD_ID => $thread_id ); 

        if( $self -> is_thread_exists( $thread_id ) )
        {
                $self -> add_thread_data( $thread_id );
                $output = $self -> construct_page( middle_tpl => 'thread' );
        } else
        {
                $output = $self -> construct_page( middle_tpl => 'thread', error_msg => 'NO_SUCH_THREAD' );
        }

        return $output;
}

sub app_mode_create
{
        my $self = shift;

        my $title = $self -> arg( 'title' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $create_button_pressed = $self -> arg( 'create_button' ) || '';

        my $error_msg = '';
        my $output;

        if( $create_button_pressed )
        {
                if( my $error_msg = $self -> can_create_thread( $title, $content ) )
                {
                        &ar( TITLE => $title, CONTENT => $content );
                        $output = $self -> construct_page( middle_tpl => 'thread_create', error_msg => $error_msg );
                } else
                {
                        my $new_thread_id = $self -> create_thread( $title, $content );
                        $output = $self -> ncrd( '/thread/?thread_id=' . $new_thread_id );
                }
        } else
        {
                $output = $self -> construct_page( middle_tpl => 'thread_create' );
        }

        return $output;
}

sub app_mode_reply
{
        my $self = shift;
        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $subject = $self -> arg( 'subject' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $reply_button_pressed = $self -> arg( 'reply_button' ) || '';

        assert( $thread_id > 0 );

        my $output;

        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                &ar( THREAD_ID => $thread_id, THREAD_TITLE => $thread -> title() );
        }

        if( $reply_button_pressed )
        {
                if( my $error_msg = $self -> can_reply( $subject, $content ) )
                {
                        &ar( SUBJECT => $subject, CONTENT => $content );
                        $output = $self -> construct_page( middle_tpl => 'thread_reply', error_msg => $error_msg );
                } else
                {
                        $self -> reply( $thread_id, $subject, $content );
                        $output = $self -> ncrd( '/thread/?thread_id=' . $thread_id );
                }
        } else
        {
                $output = $self -> construct_page( middle_tpl => 'thread_reply' );
        }

        return $output;
}

sub can_reply
{
        my $self = shift;
        my $subject = shift;
        my $content = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

        my $message_subject_length_acceptable = $self -> is_message_subject_length_acceptable( $subject );
        
        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $fields_are_filled and ( not $message_subject_length_acceptable ) ) 
        {
                $error_msg = 'MESSAGE_SUBJECT_TOO_LONG';
        }

        return $error_msg;
}

sub is_message_subject_length_acceptable
{
        my $self = shift;
        my $subject = shift;
        
        my $acceptable = 1;

        if( length( $subject ) > &gr( 'MESSAGE_SUBJECT_MAX_LENGTH' ) )
        {
                $acceptable = 0;
        }

        return $acceptable;
}

sub reply
{
        my $self = shift;
        my $thread_id = shift;
        my $subject = shift;
        my $content = shift;
        
        FModel::Messages -> create( subject   => $subject,
                                    content   => $content,
                                    author    => $self -> user(),
                                    thread_id => $thread_id,
                                    posted    => $self -> now() );

        return;
}

sub add_thread_data
{
        my $self = shift;
        my $thread_id = shift;

        my $thread = FModel::Threads -> get( id => $thread_id );

        &ar( TITLE => $thread -> title(), CONTENT => $thread -> content(),
             CREATED => $self -> readable_date( $thread -> created() ), AUTHOR => $thread -> author() -> name() );

        $self -> add_messages( $thread_id );

        return;
}

sub add_messages
{
        my $self = shift;
        my $thread_id = shift;

        my @messages_sorted = sort { $a -> posted() cmp $b -> posted() } FModel::Messages -> get_many( thread_id => $thread_id);
        my $messages = [];
         
        for my $message ( @messages_sorted ) 
        {
                my $msg_hash = { POSTED  => $self -> readable_date( $message -> posted() ),
                                 SUBJECT => $message -> subject(),
                                 CONTENT => $message -> content(),
                                 AUTHOR  => $message -> author() -> name() };
                push( $messages, $msg_hash );
        }

        if( scalar( @$messages ) )
        {
                &ar( MESSAGES => $messages );
        }

        return $messages;
}

sub can_create_thread
{
        my $self = shift;
        my $title = shift;
        my $content = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) );

        my $title_length_acceptable = $self -> is_thread_title_length_acceptable( $title );
        
        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $fields_are_filled and ( not $title_length_acceptable ) ) 
        {
                $error_msg = 'THREAD_TITLE_TOO_LONG';
        }

        return $error_msg;
}

sub is_thread_title_length_acceptable
{
        my $self = shift;
        my $title = shift;
        
        my $acceptable = 1;

        if( length( $title ) > &gr( 'THREAD_TITLE_MAX_LENGTH' ) )
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

        my $new_thread = FModel::Threads -> create( title => $title, content => $content, author => $self -> user(), created => $self -> now() );

        return $new_thread -> id();
}


1;
