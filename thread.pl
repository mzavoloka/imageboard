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

sub _run_modes { [ 'default', 'create', 'reply', 'edit' ] };

sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( defined $self -> arg( 'mode' ) and ( not $self -> user() ) )
        {
                $rv = $self -> construct_page( restricted_msg => 'THREAD_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;
        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        
        my $output;

        &ar( THREAD_ID => $thread_id ); 

        if( my $error_msg = $self -> can_show_thread( $thread_id ) )
        {
                $output = $self -> construct_page( middle_tpl => 'thread', error_msg => $error_msg );
        } else
        {
                $self -> add_thread_data( $thread_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'thread' );
        }

        return $output;
}

sub can_show_thread
{
        my $self = shift;
        my $thread_id = shift;

        my $error_msg = $self -> check_if_proper_thread_id_provided( $thread_id );

        return $error_msg;
}

sub app_mode_create
{
        my $self = shift;

        my $title = $self -> arg( 'title' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $create_button_pressed = $self -> arg( 'create_button' ) || '';

        my $output;

        if( not $create_button_pressed )
        {
                $output = $self -> construct_page( middle_tpl => 'thread_create' );
        }
        elsif( $create_button_pressed and ( my $error_msg = $self -> can_create( $title, $content ) ) )
        {
                &ar( TITLE => $title, CONTENT => $content );
                $output = $self -> construct_page( middle_tpl => 'thread_create', error_msg => $error_msg );
        }
        elsif( $create_button_pressed and ( not $error_msg ) )
        {
                my $user = FModel::Users -> get( name => $self -> user() );
                my $new_thread_id = $self -> create( $title, $content );
                $output = $self -> ncrd( '/thread/?thread_id=' . $new_thread_id );
        }

        return $output;
}

sub app_mode_edit
{
        my $self = shift;

        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $title     = $self -> arg( 'title' ) || '';
        my $content   = $self -> arg( 'content' ) || '';
        my $edit_button_pressed = $self -> arg( 'edit_button' ) || '';

        my $output;

        if( not $edit_button_pressed ) 
        {
                $self -> add_thread_data( $thread_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'thread_edit', error_msg => $self -> check_if_proper_thread_id_provided( $thread_id ) );
        }
        elsif( $edit_button_pressed and ( my $error_msg = $self -> can_edit( $thread_id, $title, $content ) ) )
        {
                $self -> add_thread_data( $thread_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'thread_edit', error_msg => $error_msg );
        }
        elsif( $edit_button_pressed and ( not $error_msg ) )
        {
                $self -> edit( $thread_id, $title, $content );
                $output = $self -> ncrd( '/thread/?thread_id=' . $thread_id );
        }

        return $output;
}

sub can_edit
{
        my $self = shift;
        my $thread_id = shift;
        my $title = shift;
        my $content = shift;

        my $error_msg = '';
        
        my $thread_id_error = $self -> check_if_proper_thread_id_provided( $thread_id );

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) );

        if( $thread_id_error )
        {
                $error_msg = $thread_id_error;
        }
        if( ( not $thread_id_error ) and ( not $fields_are_filled ) )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( ( not $thread_id_error ) and $fields_are_filled and ( not $self -> is_thread_title_length_acceptable( $title ) ) ) 
        {
                $error_msg = 'THREAD_TITLE_TOO_LONG';
        }

        return $error_msg;
}

sub edit
{
        my $self = shift;
        my $thread_id = shift;
        my $title = shift;
        my $content = shift;

        my $user = FModel::Users -> get( name => $self -> user() );

        my $thread = FModel::Threads -> get( id => $thread_id );

        $thread -> title( $title );
        $thread -> content( $content );

        my $now = $self -> now();

        $thread -> modified( $now );
        $thread -> updated( $now );

        $thread -> update();

        return;
}

sub app_mode_reply
{
        my $self = shift;
        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $subject = $self -> arg( 'subject' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $reply_button_pressed = $self -> arg( 'reply_button' ) || '';

        my $output;

        my $thread_id_error = $self -> check_if_proper_thread_id_provided( $thread_id );

        if( $thread_id_error )
        {
                $output = $self -> construct_page( middle_tpl => 'thread_reply', error_msg => $thread_id_error );
        }
        elsif( ( not $thread_id_error ) and $reply_button_pressed )
        {

                if( my $error_msg = $self -> can_reply( $subject, $content ) )
                {
                        $self -> add_thread_data( $thread_id );
                        &ar( SUBJECT => $subject, CONTENT => $content );
                        $output = $self -> construct_page( middle_tpl => 'thread_reply', error_msg => $error_msg );
                } else
                {
                        $self -> reply( $thread_id, $subject, $content );
                        $output = $self -> ncrd( '/thread/?thread_id=' . $thread_id );
                }
        }
        elsif( ( not $thread_id_error ) and ( not $reply_button_pressed ) )
        {
                $self -> add_thread_data( $thread_id );
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

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $fields_are_filled and ( not $self -> is_message_subject_length_acceptable( $subject ) ) ) 
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
        
        my $user = FModel::Users -> get( name => $self -> user() );

        FModel::Messages -> create( subject   => $subject,
                                    content   => $content,
                                    user_id   => $user -> id(),
                                    thread_id => $thread_id,
                                    posted    => $self -> now() );

        my $thread = FModel::Threads -> get( id => $thread_id );
        $thread -> updated( $self -> now() );
        $thread -> update();

        return;
}

sub add_thread_data
{
        my $self = shift;
        my $thread_id = shift;
        my $full = shift;

        if( not my $error = $self -> check_if_proper_thread_id_provided( $thread_id ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                &ar( THREAD_ID => $thread_id, TITLE => $thread -> title() );

                if( $full )
                {
                        &ar( CONTENT => $thread -> content(),
                             CREATED => $self -> readable_date( $thread -> created() ),
                             AUTHOR  => $thread -> user_id() -> name() );
                }

                $self -> add_messages( $thread_id );
        } else
        {
                &ar( DONT_SHOW_THREAD_DATA => 1 );
        }

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
                my $msg_hash = { MESSAGE_ID => $message -> id(),
                                 POSTED     => $self -> readable_date( $message -> posted() ),
                                 SUBJECT    => $message -> subject(),
                                 CONTENT    => $message -> content(),
                                 AUTHOR     => $message -> user_id() -> name() };
                push( $messages, $msg_hash );
        }

        if( scalar( @$messages ) )
        {
                &ar( MESSAGES => $messages );
        }

        return $messages;
}

sub can_create
{
        my $self = shift;
        my $title = shift;
        my $content = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) );

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $fields_are_filled and ( not $self -> is_thread_title_length_acceptable( $title ) ) ) 
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

sub create
{
        my $self = shift;
        my $title = shift;
        my $content = shift;

        my $user = FModel::Users -> get( name => $self -> user() );

        my $new_thread = FModel::Threads -> create( title => $title, content => $content, user_id => $user -> id(), created => $self -> now(), updated => $self -> now() );

        return $new_thread -> id();
}

sub check_if_proper_thread_id_provided
{
        my $self = shift;
        my $thread_id = shift || '';

        my $error = '';

        if( not $thread_id )
        {
                $error = 'NO_THREAD_ID';
        }
        elsif( not $self -> is_thread_exists( $thread_id ) )
        {
                $error = 'NO_SUCH_THREAD';
        }

        return $error;
}

1;
