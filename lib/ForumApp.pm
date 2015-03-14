use strict;

package ForumApp;

use LittleORM::Db 'init', 'get_write_dbh';
use FModel::Users;
use FModel::Sessions;
use FModel::Messages;
use FModel::Threads;
use FModel::Permissions;
use FModel::VotingOptions;
use FModel::Votes;
use Wendy::Templates::TT 'tt';
use Wendy::Db qw( dbconnect );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use Wendy::Config 'CONF_MYPATH';
use File::Type;
use ForumConst 'proper_image_filetypes';
use File::Copy 'cp';
use Carp::Assert 'assert';
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

        if( $self -> user() )
        {
                &ar( DYN_CURRENT_USER => $self -> user() -> name() );
                if( $self -> can_use_adminka() )
                {
                        &ar( DYN_CAN_USE_ADMINKA => $self -> user() -> name() );
                }
        }

        if( $restricted_msg )
        {
                &ar( DYN_RESTRICTED_MSG => &gr( $restricted_msg ) );
                $middle = &tt( 'restricted' );
        } else
        {
                assert( $middle_tpl );

                if( $error_msg )
                {
                        &ar( DYN_ERROR_MSG => &gr( $error_msg ) );
                }
                
                if( $success_msg )
                {
                        &ar( DYN_SUCCESS_MSG => &gr( $success_msg ) );
                }

                $middle = &tt( $middle_tpl );
        }

        my $header = &tt( 'header' );
        my $footer = &tt( 'footer' );

        &ar( DYN_HEADER => $header, DYN_MIDDLE => $middle, DYN_FOOTER => $footer );

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

        return( lc( $email ) =~ /.+@.+\..+/i );
}

sub is_email_exists
{
        my ( $self, $email ) = @_;

        my $exists = 0;

        if( $self -> is_email_valid( $email ) )
        {
                $exists = FModel::Users -> count( email => lc( $email ) );
        }

        return( $exists );
}

sub is_username_valid
{
        my ( $self, $username ) = @_;

        return( lc( $username ) =~ /^[a-z0-9_-]{3,16}$/ ); # TODO add constants for username length bounds
}

sub is_password_valid
{
        my ( $self, $password ) = @_;

        return( length( $password ) >= 3 ); # TODO add constant for password length bounds
}

sub is_user_exists
{
        my ( $self, $user_id ) = @_;

        my $exists = 0;

        $exists = FModel::Users -> count( id => $user_id );

        return( $exists );
}

sub is_username_exists
{
        my ( $self, $username ) = @_;

        my $exists = 0;

        if( $self -> is_username_valid( $username ) )
        {
                $exists = FModel::Users -> count( name => lc( $username ) );
        }

        return( $exists );
}

sub set_cookie
{
	my $self = shift;

	my %args = @_;

	{
                $args{ '-domain' } = undef;
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

sub is_voting_option_exists
{
        my ( $self, $option_id ) = @_;

        my $exists = 0;

        if( $option_id )
        {
                $exists = FModel::VotingOptions -> count( id => $option_id );
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
                $belongs = ( $self -> user() -> id() eq $message -> author() -> id() );
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
                $belongs = ( $self -> user() -> id() eq $thread -> author() -> id() );
        }

        return $belongs;
}

sub can_do_action_with_message
{
        my ( $self, $action, $message_id ) = @_;

        assert( $action eq 'delete' or $action eq 'edit' );

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

                my $message_author_permission = $message -> author() -> permission() -> id();

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

        assert( $action eq 'delete' or $action eq 'edit' or $action eq 'vote' );

        if( $action eq 'vote' and $self -> user() )
        {
                return 1;
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

                my $thread_author_permission = $thread -> author() -> permission() -> id();

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

        assert( $action eq 'ban' or $action eq 'unban' );

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

sub can_vote
{
        my $self = shift;

        my $can_vote = 0;

        if( $self -> user() )
        {
                $can_vote = $self -> user() -> permission() -> vote();
        }

        return $can_vote;
}

sub can_use_adminka
{
        my $self = shift;

        my $can_use = 0;

        if( $self -> user() )
        {
                $can_use = $self -> user() -> permission() -> use_adminka();
        }

        return $can_use;
}

sub check_if_proper_user_id_provided
{
        my ( $self, $user_id ) = @_;

        my $error = '';

        if( not $user_id )
        {
                $error = 'NO_USER_ID';
        }
        elsif( not &Funcs::is_id_field_value_valid( $user_id ) )
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
        elsif( not &Funcs::is_id_field_value_valid( $thread_id ) )
        {
                $error = 'INVALID_THREAD_ID';
        }
        elsif( not $self -> is_thread_exists( $thread_id ) )
        {
                $error = 'NO_SUCH_THREAD';
        }

        return $error;
}

sub check_if_proper_voting_option_id_provided
{
        my ( $self, $option_id ) = @_;

        my $error = '';

        if( not $option_id )
        {
                $error = 'NO_VOTING_OPTION_ID';
        }
        elsif( not &Funcs::is_id_field_value_valid( $option_id ) )
        {
                $error = 'INVALID_VOTING_OPTION_ID';
        }
        elsif( not $self -> is_voting_option_exists( $option_id ) )
        {
                $error = 'NO_SUCH_VOTING_OPTION';
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
        elsif( not &Funcs::is_id_field_value_valid( $message_id ) )
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

sub get_voting_options_for_replace
{
        my ( $self, $thread_id ) = @_;

        my $thread = FModel::Threads -> get( id => $thread_id );

        my @voting_options = map {
                                   { DYN_ID           => $_ -> id(),
                                     DYN_TITLE        => $_ -> title(),
                                     DYN_NUM_OF_VOTES => $_ -> num_of_votes(),
                                     DYN_PERCENTAGE   => int( $_ -> percentage() ),
                                     DYN_USERS_CHOICE => ( $self -> user() and $_ -> did_certain_user_voted_for_this_option( $self -> user() ) ) }; 
                                 } $thread -> voting_options();

        return \@voting_options;
}


1;
