use strict;

package localhost::thread_message;

sub wendy_handler
{
        return ForumMessage -> run();
}

package ForumMessage;
#use Wendy::Shorts qw( ar gr lm );
#use Wendy::Templates::TT 'tt';
#use Carp::Assert 'assert';
#use File::Copy 'cp';
use Data::Dumper 'Dumper';

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'create_form', 'do_create', 'edit_form', 'edit', 'delete' ] };

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
                $rv = $self -> construct_page( restricted_msg => 'MESSAGE_RESTRICTED' );
        }
        elsif( defined $self -> arg( 'mode' ) and $self -> user() and $self -> is_user_banned( $self -> user() -> id() ) )
        {
                $rv = $self -> construct_page( restricted_msg => 'YOU_ARE_BANNED' );
        }

        return $rv;
}

sub app_mode_edit_form
{
        my $self = shift;

        my $output = $self -> show_edit_form();

        return $output;
}

sub app_mode_do_edit
{
        my $self = shift;

        my $id           = $self -> arg( 'id' );
        my $subject      = $self -> arg( 'subject' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $output;

        if( my $error_msg = $self -> can_edit_message( $id, $subject, $content, $pinned_image ) )
        {
                $self -> add_message_data( $id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );
        }
        else
        {
                $self -> edit_message( $id, $subject, $content, $pinned_image );
                my $message = FModel::Messages -> get( id => $id );
                $output = $self -> ncrd( '/thread/?id=' . $message -> thread_id() -> id() );
        }

        return $output;
}

# old
sub app_mode_edit
{
        my $self = shift;

        my $id           = $self -> arg( 'id' );
        my $subject      = $self -> arg( 'subject' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $output;

        my $error_msg = $self -> can_edit_message( $id, $subject, $content, $pinned_image );

        if( $error_msg or ( ( not $error_msg ) and ( not $edit_button_pressed ) ) )
        {
                $self -> add_message_data( $id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );
        }
        elsif( ( not $error_msg ) and $edit_button_pressed )
        {
                $self -> edit_message( $id, $subject, $content, $pinned_image );
                my $message = FModel::Messages -> get( id => $id );
                $output = $self -> ncrd( '/thread/?id=' . $message -> thread_id() -> id() );
        }

        return $output;
}

sub can_edit_message
{
        my $self = shift;
        my $id = shift;
        my $subject = shift;
        my $content = shift;
        my $edit_button_pressed = shift;
        my $pinned_image = shift;

        my $error_msg = '';
        
        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

        my $can_edit = $self -> can_do_action_with_message( 'edit', $id );

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
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
        }

        return $error_msg;
}

sub add_message_data
{
        my $self = shift;
        my $id = shift;
        my $full = shift;
        
        &ar( MESSAGE_ID => $id );

        if( not my $error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                my $message = FModel::Messages -> get( id => $id );

                &ar( SUBJECT => $message -> subject() );

                if( $full )
                {
                        &ar( CONTENT => $message -> content(),
                             PINNED_IMAGE => $self -> get_message_pinned_image_src( $id ),
                             POSTED => $self -> readable_date( $message -> posted() ),
                             AUTHOR  => $message -> user_id() -> name(),
                             SHOW_MANAGE_LINKS => $self -> is_message_belongs_to_current_user( $id ) );

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
        my $id = shift;
        my $subject = shift;
        my $content = shift;
        my $pinned_image = shift;

        my $message = FModel::Messages -> get( id => $id );

        $message -> subject( $subject );
        $message -> content( $content );

        $message -> modified( 1 );
        $message -> modified_date( $self -> now() );

        $message -> update();

        $self -> pin_image_to_message( $id, $pinned_image );

        return;
}

sub app_mode_delete_message
{
        my $self = shift;

        my $id = $self -> arg( 'id' ) || 0;
        my $from = $self -> arg( 'from' ) || 'thread';
         
        my $output;

        my $thread_id = $self -> get_message_thread_id( $id );

        if( my $can_delete = $self -> can_do_action_with_message( 'delete', $id ) )
        {
                $self -> delete_message( $id );

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
                $self -> add_thread_data( $thread_id, 'full', 'with_messages' );
                $output = $self -> construct_page( middle_tpl => 'thread', error_msg => 'CANNOT_DELETE_MESSAGE' );
        }
        elsif( ( not $can_delete ) and ( $from ne 'thread' ) )
        {
                $output = $self -> ncrd( '/?error_msg=' . 'CANNOT_DELETE_MESSAGE' );
        }

        return $output;
}

sub delete_message
{
        my $self = shift;
        my $id = shift;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                my $message = FModel::Messages -> get( id => $id );

                if( my $pinned_image = $message -> pinned_img() )
                {
                        unlink $self -> pinned_images_dir_abs() . $pinned_image;
                }

                $message -> delete();

                $success = 1;
        }

        return $success;
}

sub get_message_thread_id
{
        my $self = shift;
        my $id = shift;

        my $thread_id;

        if( not my $error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                my $message = FModel::Messages -> get( id => $id );

                $thread_id = $message -> thread_id() -> id();
        }

        return $thread_id;
}

sub app_mode_create
{
        my $self = shift;

        my $thread_id = 
}

sub app_mode_create
{
        my $self = shift;

        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $subject = $self -> arg( 'subject' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );
        my $reply_button_pressed = $self -> arg( 'reply_button' ) || '';

        my $output;

        my $thread_id_error = $self -> check_if_proper_thread_id_provided( $thread_id );

        if( $thread_id_error )
        {
                $output = $self -> construct_page( middle_tpl => 'thread_reply', error_msg => $thread_id_error );
        }
        elsif( ( not $thread_id_error ) and $reply_button_pressed )
        {
                if( my $error_msg = $self -> can_reply( $subject, $content, $pinned_image ) )
                {
                        $self -> add_thread_data( $thread_id );
                        &ar( SUBJECT => $subject, CONTENT => $content, PINNED_IMAGE => $pinned_image );
                        $output = $self -> construct_page( middle_tpl => 'thread_reply', error_msg => $error_msg );
                } else
                {
                        $self -> reply( $thread_id, $subject, $content, $pinned_image );
                        $output = $self -> ncrd( '/thread/?id=' . $thread_id );
                }
        }
        elsif( ( not $thread_id_error ) and ( not $reply_button_pressed ) )
        {
                $self -> add_thread_data( $thread_id );
                $output = $self -> construct_page( middle_tpl => 'thread_reply' );
        }


        return $output;
}

sub can_create
{
        my $self = shift;
        my $subject = shift;
        my $content = shift;
        my $pinned_image = shift;

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
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
        }

        return $error_msg;
}

sub create
{
        my $self = shift;
        my $thread_id = shift;
        my $subject = shift;
        my $content = shift;
        my $pinned_image = shift;
        
        my $user = FModel::Users -> get( name => $self -> user() -> name() );

        my $new_message = FModel::Messages -> create( subject   => $subject,
                                                      content   => $content,
                                                      user_id   => $user -> id(),
                                                      thread_id => $thread_id,
                                                      posted    => $self -> now() );

        $self -> pin_image_to_message( $new_message -> id(), $pinned_image );
        $self -> update_thread( $thread_id );

        return;
}

sub pin_image_to_message
{
        my $self = shift;
        my $id = shift || 0;
        my $image = shift || '';

        my $success = 0;

        if( $image and ( not my $error = $self -> check_if_proper_message_id_provided( $id ) ) )
        {

                my $message = FModel::Messages -> get( id => $id );

                if( my $old_image_filename = $message -> pinned_img() )
                {
                        unlink $self -> pinned_images_dir_abs() . $old_image_filename;
                }

                my $filename = $self -> new_pinned_image_filename();
                my $filepath = $self -> pinned_images_dir_abs() . $filename;

                cp( $image, $filepath );
                $message -> pinned_img( $filename );
                $message -> update();

                $success = 1;
        }

        return $success;
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



1;
