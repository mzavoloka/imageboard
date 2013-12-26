use strict;

package localhost::thread_message;

sub wendy_handler
{
        return ForumMessage -> run();
}

package ForumMessage;
use Wendy::Shorts 'ar';
use Carp::Assert 'assert';
use File::Copy 'cp';
use URI qw( new query_from as_string );
use Data::Dumper 'Dumper';
use ForumConst qw( pinned_images_dir_abs );

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'create_form', 'do_create', 'edit_form', 'do_edit', 'delete' ] };

sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( not $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'MESSAGE_RESTRICTED' );
        }
        elsif( $self -> is_user_banned( $self -> user() -> id() ) )
        {
                $rv = $self -> construct_page( restricted_msg => 'YOU_ARE_BANNED' );
        }

        return $rv;
}

sub app_mode_create_form
{
        my $self = shift;

        my $output = $self -> show_create_form();

        return $output;
}

sub app_mode_do_create
{
        my $self = shift;

        my $output;

        if( my $error_msg = $self -> can_create() )
        {
                $output = $self -> show_create_form( error_msg => $error_msg );
        } else
        {
                $self -> create();
                my $u = URI -> new( '/thread/' );

                my $thread_id = $self -> arg( 'thread_id' );
                $u -> query_form( id => $thread_id, success_msg => 'NEW_MESSAGE_CREATED' );

                $output = $self -> ncrd( $u -> as_string() );
        }

        return $output;
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

        my $output;

        if( my $error_msg = $self -> can_edit() )
        {
                $output = $self -> show_edit_form( error_msg => $error_msg );
        }
        else
        {
                $self -> edit_message();

                my $u = URI -> new( '/thread/' );
                $u -> query_form( succes_msg => 'MESSAGE_EDITED',
                                  id => $self -> get_message_thread_id( $self -> arg( 'id' ) ) );
                $output = $self -> ncrd( $u -> as_string() );
        }

        return $output;
}

sub app_mode_delete
{
        my $self = shift;

        my $output;

        # Handle from param
        
        if( my $error_msg = $self -> check_if_can_delete() )
        {
                my $u = URI -> new( '/' );
                $u -> query_form( error_msg => $error_msg );
                $output = $self -> ncrd( $u -> as_string() );
        }
        else
        {
                $self -> delete_message();

                my $u = URI -> new( '/' );
                $u -> query_form( success_msg => 'MESSAGE_DELETED' );
                $output = $self -> ncrd( $u -> as_string() );
        }

        return $output;
}

sub check_if_can_delete
{
        my $self = shift;

        my $id = $self -> arg( 'id' ) || shift || 0;

        my $error_msg = '';

        if( my $id_error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                $error_msg = $id_error;
        }
        elsif( not $self -> can_do_action_with_message( 'delete', $id ) )
        {
                $error_msg = 'CANNOT_DELETE_MESSAGE';
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

sub show_create_form
{
        my $self = shift;
        my %params = @_;

        my $error_msg = $params{ 'error_msg' } || '';

        my $thread_id    = $self -> arg( 'thread_id' );
        my $subject      = $self -> arg( 'subject' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        &ar( DYN_THREAD_ID => $thread_id, DYN_SUBJECT => $subject, DYN_CONTENT => $content, DYN_PINNED_IMAGE => $pinned_image );

        my $output = $self -> construct_page( middle_tpl => 'message_create', error_msg => $error_msg );

        return $output;
}

sub show_edit_form
{
        my $self = shift;
        my %params = @_;

        my $id = $self -> arg( 'id' ) || $params{ 'id' } || 0;

        my $error_msg = $params{ 'error_msg' } || '';
        
        &ar( DYN_ID => $id );

        if( my $cant_show_form_msg = $self -> check_if_can_show_edit_form() )
        {
                $error_msg = $cant_show_form_msg;
                &ar( DYN_DONT_SHOW_MESSAGE_DATA => 1 );
        } else
        {
                my $message = FModel::Messages -> get( id => $id );

                &ar( DYN_SUBJECT => $message -> subject(),
                     DYN_CONTENT => $message -> content(),
                     DYN_PINNED_IMAGE => $self -> get_message_pinned_image_src( $id )
                     );
        }

        my $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );

        return $output;
}

sub check_if_can_show_edit_form
{
        my $self = shift;

        my $id = shift || $self -> arg( 'id' ) || 0;

        my $error_msg = '';

        if( my $id_error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                $error_msg = $id_error;
        }
        elsif( not $self -> can_do_action_with_message( 'edit', $id ) )
        {
                $error_msg = 'CANNOT_EDIT_MESSAGE';
        }

        return $error_msg;
}

sub delete_message
{
        my $self = shift;

        my $id = $self -> arg( 'id' ) || shift || 0;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                my $message = FModel::Messages -> get( id => $id );

                if( my $pinned_image = $message -> pinned_img() )
                {
                        unlink ForumConst -> pinned_images_dir_abs() . $pinned_image;
                }

                $message -> delete();

                $success = 1;
        }

        return $success;
}

sub get_message_thread_id
{
        my $self = shift;
        my $message_id = shift;

        my $thread_id;

        if( not my $error = $self -> check_if_proper_message_id_provided( $message_id ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                $thread_id = $message -> thread_id() -> id();
        }

        return $thread_id;
}

sub can_create
{
        my $self = shift;

        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $subject = $self -> arg( 'subject' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

        if( my $thread_id_error = $self -> check_if_proper_thread_id_provided( $thread_id ) )
        {
                $error_msg = $thread_id_error;
        }
        elsif( not $fields_are_filled )
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

        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $subject = $self -> arg( 'subject' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );
        
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

sub can_edit
{
        my $self = shift;

        my $id           = $self -> arg( 'id' );
        my $subject      = $self -> arg( 'subject' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $error_msg = '';
        
        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

        if( my $message_id_error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                $error_msg = $message_id_error;
        }
        elsif( not $self -> can_do_action_with_message( 'edit', $id ) )
        {
                $error_msg = 'CANNOT_EDIT_MESSAGE';
        }
        elsif( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( not $self -> is_message_subject_length_acceptable( $subject ) )
        {
                $error_msg = 'MESSAGE_SUBJECT_TOO_LONG';
        }
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
        }

        return $error_msg;
}

sub edit_message
{
        my $self = shift;

        my $id           = $self -> arg( 'id' );
        my $subject      = $self -> arg( 'subject' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        # add transaction;

        my $message = FModel::Messages -> get( id => $id );

        $message -> subject( $subject );
        $message -> content( $content );

        $message -> modified( 1 );
        $message -> modified_date( $self -> now() );

        $message -> update();

        $self -> pin_image_to_message( $id, $pinned_image );

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
                        unlink ForumConst -> pinned_images_dir_abs() . $old_image_filename;
                }

                my $filename = $self -> new_pinned_image_filename();
                my $filepath = ForumConst -> pinned_images_dir_abs() . $filename;

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

        if( length( $subject ) > ForumConst -> message_subject_max_length() )
        {
                $acceptable = 0;
        }

        return $acceptable;
}


1;
