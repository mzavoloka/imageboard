use strict;

package localhost::thread;

sub wendy_handler
{
        my $self = shift;
        return ForumThread -> run();
}

package ForumThread;
use Wendy::Shorts qw( ar gr lm );
use Wendy::Templates::TT 'tt';
use Carp::Assert 'assert';
use File::Copy 'cp';
use Data::Dumper 'Dumper';

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'create', 'reply', 'edit', 'delete', 'edit_message', 'delete_message' ] };

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
        elsif( defined $self -> arg( 'mode' ) and $self -> is_user_banned( $self -> user_id() ) )
        {
                $rv = $self -> construct_page( restricted_msg => 'YOU_ARE_BANNED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;
        my $thread_id = $self -> arg( 'thread_id' ) || 0;
        my $page = $self -> arg( 'page' ) || 1;
        
        my $output;

        &ar( THREAD_ID => $thread_id ); 

        if( my $error_msg = $self -> can_show_thread( $thread_id ) )
        {
                $output = $self -> construct_page( middle_tpl => 'thread', error_msg => $error_msg );
        } else
        {
                $self -> add_thread_data( $thread_id, 'full', 'with_messages', $page );
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
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $output;

        if( not $create_button_pressed )
        {
                $output = $self -> construct_page( middle_tpl => 'thread_create' );
        }
        elsif( $create_button_pressed and ( my $error_msg = $self -> can_create( $title, $content, $pinned_image ) ) )
        {
                &ar( TITLE => $title, CONTENT => $content );
                $output = $self -> construct_page( middle_tpl => 'thread_create', error_msg => $error_msg );
        }
        elsif( $create_button_pressed and ( not $error_msg ) )
        {
                my $user = FModel::Users -> get( name => $self -> user() );
                my $new_thread_id = $self -> create( $title, $content, $pinned_image );
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
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $output;

        my $error_msg = $self -> can_edit( $thread_id, $title, $content, $edit_button_pressed, $pinned_image );
        
        if( $error_msg or ( ( not $error_msg ) and ( not $edit_button_pressed ) ) )
        {
                $self -> add_thread_data( $thread_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'thread_edit', error_msg => $error_msg );
        }
        elsif( ( not $error_msg ) and $edit_button_pressed )
        {
                $self -> edit( $thread_id, $title, $content, $pinned_image );
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
        my $edit_button_pressed = shift;
        my $pinned_image = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) );
        
        my $can_edit = $self -> can_do_action_with_thread( 'edit', $thread_id );

        if( not $can_edit )
        {
                $error_msg = 'CANNOT_EDIT_THREAD';
                &ar( DONT_SHOW_THREAD_DATA => 1 );
        }
        elsif( $can_edit and $edit_button_pressed and ( not $fields_are_filled ) )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( $can_edit and $edit_button_pressed and $fields_are_filled and ( not $self -> is_thread_title_length_acceptable( $title ) ) )
        {
                $error_msg = 'THREAD_TITLE_TOO_LONG';
        }
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
        }

        return $error_msg;
}

sub edit
{
        my $self = shift;
        my $thread_id = shift;
        my $title = shift;
        my $content = shift;
        my $pinned_image = shift;

        my $thread = FModel::Threads -> get( id => $thread_id );

        $thread -> title( $title );
        $thread -> content( $content );

        $thread -> modified( 1 );
        my $now = $self -> now();
        $thread -> modified_date( $now );
        $thread -> updated( $now );

        $thread -> update();

        $self -> pin_image_to_thread( $thread_id, $pinned_image );

        return;
}

sub app_mode_reply
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

sub check_pinned_image
{
        my $self = shift;
        my $image = shift || '';

        my $error_msg = '';

        my $filesize = -s $image;

        if( $image and CGI::uploadInfo( $image ) -> { 'Content-Type' } ne 'image/jpeg' ) # Add macros for this thing with list of correct filetypes
        {
                $error_msg = 'PINNED_IMAGE_INCORRECT_FILETYPE';
        }
        elsif( $image and $filesize > &gr( 'PINNED_IMAGE_MAX_SIZE' ) )
        {
                $error_msg = 'PINNED_IMAGE_FILESIZE_TOO_BIG';
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
        my $pinned_image = shift;
        
        my $user = FModel::Users -> get( name => $self -> user() );

        my $new_message = FModel::Messages -> create( subject   => $subject,
                                                      content   => $content,
                                                      user_id   => $user -> id(),
                                                      thread_id => $thread_id,
                                                      posted    => $self -> now() );

        $self -> pin_image_to_message( $new_message -> id(), $pinned_image );
        $self -> update_thread( $thread_id );

        return;
}

sub pin_image_to_thread
{
        my $self = shift;
        my $thread_id = shift || 0;
        my $image = shift;

        my $success = 0;

        if( $image and ( not my $error = $self -> check_if_proper_thread_id_provided( $thread_id ) ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                if( my $old_image_filename = $thread -> pinned_img() )
                {
                        unlink $self -> pinned_images_dir_abs() . $old_image_filename;
                }

                my $filename = $self -> new_pinned_image_filename();
                my $filepath = $self -> pinned_images_dir_abs() . $filename;

                cp( $image, $filepath );
                $thread -> pinned_img( $filename );
                $thread -> update();

                $success = 1;
        }

        return $success;
}

sub pin_image_to_message
{
        my $self = shift;
        my $message_id = shift || 0;
        my $image = shift || '';

        my $success = 0;

        if( $image and ( not my $error = $self -> check_if_proper_message_id_provided( $message_id ) ) )
        {

                my $message = FModel::Messages -> get( id => $message_id );

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

sub update_thread
{
        my $self = shift;
        my $thread_id = shift;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_thread_id_provided( $thread_id ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                $thread -> updated( $self -> now() );
                $thread -> update();

                $success = 1;
        }

        return $success;
}

sub new_pinned_image_filename
{
        my $self = shift;

        my $filename = '';

        for my $number ( 1 .. 20 )
        {
                $filename .= int( rand( 10 ) );
        }

        if( $self -> is_pinned_filename_exists( $filename ) )
        {
                $filename = $self -> new_pinned_image_filename();
        }

        return $filename;
}

sub is_pinned_filename_exists
{
        my $self = shift;
        my $filename = shift;

        my $exists = 0;

        if( -e $self -> pinned_images_dir_abs() . $filename )
        {
                $exists = 1;
        }

        return $exists;
}

sub app_mode_edit_message
{
        my $self = shift;

        my $message_id = $self -> arg( 'message_id' );
        my $subject    = $self -> arg( 'subject' ) || '';
        my $content    = $self -> arg( 'content' ) || '';
        my $edit_button_pressed = $self -> arg( 'edit_button' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $output;

        my $error_msg = $self -> can_edit_message( $message_id, $subject, $content, $edit_button_pressed, $pinned_image );

        if( $error_msg or ( ( not $error_msg ) and ( not $edit_button_pressed ) ) )
        {
                $self -> add_message_data( $message_id, 'full' );
                $output = $self -> construct_page( middle_tpl => 'message_edit', error_msg => $error_msg );
        }
        elsif( ( not $error_msg ) and $edit_button_pressed )
        {
                $self -> edit_message( $message_id, $subject, $content, $pinned_image );
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
        my $pinned_image = shift;

        my $error_msg = '';
        
        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

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
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
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
                             PINNED_IMAGE => $self -> get_message_pinned_image_src( $message_id ),
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
        my $pinned_image = shift;

        my $message = FModel::Messages -> get( id => $message_id );

        $message -> subject( $subject );
        $message -> content( $content );

        $message -> modified( 1 );
        $message -> modified_date( $self -> now() );

        $message -> update();

        $self -> pin_image_to_message( $message_id, $pinned_image );

        return;
}

sub app_mode_delete_message
{
        my $self = shift;

        my $message_id = $self -> arg( 'message_id' ) || 0;
        my $from = $self -> arg( 'from' ) || 'thread';
         
        my $output;

        my $thread_id = $self -> get_message_thread_id( $message_id );

        if( my $can_delete = $self -> can_do_action_with_message( 'delete', $message_id ) )
        {
                $self -> delete_message( $message_id );

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
        my $message_id = shift;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_message_id_provided( $message_id ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

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
        my $message_id = shift;

        my $thread_id;

        if( not my $error = $self -> check_if_proper_message_id_provieded( $message_id ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                $thread_id = $message -> thread_id() -> id();
        }

        return $thread_id;
}


sub app_mode_delete
{
        my $self = shift;

        my $thread_id = $self -> arg( 'thread_id' ) || 0;

        my $output;

        if( my $can_delete = $self -> can_do_action_with_thread( 'delete', $thread_id ) )
        {
                $self -> delete_thread( $thread_id );

                my $success_msg = 'MESSAGE_DELETED';
                $output = $self -> ncrd( '/?success_msg=' . $success_msg );
        }
        else
        {
                $output = $self -> ncrd( '/?error_msg=' . 'CANNOT_DELETE_THREAD' );
        }

        return $output;
}

sub delete_thread
{
        my $self = shift;
        my $thread_id = shift || 0;

        if( not my $error = $self -> check_if_proper_thread_id_provided( $thread_id ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                my @thread_messages = FModel::Messages -> get_many( thread_id => $thread_id );

                foreach my $message ( @thread_messages )
                {
                        $self -> delete_message( $message -> id() );
                }

                if( my $pinned_image = $thread -> pinned_img() )
                {
                        unlink $self -> pinned_images_dir_abs() . $pinned_image;
                }

                $thread -> delete();
        }

        return;
}

sub add_thread_data
{
        my $self = shift;
        my $thread_id = shift;
        my $full = shift;
        my $with_messages = shift;
        my $page = shift;

        &ar( THREAD_ID => $thread_id);

        if( not my $error = $self -> check_if_proper_thread_id_provided( $thread_id ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                &ar( TITLE => $thread -> title() );

                if( $full )
                {
                        &ar( CONTENT => $thread -> content(),
                             PINNED_IMAGE => $self -> get_thread_pinned_image_src( $thread_id ),
                             CREATED => $self -> readable_date( $thread -> created() ),
                             AUTHOR  => $thread -> user_id() -> name(),
                             CAN_DELETE => $self -> can_do_action_with_thread( 'delete', $thread_id ),
                             CAN_EDIT   => $self -> can_do_action_with_thread( 'edit', $thread_id ),
                             AUTHOR_AVATAR => $self -> get_user_avatar_src( $thread -> user_id() -> id() ),
                             AUTHOR_PERMISSIONS => $self -> get_user_special_permissions ( $thread -> user_id() -> id() ) );

                        if( $thread -> modified() )
                        {
                                &ar( MODIFIED => 1, MODIFIED_DATE => $self -> readable_date( $thread -> modified_date() ) );
                        }

                        if( $with_messages )
                        {
                                $self -> add_messages( $thread_id, $page );
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
        my $page = shift || 1;

        my @messages_sorted = sort { $a -> posted() cmp $b -> posted() } FModel::Messages -> get_many( thread_id => $thread_id );
        my $messages = [];

        my $count_of_messages = scalar( @messages_sorted );
        my $messages_on_page = &gr( 'MESSAGES_ON_PAGE' );
        my $show_from = ( $page - 1 ) * $messages_on_page;
        my $show_to = $self -> min_of( $show_from + $messages_on_page, $count_of_messages );

        for( my $index = $show_from; $index < $show_to; $index++ )
        {
                my $message = $messages_sorted[ $index ];

                my $msg_hash = { MESSAGE_ID => $message -> id(),
                                 POSTED     => $self -> readable_date( $message -> posted() ),
                                 SUBJECT    => $message -> subject(),
                                 CONTENT    => $message -> content(),
                                 PINNED_IMAGE => $self -> get_message_pinned_image_src( $message -> id() ),
                                 AUTHOR     => $message -> user_id() -> name(),
                                 CAN_DELETE => $self -> can_do_action_with_message( 'delete', $message -> id() ),
                                 CAN_EDIT   => $self -> can_do_action_with_message( 'edit', $message -> id() ),
                                 AUTHOR_AVATAR => $self -> get_user_avatar_src( $message -> user_id() -> id() ),
                                 AUTHOR_PERMISSIONS => $self -> get_user_special_permissions ( $message -> user_id() -> id() )
                                 };

                if( $message -> modified() )
                {
                        $msg_hash -> { 'MODIFIED' } = 1;
                        $msg_hash -> { 'MODIFIED_DATE' } = $self -> readable_date( $message -> modified_date() );
                }

                push( $messages, $msg_hash );
        }
         
        if( $count_of_messages > 0 )
        {
                &ar( MESSAGES => $messages );
                &ar( PAGES => $self -> add_pages( $thread_id, $page ) );
        }

        return $messages;
}

sub add_pages
{
        my $self = shift;
        my $thread_id = shift;
        my $current_page = shift;

        my $count_of_messages = FModel::Messages -> count( thread_id => $thread_id );
        my $messages_on_page = &gr( 'MESSAGES_ON_PAGE' );

        my $num_of_pages = int( $count_of_messages / $messages_on_page ) + 1;

        my $pages = [];

        if( $num_of_pages > 1 )
        {
                for my $page ( 1 .. $num_of_pages )
                {
                        my $hash = { PAGE => $page };

                        if( $page == $current_page )
                        {
                                $hash -> { 'CURRENT' } = 1;
                        }

                        push( @$pages, $hash );
                }
        }

        &ar( PAGES => $pages );

        return &tt( 'pages' );
}

sub can_create
{
        my $self = shift;
        my $title = shift;
        my $content = shift;
        my $pinned_image = shift;

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
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
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
        my $pinned_image = shift;

        my $user = FModel::Users -> get( name => $self -> user() );

        my $new_thread = FModel::Threads -> create( title => $title, content => $content, user_id => $user -> id(), created => $self -> now(), updated => $self -> now() );

        $self -> pin_image_to_thread( $new_thread -> id(), $pinned_image );

        return $new_thread -> id();
}


1;
