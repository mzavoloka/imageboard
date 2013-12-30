use strict;

package localhost::thread;

sub wendy_handler
{
        return ForumThread -> run();
}

package ForumThread;
use Wendy::Shorts qw( ar );
use Wendy::Templates::TT 'tt';
use Carp::Assert 'assert';
use File::Copy 'cp';
use URI qw( new query_from as_string );
use Data::Dumper 'Dumper';
use ForumConst qw( pinned_images_dir_abs );

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'create_form', 'do_create', 'edit_form', 'do_edit', 'delete', 'vote' ] };

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
        elsif( defined $self -> arg( 'mode' ) and $self -> user() -> banned() )
        {
                $rv = $self -> construct_page( restricted_msg => 'YOU_ARE_BANNED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> show_thread();

        return $output;
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
                my $new_thread_id = $self -> create();
                $output = $self -> show_thread( id => $new_thread_id, success_msg => 'NEW_THREAD_CREATED' );
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
                $self -> edit();
                $output = $self -> show_thread( success_msg => 'THREAD_EDITED' );
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
                $self -> delete_thread();

                my $u = URI -> new( '/' );
                $u -> query_form( success_msg => 'THREAD_DELETED' );
                $output = $self -> ncrd( $u -> as_string() );
        }

        return $output;
}

sub check_if_can_delete
{
        my $self = shift;

        my $id = $self -> arg( 'id' ) || shift || 0;

        my $error_msg = '';

        if( my $id_error = $self -> check_if_proper_thread_id_provided( $id ) )
        {
                $error_msg = $id_error;
        }
        elsif( not $self -> can_do_action_with_thread( 'delete', $id ) )
        {
                $error_msg = 'CANNOT_DELETE_THREAD';
        }

        return $error_msg;
}

sub app_mode_vote
{
        my $self = shift;
        my $id = $self -> arg( 'id' ) || 0;

        my $output;

        # Handle from param

        if( my $error_msg = $self -> check_if_proper_thread_id_provided( $id ) )
        {
                $output = $self -> show_thread( error_msg => $error_msg );
        }
        else
        {
                $self -> do_vote( $id );
                $output = $self -> show_thread( success_msg => 'VOTE_SUCCESS' );
        }

        return $output;
}

sub do_vote
{
        my $self = shift;
        my $id = shift;

        FModel::Votes -> create( thread_id => $id, user_id => $self -> user() -> id() );

        return;
}

sub show_thread
{
        my $self = shift;
        my %params = @_;
        my $id = $self -> arg( 'id' )                                      || $params{ 'id' }        || 0;
        my $page = $self -> arg( 'page' )                                  || $params{ 'page' }      || 1;
        my $error_msg = $self -> check_if_proper_thread_id_provided( $id ) || $params{ 'error_msg' } || '';
        my $success_msg = $params{ 'success_msg' } || '';

        &ar( DYN_ID => $id ); 

        if( not $error_msg )
        {
                my $thread = FModel::Threads -> get( id => $id );

                &ar( DYN_TITLE => $thread -> title(),
                     DYN_CONTENT => $thread -> content(),
                     DYN_PINNED_IMAGE => $thread -> pinned_image_src(),
                     DYN_CREATED => $self -> readable_date( $thread -> created() ),
                     DYN_AUTHOR  => $thread -> user_id() -> name(),
                     DYN_VOTE          => $thread -> vote(),
                     DYN_VOTING_OPTIONS => $self -> get_voting_options_for_replace( $id ),
                     DYN_CAN_DELETE => $self -> can_do_action_with_thread( 'delete', $id ),
                     DYN_CAN_EDIT   => $self -> can_do_action_with_thread( 'edit', $id ),
                     DYN_AUTHOR_AVATAR => $thread -> user_id() -> get_avatar_src(),
                     DYN_AUTHOR_PERMISSIONS => $thread -> user_id() -> get_special_permission_title() );

                if( $thread -> modified() )
                {
                        &ar( DYN_MODIFIED => 1, DYN_MODIFIED_DATE => $self -> readable_date( $thread -> modified_date() ) ); # do smth with this. Maybe new method get_modified_date() in model
                }

                $self -> add_messages( $id, $page );

        }

        my $output = $self -> construct_page( middle_tpl => 'thread', error_msg => $error_msg, success_msg => $success_msg );

        return $output;
}

sub show_create_form
{
        my $self = shift;
        my %params = @_;

        my $error_msg = $params{ 'error_msg' } || '';

        my $title        = $self -> arg( 'title' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );
        my $vote         = $self -> arg( 'vote' ) || 0;

        $self -> add_voting_options_data();

        &ar( DYN_TITLE => $title, DYN_CONTENT => $content, DYN_PINNED_IMAGE => $pinned_image, DYN_VOTE => $vote ); # maybe do smth with pinned_image

        my $output = $self -> construct_page( middle_tpl => 'thread_create', error_msg => $error_msg );

        return $output;
}

sub show_edit_form
{
        my $self = shift;
        my %params = @_;

        my $id = $self -> arg( 'id' ) || $params{ 'id' } || 0;

        my $error_msg = $params{ 'error_msg' } || '';

        &ar( DYN_ID => $id ); 

        if( my $cant_show_form_msg = $self -> check_if_can_show_edit_form( $id ) )
        {
                $error_msg = $cant_show_form_msg;
                &ar( DYN_DONT_SHOW_THREAD_DATA => 1 );
        } else
        {
                my $thread = FModel::Threads -> get( id => $id );

                &ar( DYN_TITLE => $thread -> title(),
                     DYN_CONTENT => $thread -> content(),
                     DYN_PINNED_IMAGE => $thread -> pinned_image_src(),
                     DYN_VOTING_OPTIONS => $self -> get_voting_options( $id )
                     );

                $self -> add_voting_options_data();
        }

        my $output = $self -> construct_page( middle_tpl => 'thread_edit', error_msg => $error_msg );

        return $output;
}

sub check_if_can_show_edit_form
{
        my $self = shift;

        my $id = $self -> arg( 'id' ) || shift || 0;

        my $error_msg = '';

        if( my $id_error = $self -> check_if_proper_thread_id_provided( $id ) )
        {
                $error_msg = $id_error;
        }
        elsif( not $self -> can_do_action_with_thread( 'edit', $id ) )
        {
                $error_msg = 'CANNOT_EDIT_THREAD';
        }

        return $error_msg;
}

sub can_edit
{
        my $self = shift;

        my $id           = $self -> arg( 'id' ) || 0;
        my $title        = $self -> arg( 'title' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) );
        
        if( my $thread_id_error = $self -> check_if_proper_thread_id_provided( $id ) )
        {
                $error_msg = $thread_id_error;
        }
        if( not $self -> can_do_action_with_thread( 'edit', $id ) )
        {
                $error_msg = 'CANNOT_EDIT_THREAD';
        }
        elsif( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( not $self -> is_thread_title_length_acceptable( $title ) )
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

        my $id           = $self -> arg( 'id' ) || 0;
        my $title        = $self -> arg( 'title' ) || '';
        my $content      = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );

        my $dbh = LittleORM::Db -> get_write_dbh();
        $dbh -> begin_work();

        my $thread = FModel::Threads -> get( id => $id );

        $thread -> title( $title );
        $thread -> content( $content );

        $thread -> modified( 1 );
        my $now = $self -> now();
        $thread -> modified_date( $now );
        $thread -> updated( $now );

        $thread -> update();

        $self -> pin_image_to_thread( $id, $pinned_image );

        assert( $dbh -> commit() );

        return;
}

sub pin_image_to_thread
{
        my $self = shift;
        my $id = shift || 0;
        my $image = shift;

        my $success = 0;

        if( $image and ( not my $error = $self -> check_if_proper_thread_id_provided( $id ) ) )
        {
                my $thread = FModel::Threads -> get( id => $id );

                if( my $old_image_filename = $thread -> pinned_img() )
                {
                        unlink ForumConst -> pinned_images_dir_abs() . $old_image_filename;
                }

                my $filename = $self -> new_pinned_image_filename();
                my $filepath = ForumConst -> pinned_images_dir_abs() . $filename;

                cp( $image, $filepath );
                $thread -> pinned_img( $filename );
                $thread -> update();

                $success = 1;
        }

        return $success;
}

sub delete_thread
{
        my $self = shift;

        my $id = $self -> arg( 'id' ) || 0;

        if( not my $error = $self -> check_if_proper_thread_id_provided( $id ) )
        {
                my $thread = FModel::Threads -> get( id => $id );

                my @thread_messages = FModel::Messages -> get_many( thread_id => $id );

                foreach my $message ( @thread_messages )
                {
                        $message -> delete();

                        if( my $pinned_image = $message -> pinned_img() )
                        {
                                unlink ForumConst -> pinned_images_dir_abs() . $pinned_image;
                        }
                }

                if( my $pinned_image = $thread -> pinned_img() )
                {
                        unlink ForumConst -> pinned_images_dir_abs() . $pinned_image;
                }

                $thread -> delete();
        }

        return;
}

sub add_voting_options_data
{
        my $self = shift;
        my $vote = $self -> arg( 'vote' );

        my $options = [];

        if( $vote )
        {
                &ar( DYN_VOTE => $vote );
                
                my $vote_options = $self -> get_voting_options_from_args();

                for my $number ( sort keys $vote_options )
                {
                        my $option_hash = { DYN_NUMBER => $number, DYN_VALUE => $vote_options -> { $number } };
                        push( @$options, $option_hash );
                }
        }
        else
        {
                $options = [ { DYN_NUMBER => 1, DYN_VALUE => '' }, { DYN_NUMBER => 2, DYN_VALUE => '' } ];
        }
        
        &ar( DYN_OPTIONS => $options );
}

sub add_messages
{
        my $self = shift;
        my $id = shift;
        my $page = shift || 1;

        my @messages_sorted = sort { $a -> posted() cmp $b -> posted() } FModel::Messages -> get_many( thread_id => $id );
        my $messages = [];

        my $count_of_messages = scalar( @messages_sorted );
        my $messages_on_page = ForumConst -> messages_on_page();
        my $show_from = ( $page - 1 ) * $messages_on_page;
        my $show_to = $self -> min_of( $show_from + $messages_on_page, $count_of_messages );

        for( my $index = $show_from; $index < $show_to; $index++ )
        {
                my $message = $messages_sorted[ $index ];

                my $msg_hash = { DYN_MESSAGE_ID => $message -> id(),
                                 DYN_POSTED     => $self -> readable_date( $message -> posted() ),
                                 DYN_SUBJECT    => $message -> subject(),
                                 DYN_CONTENT    => $message -> content(),
                                 DYN_PINNED_IMAGE => $message -> pinned_image_src(),
                                 DYN_AUTHOR     => $message -> user_id() -> name(),
                                 DYN_CAN_DELETE => $self -> can_do_action_with_message( 'delete', $message -> id() ),
                                 DYN_CAN_EDIT   => $self -> can_do_action_with_message( 'edit', $message -> id() ),
                                 DYN_AUTHOR_AVATAR => $message -> user_id() -> get_avatar_src(),
                                 DYN_AUTHOR_PERMISSIONS => $message -> user_id() -> get_special_permission_title()
                                 };

                if( $message -> modified() )
                {
                        $msg_hash -> { 'DYN_MODIFIED' } = 1;
                        $msg_hash -> { 'DYN_MODIFIED_DATE' } = $self -> readable_date( $message -> modified_date() );
                }

                push( $messages, $msg_hash );
        }
         
        if( $count_of_messages > 0 )
        {
                &ar( DYN_MESSAGES => $messages,
                     DYN_PAGES => $self -> add_pages( $id, $page ) );
        }

        return $messages;
}

sub add_pages
{
        my $self = shift;
        my $id = shift;
        my $current_page = shift;

        my $count_of_messages = FModel::Messages -> count( thread_id => $id );
        my $messages_on_page = ForumConst -> messages_on_page();

        my $num_of_pages = int( abs( $count_of_messages - 1 ) / $messages_on_page ) + 1;

        my $pages = [];

        if( $num_of_pages > 1 )
        {
                for my $page ( 1 .. $num_of_pages )
                {
                        my $hash = { DYN_PAGE => $page };

                        if( $page == $current_page )
                        {
                                $hash -> { 'DYN_CURRENT' } = 1;
                        }

                        push( @$pages, $hash );
                }
        }

        &ar( DYN_THREAD_ID => $id, DYN_PAGES => $pages );

        return &tt( 'pages' );
}

sub can_create
{
        my $self = shift;

        my $title = $self -> arg( 'title' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );
        my $vote = $self -> arg( 'vote' ) || 0;

        my $error_msg = '';

        my $vote_options_correctly_filled = ( not $vote or ( $vote and $self -> vote_options_filled() ) );

        my $fields_are_filled = ( $self -> trim( $title ) and $self -> trim( $content ) and $vote_options_correctly_filled );

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        elsif( not $self -> is_thread_title_length_acceptable( $title ) ) 
        {
                $error_msg = 'THREAD_TITLE_TOO_LONG';
        }
        elsif( my $pinned_image_error = $self -> check_pinned_image( $pinned_image ) )
        {
                $error_msg = $pinned_image_error;
        }

        return $error_msg;
}

sub vote_options_filled
{
        my $self = shift;

        my $vote_options = $self -> get_voting_options_from_args();

        my $filled;

        if( scalar $vote_options )
        {
                $filled = 1;

                for my $option ( keys $vote_options )
                {
                        if( $self -> trim( $vote_options -> { $option } ) eq '' )
                        {
                                $filled = 0;
                        }
                }
        }

        return $filled;
}

sub is_thread_title_length_acceptable
{
        my $self = shift;
        my $title = shift;
        
        my $acceptable = 1;

        if( length( $title ) > ForumConst -> thread_title_max_length() )
        {
                $acceptable = 0;
        }

        return $acceptable;
}

sub create
{
        my $self = shift;

        my $title = $self -> arg( 'title' ) || '';
        my $content = $self -> arg( 'content' ) || '';
        my $pinned_image = $self -> upload( 'pinned_image' );
        my $vote = $self -> arg( 'vote' ) || 0;

        my $dbh = LittleORM::Db -> get_write_dbh();
        $dbh -> begin_work();

        my $user = FModel::Users -> get( name => $self -> user() -> name() );

        my $new_thread = FModel::Threads -> create( title => $title, content => $content, user_id => $user -> id(), created => $self -> now(), updated => $self -> now(), vote => $vote );

        if( $vote )
        {
                my $vote_options = $self -> get_voting_options_from_args();
                for my $number ( sort keys $vote_options )
                {
                        FModel::VotingOptions -> create( thread_id => $new_thread -> id(), title => $vote_options -> { $number } );
                }
        }
        
        $self -> pin_image_to_thread( $new_thread -> id(), $pinned_image );

        assert( $dbh -> commit() );

        return $new_thread -> id();
}

sub get_voting_options_from_args
{
        my $self = shift;

        my $options = {};

        for my $arg ( keys $self -> args() )
        {
                if( $arg =~ m/^option\d+$/ )
                {
                        my ( $number ) = $arg =~ /(\d+)/;
                        $options -> { $number } = $self -> trim( $self -> arg( $arg ) );
                }
        }

        return $options;
}


1;
