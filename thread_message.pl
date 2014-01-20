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

        return $rv;
}

sub app_mode_create_form
{
        my $self = shift;

        my $output;

        if( my $id_error = $self -> check_if_proper_thread_id_provided( int( $self -> arg( 'thread_id' ) ) ) )
        {
                $self -> construct_page( middle_tpl => 'unexpected_error', error_msg => $id_error );
        } else
        {
                $output = $self -> show_create_form();
        }

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
                $self -> create_message();
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
                my $id = int( $self -> arg( 'id' ) );

                $self -> edit_message();

                my $u = URI -> new( '/thread/' );
                my $message = FModel::Messages -> get( id => $id );
                $u -> query_form( succes_msg => 'MESSAGE_EDITED',
                                  id =>  $message -> thread() -> id() );
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

        my $id = int( $self -> arg( 'id' ) );

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

sub show_create_form
{
        my ( $self, %params ) = @_;

        my $error_msg = $params{ 'error_msg' };

        my $thread_id    = $self -> arg( 'thread_id' );
        my $subject      = $self -> arg( 'subject' );
        my $content      = $self -> arg( 'content' );
        my $pinned_image = $self -> upload( 'pinned_image' );

        &ar( DYN_THREAD_ID => $thread_id, DYN_SUBJECT => $subject, DYN_CONTENT => $content, DYN_PINNED_IMAGE => $pinned_image );

        my $output = $self -> construct_page( middle_tpl => 'message_create', error_msg => $error_msg );

        return $output;
}

sub show_edit_form
{
        my ( $self, %params ) = @_;

        my $id = int( $self -> arg( 'id' ) || $params{ 'id' } );

        my $error_msg = $params{ 'error_msg' };
        
        &ar( DYN_ID => $id );

        if( my $cant_show_form_msg = $self -> check_if_can_show_edit_form() )
        {
                $error_msg = $cant_show_form_msg;
                &ar( DYN_DONT_SHOW_MESSAGE_DATA => 1 );
        } else
        {
                my $message = FModel::Messages -> get( id => $id );

                &ar( DYN_SUBJECT      => $message -> subject(),
                     DYN_CONTENT      => $message -> content(),
                     DYN_PINNED_IMAGE => $message -> pinned_image_url() );
        }

        my $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );

        return $output;
}

sub check_if_can_show_edit_form
{
        my $self = shift;

        my $id = int( $self -> arg( 'id' ) );

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

        my $id = int( $self -> arg( 'id' ) );

        my $success = 0;

        if( not my $error = $self -> check_if_proper_message_id_provided( $id ) )
        {
                my $message = FModel::Messages -> get( id => $id );

                $message -> delete_pinned_image();
                $message -> delete();

                $success = 1;
        }

        return $success;
}

sub get_message_thread_id
{
        my ( $self, $message_id ) = @_;

        my $thread_id;

        if( not my $error = $self -> check_if_proper_message_id_provided( $message_id ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                $thread_id = $message -> thread() -> id();
        }

        return $thread_id;
}

sub can_create
{
        my $self = shift;

        my $thread_id    = int( $self -> arg( 'thread_id' ) );
        my $subject      = $self -> arg( 'subject' );
        my $content      = $self -> arg( 'content' );
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $error_msg = '';

        my $fields_are_filled = ( Funcs::trim( $subject ) and Funcs::trim( $content ) );

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

sub create_message
{
        my $self = shift;

        my $thread_id    = int( $self -> arg( 'thread_id' ) );
        my $subject      = $self -> arg( 'subject' );
        my $content      = $self -> arg( 'content' );
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $dbh = LittleORM::Db -> get_write_dbh();
        $dbh -> begin_work();
        
        my $user = FModel::Users -> get( name => $self -> user() -> name() );

        my $new_message = FModel::Messages -> create( subject => $subject,
                                                      content => $content,
                                                      user => $user,
                                                      thread  => $thread_id,
                                                      posted  => Funcs::now() );

        $self -> pin_image_to_message( $new_message -> id(), $pinned_image );

        my $thread = FModel::Threads -> get( id => $thread_id );

        $thread -> update_thread();

        assert( $dbh -> commit() );

        return;
}

sub can_edit
{
        my $self = shift;

        my $id           = int( $self -> arg( 'id' ) );
        my $subject      = $self -> arg( 'subject' );
        my $content      = $self -> arg( 'content' );
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $error_msg = '';
        
        my $fields_are_filled = ( Funcs::trim( $subject ) and Funcs::trim( $content ) );

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

        my $id           = int( $self -> arg( 'id' ) );
        my $subject      = $self -> arg( 'subject' );
        my $content      = $self -> arg( 'content' );
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $dbh = LittleORM::Db -> get_write_dbh();
        $dbh -> begin_work();

        my $message = FModel::Messages -> get( id => $id );

        $message -> subject( $subject );
        $message -> content( $content );

        $message -> modified( Funcs::now() );

        $message -> update();

        $self -> pin_image_to_message( $id, $pinned_image );

        assert( $dbh -> commit() );

        return;
}


sub pin_image_to_message
{
        my ( $self, $id, $image ) = @_;

        my $success = 0;

        if( $image and ( not my $error = $self -> check_if_proper_message_id_provided( $id ) ) )
        {
                my $message = FModel::Messages -> get( id => $id );

                $message -> delete_pinned_image();

                my $filename = $self -> new_pinned_image_filename();
                my $filepath = File::Spec -> catfile( ForumConst -> pinned_images_dir_abs(), $filename );

                cp( $image, $filepath );
                $message -> pinned_img( $filename );
                $message -> update();

                $success = 1;
        }

        return $success;
}

sub is_message_subject_length_acceptable
{
        my ( $self, $subject ) = @_;
        
        my $acceptable = 1;

        if( length( $subject ) > ForumConst -> message_subject_max_length() )
        {
                $acceptable = 0;
        }

        return $acceptable;
}


1;
