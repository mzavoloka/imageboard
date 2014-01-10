use strict;

package ForumApp;

use LittleORM::Db 'init', 'get_write_dbh';
use FModel::Users;
use FModel::Sessions;
use FModel::Messages;
use FModel::Threads;
use FModel::Permissions;
use FModel::VotingOptions;
use Wendy::Templates::TT 'tt';
use Wendy::Db qw( dbconnect );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use Wendy::Config 'CONF_MYPATH';
use Scalar::Util 'looks_like_number';
use File::Type;
use ForumConst 'proper_image_filetypes';
use File::Copy 'cp';
use Carp::Assert 'assert';
use Carp 'croak';
use Funcs;
use File::Spec;

use Moose;
extends 'Wendy::App';

has 'user' => ( is => 'rw', isa => 'Maybe[FModel::Users]' );

sub init
{
        my $self = shift;

        my $rv = '';
        LittleORM::Db -> init( &dbconnect() );

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        } else
        {
                $self -> init_user();
        }

        &lm( 'ANY' );
        &lm();

        return $rv;
}

sub construct_page
{
        my ( $self, %params ) = @_;
        my ( $middle_tpl, $error_msg, $success_msg, $restricted_msg ) = @params{ 'middle_tpl', 'error_msg', 'success_msg', 'restricted_msg' };

        my $middle = '';

        if( $restricted_msg )
        {
                &ar( RESTRICTED_MSG => &gr( $restricted_msg ) );
                $middle = &tt( 'restricted' );
        } else
        {
                assert( $middle_tpl );

                if( $self -> user() )
                {
                        &ar( CURRENT_USER => $self -> user() -> name() );
                }

                if( $error_msg )
                {
                        &ar( ERROR_MSG => &gr( $error_msg ) );
                }
                
                if( $success_msg )
                {
                        &ar( SUCCESS_MSG => &gr( $success_msg ) );
                }

                $middle = &tt( $middle_tpl );
        }

        my $header = &tt( 'header' );
        my $footer = &tt( 'footer' );

        &ar( HEADER => $header, MIDDLE => $middle, FOOTER => $footer );

        return $self -> ncd( &tt( 'carcass' ) );
}

sub init_user
{
        my $self = shift;
        my $session_key = $self -> get_cookie( 'session_key' );

        my $session = FModel::Sessions -> get( session_key => $session_key );

        my $user;

        if( $session )
        {
                my $expired = 0;
                if( Funcs::now() gt $session -> expires() )
                {
                        $expired = 1;
                }

                if( $expired )
                {
                        $session -> delete( session_key => $session_key );
                } else
                {
                        $user = FModel::Users -> get( id => $session -> user() -> id() );
                        $session -> expires( FModel::Sessions -> session_expires() );
                        $session -> update();
                }
        }

        $self -> user( $user );

        return $user;
}

sub log_user_in
{
        my ( $self, $username ) = @_;

        my $session_key = FModel::Sessions -> new_session_key();

        my $user = FModel::Users -> get( name => $username );

        assert( FModel::Sessions -> create( user => $user, expires => FModel::Sessions -> session_expires(), session_key => $session_key ) );

        $self -> set_cookie( '-name' => 'session_key', '-value' => $session_key );

        $self -> user( $user );

        return $session_key;
}

sub log_user_out
{
        my $self = shift;
        my $session_key = $self -> get_cookie( 'session_key' );

        FModel::Sessions -> delete( session_key => $session_key );

        $self -> set_cookie( '-name' => 'session_key', '-value' => '' );

        return;
}

sub is_email_valid
{
        my ( $self, $email ) = @_;
        $email = lc( $email );

        return( $email =~ /.+@.+\..+/i );
}

sub is_email_exists
{
        my ( $self, $email ) = @_;

        my $exists = 0;

        if( $self -> is_email_valid( $email ) )
        {
                $email = lc( $email );
                $exists = FModel::Users -> count( email => $email );
        }

        return( $exists );
}

sub is_username_valid
{
        my ( $self, $username ) = @_;
        $username = lc( $username );

        return( $username =~ /^[a-z0-9_-]{3,16}$/ );
}

sub is_user_exists
{
        my ( $self, $user_id ) = @_;

        my $exists = 0;

        if( looks_like_number( $user_id ) )
        {
                $exists = FModel::Users -> count( id => $user_id );
        }

        return( $exists );
}

sub is_username_exists
{
        my ( $self, $username ) = @_;

        my $exists = 0;

        if( $self -> is_username_valid( $username ) )
        {
                $username = lc( $username );
                $exists = FModel::Users -> count( name => $username );
        }

        return( $exists );
}

sub set_cookie
{
	my $self = shift;

	my %args = @_;

	{
		$args{ '-domain' } = '192.168.9.24';
		$args{ '-expires' } ||= '+1d';
	}

	my $cookie = CGI::Cookie -> new( %args );

	push( @{ $self -> out_cookies() }, $cookie );
}

sub is_thread_exists
{
        my ( $self, $thread_id ) = @_;

        my $exists = 0;

        if( $thread_id )
        {
                $exists = FModel::Threads -> count( id => $thread_id );
        }

        return $exists;
}

sub is_message_exists
{
        my ( $self, $message_id ) = @_;

        my $exists = 0;

        if( $message_id )
        {
                $exists = FModel::Messages -> count( id => $message_id );
        }

        return $exists;
}

sub is_message_belongs_to_current_user
{
        my ( $self, $message_id ) = @_;

        my $belongs = 0;

        if( $self -> user() )
        {
                my $message = FModel::Messages -> get( id => $message_id );
                $belongs = ( $self -> user() -> id() eq $message -> user() -> id() );
        }

        return $belongs;
}

sub is_thread_belongs_to_current_user
{
        my ( $self, $thread_id ) = @_;

        my $belongs = 0;

        if( $self -> user() )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                $belongs = ( $self -> user() -> id() eq $thread -> user() -> id() );
        }

        return $belongs;
}

sub can_do_action_with_message
{
        my ( $self, $action, $message_id ) = @_;

        if( $action ne 'delete' and $action ne 'edit' )
        {
                croak 'You wrongly defined, which action that you intend to do with message needs to be checked';
        }

        my $can = 0;

        my $error = ( ( not $self -> user() ) or $self -> check_if_proper_message_id_provided( $message_id ) );

        if( not $error and $self -> is_message_belongs_to_current_user( $message_id ) )
        {
                if( ( $action eq 'delete' and $self -> user() -> permission() -> delete_messages() ) or
                    ( $action eq 'edit' and $self -> user() -> permission() -> edit_messages() ) )
                {
                        $can = 1;
                }
        }
        elsif( not $error and ( not $self -> is_message_belongs_to_current_user( $message_id ) ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                my $message_author_permission = $message -> user() -> permission() -> id();

                if( $action eq 'delete' )
                {
                        for my $permission ( $self -> user() -> permission() -> can_delete_messages_of() )
                        {
                                if( $permission eq $message_author_permission )
                                {
                                        $can = 1;
                                        last;
                                }
                        }
                }
                elsif( $action eq 'edit' )
                {
                        for my $permission ( $self -> user() -> permission() -> can_edit_messages_of() )
                        {
                                if( $permission eq $message_author_permission )
                                {
                                        $can = 1;
                                        last;
                                }
                        }
                }
        }

        return $can;
}



sub can_do_action_with_thread
{
        my ( $self, $action, $thread_id ) = @_;

        if( $action ne 'delete' and $action ne 'edit' )
        {
                croak 'You wrongly defined, which action that you intend to do with thread needs to be checked';
        }

        my $can = 0;
        
        my $error = ( ( not $self -> user() ) or $self -> check_if_proper_thread_id_provided( $thread_id ) );

        if( not $error and $self -> is_thread_belongs_to_current_user( $thread_id ) )
        {
                if( ( $action eq 'delete' and $self -> user() -> permission() -> delete_threads() ) or
                    ( $action eq 'edit' and $self -> user() -> permission() -> edit_threads() ) )
                {
                        $can = 1;
                }
        }
        elsif( not $error and ( not $self -> is_thread_belongs_to_current_user( $thread_id ) ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                my $thread_author_permission = $thread -> user() -> permission() -> id();

                if( $action eq 'delete' )
                {
                        for my $permission ( $self -> user() -> permission() -> can_delete_threads_of() )
                        {
                                if( $permission eq $thread_author_permission )
                                {
                                        $can = 1;
                                        last;
                                }
                        }
                }
                elsif( $action eq 'edit' )
                {
                        for my $permission ( $self -> user() -> permission() -> can_edit_threads_of() )
                        {
                                if( $permission eq $thread_author_permission )
                                {
                                        $can = 1;
                                        last;
                                }
                        }
                }
        }

        if( not $error and $can and $action eq 'delete' )
        {
                my @messages = FModel::Messages -> get_many( thread => $thread_id );

                for my $message ( @messages )
                {
                        if( not $self -> can_do_action_with_message( 'delete', $message -> id() ) )
                        {
                                $can = 0;
                                last;
                        }
                }
        }

        return $can;
}

sub can_do_action_with_user
{
        my ( $self, $action, $user_id ) = @_;

        if( $action ne 'ban' and $action ne 'unban' )
        {
                croak 'You wrongly defined, which action that you intend to do with user needs to be checked';
        }

        my $can = 0;
        
        my $error = ( ( not $self -> user() ) or $self -> check_if_proper_user_id_provided( $user_id ) );

        if( not $error )
        {
                my $user_to_act = FModel::Users -> get( id => $user_id );
                my $user_to_act_permission = $user_to_act -> permission() -> id();

                if( $action eq 'ban' or $action eq 'unban' )
                {
                        for my $permission ( $self -> user() -> permission() -> can_ban_users_of() )
                        {
                                if( $permission eq $user_to_act_permission )
                                {
                                        $can = 1;
                                        last;
                                }
                        }
                }
        }

        return $can;
}

sub check_if_proper_user_id_provided
{
        my ( $self, $user_id ) = @_;

        my $error = '';

        if( not $user_id )
        {
                $error = 'NO_USER_ID';
        }
        elsif( not looks_like_number( $user_id ) )
        {
                $error = 'INVALID_USER_ID';
        }
        elsif( not $self -> is_user_exists( $user_id ) )
        {
                $error = 'NO_SUCH_USER';
        }

        return $error;
}

sub check_if_proper_thread_id_provided
{
        my ( $self, $thread_id ) = @_;

        my $error = '';

        if( not $thread_id )
        {
                $error = 'NO_THREAD_ID';
        }
        elsif( not looks_like_number( $thread_id ) )
        {
                $error = 'INVALID_THREAD_ID';
        }
        elsif( not $self -> is_thread_exists( $thread_id ) )
        {
                $error = 'NO_SUCH_THREAD';
        }

        return $error;
}

sub check_if_proper_message_id_provided
{
        my ( $self, $message_id ) = @_;

        my $error = '';

        if( not $message_id )
        {
                $error = 'NO_MESSAGE_ID';
        }
        elsif( not looks_like_number( $message_id ) )
        {
                $error = 'INVALID_MESSAGE_ID';
        }
        elsif( not $self -> is_message_exists( $message_id ) )
        {
                $error = 'NO_SUCH_MESSAGE';
        }

        return $error;
}

sub check_pinned_image
{
        my ( $self, $image ) = @_;

        my $error_msg = '';

        my $filesize = -s $image;

        if( $image and not $self -> is_image_has_proper_filetype( $image ) )
        {
                $error_msg = 'PINNED_IMAGE_INCORRECT_FILETYPE';
        }
        elsif( $image and $filesize > ForumConst -> pinned_image_max_filesize() )
        {
                $error_msg = 'PINNED_IMAGE_FILESIZE_TOO_BIG';
        }

        return $error_msg;
}

sub is_image_has_proper_filetype
{
        my ( $self, $image ) = @_;

        my $proper = 0;

        my $tmp_image_filepath = CGI -> new() -> tmpFileName( $image );

        use File::MimeInfo::Magic;
        my $filetype = &File::MimeInfo::Magic::magic( $tmp_image_filepath );

        for my $proper_filetype ( @{ ForumConst -> proper_image_filetypes() } )
        {
                if( 'image/' . $proper_filetype eq $filetype )
                {
                        $proper = 1;
                        last;
                }
        }

        return $proper;
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
        my ( $self, $filename ) = @_;

        my $exists = 0;

        if( -e File::Spec -> catfile( ForumConst -> pinned_images_dir_abs(), $filename ) )
        {
                $exists = 1;
        }

        return $exists;
}

sub get_voting_options_for_replace()
{
        my ( $self, $thread_id ) = @_;

        my $thread = FModel::Threads -> get( id => $thread_id );

        my @voting_options = map {
                                   { DYN_ID => $_ -> id(),
                                     DYN_TITLE => $_ -> title() };
                                 } $thread -> voting_options();

        return \@voting_options;
}


1;
