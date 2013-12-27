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
use DateTime;
use Wendy::Config 'CONF_MYPATH';
use Scalar::Util 'looks_like_number';
use ForumConst qw( session_expires_after avatars_dir_url pinned_images_dir_url );

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

        &lm( 'ANY');
        &lm();

        return $rv;
}

sub construct_page
{
        my $self = shift;
        my %args = @_;
        my $middle_tpl = $args{ 'middle_tpl' } || '';
        my $error_msg = $args{ 'error_msg' } || '';
        my $success_msg = $args{ 'success_msg' } || '';
        my $restricted_msg = $args{ 'restricted_msg' } || '';

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

        my $header = &tt( 'header' );
        my $footer = &tt( 'footer' );
        my $middle = '';

        if( $restricted_msg )
        {
                &ar( RESTRICTED_MSG => &gr( $restricted_msg ) );
                $middle = &tt( 'restricted' );
        } else
        {
                $middle = &tt( $middle_tpl );
        }

        &ar( HEADER => $header, MIDDLE => $middle, FOOTER => $footer );

        return $self -> ncd( &tt( 'carcass' ) );
}

sub init_user
{
        my $self = shift;
        my $session_key = $self -> get_cookie( 'session_key' ) || '';

        my $session = FModel::Sessions -> get( session_key => $session_key );

        my $user;

        if( $session )
        {
                my $expired = 0;
                if( $self -> now() gt $session -> expires() )
                {
                        $expired = 1;
                }

                if( $expired )
                {
                        $session -> delete( session_key => $session_key );
                } else
                {
                        $user = FModel::Users -> get( id => $session -> user_id() -> id() );
                        $session -> expires( $self -> session_expires() );
                        $session -> update();
                }
        }

        $self -> user( $user );

        return $user;
}

sub log_user_in
{
        my $self = shift;
        my $username = shift;

        my $session_key = $self -> new_session_key();

        my $user = FModel::Users -> get( name => $username );
        FModel::Sessions -> create( user_id => $user -> id(), expires => $self -> session_expires(), session_key => $session_key );

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

sub now
{
        my $self = shift;

        return DateTime -> now( time_zone => 'local' );
}

sub session_expires
{
        my $self = shift;

        return DateTime -> from_epoch( epoch => time() + ForumConst -> session_expires_after(), time_zone => 'local' );
}

sub readable_date
{
        my $self = shift;
	my $date = shift;

	my ( $part1, $part2 ) = split ( 'T', $date );
	my ( $year, $month, $day ) = split ( '-', $part1 );
	my ( $time, $milliseconds ) = split ( /\./, $part2 );

	return ( $day . '.' . $month . '.' . $year . ' ' . $time );
}

sub is_user_banned
{
        my $self = shift;
        my $user_id = shift;

        my $banned = 0;

        if( not my $error_msg = $self -> check_if_proper_user_id_provided( $user_id ) )
        {
                my $user = FModel::Users -> get( id => $user_id );
                $banned = $user -> banned();
        }

        return $banned;
}

sub is_email_valid
{
        my $self = shift;
        my $email = shift;
        $email = lc( $email );

        return( $email =~ /.+@.+\..+/i );
}

sub is_email_exists
{
        my $self = shift;
        my $email = shift;

        my $exists = 0;

        if( $self -> is_email_valid( $email ) )
        {
                $email = lc( $email );
                $exists = FModel::Users -> count( email => $email );
        }

        return( $exists );
}

sub is_email_exists_except_user
{
        my $self = shift;
        my $email = shift;
        my $username = shift;

        my $exists = 0;

        if( $self -> is_email_valid( $email ) )
        {
                $email = lc( $email );
                $exists = FModel::Users -> count( email => $email, name => { '!=', $username } );
        }

        return( $exists );
}

sub is_username_valid
{
        my $self = shift;
        my $username = shift;
        $username = lc( $username );

        return( $username =~ /^[a-z0-9_-]{3,16}$/ );
}

sub is_user_exists
{
        my $self = shift;
        my $user_id = shift || 0;

        my $exists = 0;

        if( looks_like_number( $user_id ) )
        {
                $exists = FModel::Users -> count( id => $user_id );
        }

        return( $exists );
}

sub is_username_exists
{
        my $self = shift;
        my $username = shift || '';

        my $exists = 0;

        if( $self -> is_username_valid( $username ) )
        {
                $username = lc( $username );
                $exists = FModel::Users -> count( name => $username );
        }

        return( $exists );
}

sub new_session_key
{
        my $self = shift;

        my $key = Digest::MD5::md5_base64( rand() );

        return $key;
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

sub trim
{
        my $self = shift;
        my $str = shift;

        if( $str )
        {
                $str =~ s/^\s+|\s+$//g;
        }

        return $str;
}

sub is_thread_exists
{
        my $self = shift;
        my $thread_id = shift || '';

        my $exists = 0;

        if( $thread_id )
        {
                $exists = FModel::Threads -> count( id => $thread_id );
        }

        return $exists;
}

sub is_message_exists
{
        my $self = shift;
        my $message_id = shift || '';

        my $exists = 0;

        if( $message_id )
        {
                $exists = FModel::Messages -> count( id => $message_id );
        }

        return $exists;
}

sub is_message_belongs_to_current_user
{
        my $self = shift;
        my $message_id = shift;

        my $belongs = 0;

        if( $self -> user() )
        {
                my $message = FModel::Messages -> get( id => $message_id );
                $belongs = ( $self -> user() -> id() eq $message -> user_id() -> id() );
        }

        return $belongs;
}

sub is_thread_belongs_to_current_user
{
        my $self = shift;
        my $thread_id = shift;

        my $belongs = 0;

        if( $self -> user() )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                $belongs = ( $self -> user() -> id() eq $thread -> user_id() -> id() );
        }

        return $belongs;
}

sub get_user_avatar_src
{
        my $self = shift;
        my $user_id = shift;

        my $user = FModel::Users -> get( id => $user_id );

        my $avatar_src = ForumConst-> avatars_dir_url();

        if( $user -> avatar() )
        {
                $avatar_src .= $user -> avatar();
        } else
        {
                $avatar_src .= 'default'; 
        }

        return $avatar_src;
}

sub get_thread_pinned_image_src
{
        my $self = shift;
        my $thread_id = shift;

        my $thread = FModel::Threads -> get( id => $thread_id );

        my $image_src;

        if( $thread -> pinned_img() )
        {
                $image_src = ForumConst -> pinned_images_dir_url() . $thread -> pinned_img();
        }

        return $image_src;
}

sub get_message_pinned_image_src
{
        my $self = shift;
        my $message_id = shift;

        my $message = FModel::Messages -> get( id => $message_id );

        my $image_src;

        if( $message -> pinned_img() )
        {
                $image_src = ForumConst -> pinned_images_dir_url() . $message -> pinned_img();
        }

        return $image_src;
}

sub can_do_action_with_message
{
        my $self = shift;
        my $action = shift || '';
        my $message_id = shift || 0;

        my $can = 0;

        my $error = ( ( not $self -> user() ) or $self -> check_if_proper_message_id_provided( $message_id ) );

        if( not $error and $self -> is_message_belongs_to_current_user( $message_id ) )
        {
                if( ( $action eq 'delete' and $self -> user() -> permission_id() -> delete_messages() ) or
                    ( $action eq 'edit' and $self -> user() -> permission_id() -> edit_messages() ) )
                {
                        $can = 1;
                }
        }
        elsif( not $error and ( not $self -> is_message_belongs_to_current_user( $message_id ) ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );

                my $message_author_permission = $message -> user_id() -> permission_id() -> id();

                if( $action eq 'delete' )
                {
                        for my $permission ( $self -> user() -> permission_id() -> can_delete_messages_of() );
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
                        for my $permission ( $self -> user() -> permission_id() -> can_edit_messages_of() );
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
        my $self = shift;
        my $action = shift || '';
        my $thread_id = shift || 0;

        my $can = 0;
        
        my $error = ( ( not $self -> user() ) or $self -> check_if_proper_thread_id_provided( $thread_id ) );

        if( not $error and $self -> is_thread_belongs_to_current_user( $thread_id ) )
        {
                if( ( $action eq 'delete' and $self -> user() -> permission_id() -> delete_threads() ) or
                    ( $action eq 'edit' and $self -> user() -> permission_id() -> edit_threads() ) )
                {
                        $can = 1;
                }
        }
        elsif( not $error and ( not $self -> is_thread_belongs_to_current_user( $thread_id ) ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );

                my $thread_author_permission = $thread -> user_id() -> permission_id() -> id();

                if( $action eq 'delete' )
                {
                        for my $permission ( $self -> user() -> permission_id() -> can_delete_threads_of() );
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
                        for my $permission ( $self -> user() -> permission_id() -> can_edit_threads_of() );
                        {
                                if( $permission eq $thread_author_permission )
                                {
                                        $self -> can_delete_thread_messages();
                                        $can = 1;
                                        last;
                                }
                        }
                }
        }

        if( not $error and $can and $action eq 'delete' )
        {
                my @messages = FModel::Messages -> get_many( thread_id => $thread_id );

                foreach my $message ( @messages )
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
        my $self = shift;
        my $action = shift || '';
        my $user_id = shift || 0;

        my $can = 0;
        
        my $error = ( ( not $self -> user() ) or $self -> check_if_proper_user_id_provided( $user_id ) );

        if( not $error )
        {
                my $cur_user = FModel::Users -> get( id => $self -> user() -> id() );
                my $permissions = FModel::Permissions -> get( id => $cur_user -> permissions_id() );

                my $user_to_act = FModel::Users -> get( id => $user_id );
                my $user_to_act_permissions = FModel::Permissions -> get( id => $user_to_act -> permissions_id() );
                my $user_to_act_permissions_title = $user_to_act_permissions -> title();

                if( $action eq 'ban' or $action eq 'unban' )
                {
                        my $can_do_action_with_users = $permissions -> ban_users();

                        for my $title ( split( ', ', $can_do_action_with_users ) )
                        {
                                if( $user_to_act_permissions_title eq $title ) 
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
        my $self = shift;
        my $user_id = shift || '';

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
        my $self = shift;
        my $thread_id = shift || '';

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
        my $self = shift;
        my $message_id = shift || '';

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

sub get_user_permissions
{
        my $self = shift;
        my $user_id = shift;

        my $rv = '';

        if( not my $error = $self -> check_if_proper_user_id_provided( $user_id ) )
        {
                my $user = FModel::Users -> get( id => $user_id );
                my $permissions = FModel::Permissions -> get( id => $user -> permissions_id() );
                $rv = $permissions -> title();
        }

        return $rv;
}

sub get_user_special_permissions
{
        my $self = shift;
        my $user_id = shift;

        my $special_permissions = '';

        my $user_perm = $self -> get_user_permissions( $user_id );

        if( $user_perm ne 'regular' )
        {
                $special_permissions = $user_perm;
        }

        return $special_permissions;
}

sub max_of
{
        my $self = shift;
        my @numbers = @_;

        my $max = $numbers[0];

        for my $num ( @numbers )
        {
                if( $num > $max )
                {
                        $max = $num;
                }
        }

        return $max;
}

sub min_of
{
        my $self = shift;
        my @numbers = @_;

        my $min = $numbers[0];

        for my $num ( @numbers )
        {
                if( $num < $min )
                {
                        $min = $num;
                }
        }

        return $min;
}

sub check_pinned_image
{
        my $self = shift;
        my $image = shift || '';

        my $error_msg = '';

        my $filesize = -s $image;

        if( $image and CGI::uploadInfo( $image ) -> { 'Content-Type' } ne 'image/jpeg' ) # New function for this thing that uses special modules for filetype check
        {
                $error_msg = 'PINNED_IMAGE_INCORRECT_FILETYPE';
        }
        elsif( $image and $filesize > ForumConst -> pinned_image_max_filesize() )
        {
                $error_msg = 'PINNED_IMAGE_FILESIZE_TOO_BIG';
        }

        return $error_msg;
}

sub update_thread
{
        my $self = shift;
        my $id = shift;

        my $success = 0;

        if( not my $error = $self -> check_if_proper_thread_id_provided( $id ) )
        {
                my $thread = FModel::Threads -> get( id => $id );
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

        if( -e ForumConst -> pinned_images_dir_abs() . $filename )
        {
                $exists = 1;
        }

        return $exists;
}

sub get_voting_options
{
        my $self = shift;
        my $id = shift;

        my $rv = [];

        my @options = FModel::VotingOptions -> get_many( thread_id => $id, _sortby => 'id' );

        for my $option ( @options )
        {
                my $hash = { DYN_ID => $option -> id(), DYN_TITLE => $option -> title() };
                push( @$rv, $hash );
                
        }

        return $rv;
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
