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

sub _run_modes { [ 'default', 'create', 'reply', 'edit', 'edit_message', 'delete_message' ] };

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
                $self -> add_thread_data( $thread_id, 'full', 'with_messages' );
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

        if( not $self -> is_thread_belongs_to_current_user( $thread_id ) )
        {
                &ar( DONT_SHOW_THREAD_DATA => 1 );
                $self -> add_thread_data( $thread_id );
                $output = $self -> construct_page( middle_tpl => 'thread_edit', error_msg => 'CAN_ONLY_EDIT_THREADS_OF_YOUR_OWN' );
        }
        elsif( $edit_button_pressed and ( not my $error_msg = $self -> can_edit( $thread_id, $title, $content, $edit_button_pressed ) ) )
        {
                $self -> edit( $thread_id, $title, $content );
                $output = $self -> ncrd( '/thread/?thread_id=' . $thread_id );
        }
        else
        {
                $self -> add_thread_data( $thread_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'thread_edit', error_msg => $error_msg );
        }
        
        return $output;
}

sub can_edit
{
        my $self = shift;
        my $thread_id = shift;
        my $title = shift;
        my $content = shift;
        my $edit_button_pressed = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) );
        
        my $thread_id_error = $self -> check_if_proper_thread_id_provided( $thread_id );

        if( $thread_id_error )
        {
                $error_msg = $thread_id_error;
        }
        elsif( ( not $thread_id_error ) and ( not $self -> is_thread_belongs_to_current_user( $thread_id ) ) )
        {
                $error_msg = 'CAN_ONLY_EDIT_THREADS_OF_YOUR_OWN';
                &ar( DONT_SHOW_THREAD_DATA => 1 );
        }
        elsif( ( not $thread_id_error ) and $self -> is_thread_belongs_to_current_user( $thread_id ) and
                 $edit_button_pressed and ( not $fields_are_filled ) )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( ( not $thread_id_error ) and $self -> is_thread_belongs_to_current_user( $thread_id ) and
                 $edit_button_pressed and $fields_are_filled and ( not $self -> is_thread_title_length_acceptable( $title ) ) ) 
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

        my $thread = FModel::Threads -> get( id => $thread_id );

        $thread -> title( $title );
        $thread -> content( $content );

        my $now = $self -> now();

        $thread -> modified( 1 );
        $thread -> modified_date( $now );
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

sub app_mode_edit_message
{
        my $self = shift;

        my $message_id = $self -> arg( 'message_id' );
        my $subject    = $self -> arg( 'subject' ) || '';
        my $content    = $self -> arg( 'content' ) || '';
        my $edit_button_pressed = $self -> arg( 'edit_button' ) || '';

        my $output;

        if( my $error_msg = $self -> can_edit_message( $message_id, $subject, $content, $edit_button_pressed ) )
        {
                $self -> add_message_data( $message_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );
        }
        elsif( ( not $error_msg ) and ( not $edit_button_pressed ) )
        {
                $self -> add_message_data( $message_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );
        }
        elsif( ( not $error_msg ) and $edit_button_pressed )
        {
                $self -> edit_message( $message_id, $subject, $content );
                my $message = FModel::Messages -> get( id => $message_id );
                $output = $self -> ncrd( '/thread/?thread_id=' . $message -> thread_id() -> id() );
        }

        return $output;
}

sub can_edit_message
{
        my $self = shift;
        my $message_id = shift;
        my $subject = shift;
        my $content = shift;
        my $edit_button_pressed = shift;

        my $error_msg = '';
        
        #my $message_id_error = $self -> check_if_proper_message_id_provided( $message_id );

        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

        #if( $message_id_error )
        #{
        #        $error_msg = $message_id_error;
        #}

        my $can_edit = $self -> can_do_action_with_message( 'edit', $message_id );

        if( not $can_edit )
        {
                $error_msg = 'CANNOT_EDIT_MESSAGE';
                &ar( DONT_SHOW_MESSAGE_DATA => 1 );
        }
        elsif( $can_edit and $edit_button_pressed and ( not $fields_are_filled ) )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $can_edit and $edit_button_pressed and $fields_are_filled and ( not $self -> is_message_subject_length_acceptable( $subject ) ) )
        {
                $error_msg = 'MESSAGE_SUBJECT_TOO_LONG';
        }

        return $error_msg;
}

sub add_message_data
{
        my $self = shift;
        my $message_id = shift;
        my $full = shift;
        
        &ar( MESSAGE_ID => $message_id );
        if( not my $error = $self -> check_if_proper_message_id_provided( $message_id ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                &ar( SUBJECT => $message -> subject() );

                if( $full )
                {
                        &ar( CONTENT => $message -> content(),
                             POSTED => $self -> readable_date( $message -> posted() ),
                             AUTHOR  => $message -> user_id() -> name(),
                             SHOW_MANAGE_LINKS => $self -> is_message_belongs_to_current_user( $message_id ) );

                        if( $message -> modified() )
                        {
                                &ar( MODIFIED => 1, MODIFIED_DATE => $self -> readable_date( $message -> modified_date() ) );
                        }
                }
        } else
        {
                &ar( DONT_SHOW_MESSAGE_DATA => 1 );
        }

        return;
}

sub edit_message
{
        my $self = shift;
        my $message_id = shift;
        my $subject = shift;
        my $content = shift;

        my $message = FModel::Messages -> get( id => $message_id );

        $message -> subject( $subject );
        $message -> content( $content );
        $message -> modified( 1 );
        $message -> modified_date( $self -> now() );

        $message -> update();

        return;
}

sub app_mode_delete_thread
{
        my $self = shift;

        return $self -> nctd( 'This feature is in development' );
}

sub app_mode_delete_message
{
        my $self = shift;

        my $message_id = $self -> arg( 'message_id' ) || 0;
        my $from = $self -> arg( 'from' ) || 'thread';
         
        my $output;

        if( my $can_delete = $self -> can_do_action_with_message( 'delete', $message_id ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                my $thread_id = $message -> thread_id() -> id();

                $message -> delete();

                my $success_msg = 'MESSAGE_DELETED';

                if( $from eq 'thread' )
                {
                        $self -> add_thread_data( $thread_id, 'full', 'with_messages' );
                        $output = $self -> construct_page( middle_tpl => 'thread', success_msg => $success_msg );
                }
                elsif( $from eq 'mainpage' )
                {
                        $output = $self -> ncrd( '/?success_msg=' . $success_msg );
                }
        }
        elsif( ( not $can_delete ) and ( $from eq 'thread' ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );
                my $thread_id = $message -> thread_id() -> id();

                $self -> add_thread_data( $thread_id, 'full', 'with_messages' );
                $output = $self -> construct_page( middle_tpl => 'thread', error_msg => 'CANNOT_DELETE_MESSAGE' );
        }
        elsif( ( not $can_delete ) and ( $from ne 'thread' ) )
        {
                $output = $self -> ncrd( '/?error_msg=' . 'CANNOT_DELETE_MESSAGE' );
        }

        return $output;
}

sub add_thread_data
{
        my $self = shift;
        my $thread_id = shift;
        my $full = shift;
        my $with_messages = shift;

        &ar( THREAD_ID => $thread_id);

        if( not my $error = $self -> check_if_proper_thread_id_provided( $thread_id ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                &ar( TITLE => $thread -> title() );

                if( $full )
                {
                        &ar( CONTENT => $thread -> content(),
                             CREATED => $self -> readable_date( $thread -> created() ),
                             AUTHOR  => $thread -> user_id() -> name(),
                             CAN_DELETE => $self -> can_do_action_with_thread( 'delete', $thread_id ),
                             CAN_EDIT   => $self -> can_do_action_with_thread( 'edit', $thread_id ),
                             AUTHOR_AVATAR => $self -> get_user_avatar_src( $thread -> user_id() -> id() ) );

                        if( $thread -> modified() )
                        {
                                &ar( MODIFIED => 1, MODIFIED_DATE => $self -> readable_date( $thread -> modified_date() ) );
                        }

                        if( $with_messages )
                        {
                                $self -> add_messages( $thread_id );
                        }
                }
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
                                 AUTHOR     => $message -> user_id() -> name(),
                                 CAN_DELETE => $self -> can_do_action_with_message( 'delete', $message -> id() ),
                                 CAN_EDIT   => $self -> can_do_action_with_message( 'edit', $message -> id() ),
                                 AUTHOR_AVATAR => $self -> get_user_avatar_src( $message -> user_id() -> id() )
                                 };

                if( $message -> modified() )
                {
                        $msg_hash -> { 'MODIFIED' } = 1;
                        $msg_hash -> { 'MODIFIED_DATE' } = $self -> readable_date( $message -> modified_date() );
                }

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


1;
