use strict;

package ForumApp;

use LittleORM::Db 'init';
use FModel::Users;
use FModel::Sessions;
use FModel::Messages;
use FModel::Threads;
use FModel::Permissions;
use Wendy::Templates::TT 'tt';
use Wendy::Db qw( dbconnect );
use Data::Dumper 'Dumper';
use Wendy::Shorts qw( ar gr lm );
use Digest::MD5 'md5_base64';
use DateTime;
use Wendy::Config 'CONF_MYPATH';
use Scalar::Util 'looks_like_number';

use Moose;
extends 'Wendy::App';

has 'user' => ( is => 'rw', isa => 'Str' );
has 'user_id' => ( is => 'rw', isa => 'Int' );
has 'session_expires_after' => ( is => 'rw', isa => 'Int', default => 900 );
has 'avatars_dir_abs' => ( is => 'rw', isa => 'Str', default => CONF_MYPATH . '/var/hosts/localhost/htdocs/static/img/avatars/' );
has 'avatars_dir_url' => ( is => 'rw', isa => 'Str', default => '/static/img/avatars/' );

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

        &lm();

        return $rv;
}

sub cleanup
{
        my $self = shift;
}

sub construct_page
{
        my $self = shift;
        my %args = @_;
        my $middle_tpl = $args{ 'middle_tpl' } || '';
        my $error_msg = $args{ 'error_msg' } || '';
        my $success_msg = $args{ 'success_msg' } || '';
        my $restricted_msg = $args{ 'restricted_msg' } || '';

        &ar( CURRENT_USER => $self -> user() );

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

        my $rv = 0;
        
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
                        $session -> expires( $self -> session_expires() );
                        $rv = $self -> user( $session -> user_id() -> name() );
                        $self -> user_id( $session -> user_id() -> id() );
                        $session -> update();
                }
        }

        return $rv;
}

sub log_user_in
{
        my $self = shift;
        my $username = shift;

        my $session_key = $self -> new_session_key();

        my $user = FModel::Users -> get( name => $username );
        FModel::Sessions -> create( user_id => $user -> id(), expires => $self -> session_expires(), session_key => $session_key );

        $self -> set_cookie( '-name' => 'session_key', '-value' => $session_key );

        $self -> user( $username );
        $self -> user_id( $user -> id() );

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

        return DateTime -> from_epoch( epoch => time() + $self -> session_expires_after(), time_zone => 'local' );
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

        if( $self -> user_id() )
        {
                my $message = FModel::Messages -> get( id => $message_id );
                $belongs = ( $self -> user_id() eq $message -> user_id() -> id() );
        }

        return $belongs;
}

sub is_thread_belongs_to_current_user
{
        my $self = shift;
        my $thread_id = shift;

        my $belongs = 0;

        if( $self -> user_id() )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                $belongs = ( $self -> user_id() eq $thread -> user_id() -> id() );
        }

        return $belongs;
}

sub get_user_avatar_src
{
        my $self = shift;
        my $user_id = shift;

        my $user = FModel::Users -> get( id => $user_id );

        my $avatar_src = $self -> avatars_dir_url();

        if( $user -> avatar() )
        {
                $avatar_src .= $user -> avatar();
        } else
        {
                $avatar_src .= 'default'; 
        }

        return $avatar_src;
}

sub can_do_action_with_message
{
        my $self = shift;
        my $action = shift || '';
        my $message_id = shift || 0;

        my $can = 0;

        my $error = ( ( not $self -> user_id() ) or $self -> check_if_proper_message_id_provided( $message_id ) );

        if( not $error and $self -> is_message_belongs_to_current_user( $message_id ) )
        {
                my $cur_user = FModel::Users -> get( id => $self -> user_id() );
                my $cur_user_permissions = FModel::Permissions -> get( id => $cur_user -> permissions_id() );

                if( ( $action eq 'delete' and $cur_user_permissions -> delete_messages() ) or
                    ( $action eq 'edit' and $cur_user_permissions -> edit_messages() ) )
                {
                        $can = 1;
                }
        }
        elsif( not $error and ( not $self -> is_message_belongs_to_current_user( $message_id ) ) )
        {
                my $message = FModel::Messages -> get( id => $message_id );
                my $author_permissions = FModel::Permissions -> get( id => $message -> user_id() -> permissions_id() );
                my $author_permissions_title = $author_permissions -> title();

                my $cur_user = FModel::Users -> get( id => $self -> user_id() );
                my $cur_user_permissions = FModel::Permissions -> get( id => $cur_user -> permissions_id() );

                my $can_do_action_with_messages_of;

                if( $action eq 'delete' )
                {
                        $can_do_action_with_messages_of = $cur_user_permissions -> delete_messages_of();
                }
                elsif( $action eq 'edit' )
                {
                        $can_do_action_with_messages_of = $cur_user_permissions -> edit_messages_of();
                }

                for my $title ( split( ', ', $can_do_action_with_messages_of ) )
                {
                        if( $author_permissions_title eq $title ) 
                        {
                                $can = 1;
                                last;
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
        
        my $error = ( ( not $self -> user_id() ) or $self -> check_if_proper_thread_id_provided( $thread_id ) );

        if( not $error and $self -> is_thread_belongs_to_current_user( $thread_id ) )
        {
                my $cur_user = FModel::Users -> get( id => $self -> user_id() );
                my $cur_user_permissions = FModel::Permissions -> get( id => $cur_user -> permissions_id() );

                if( ( $action eq 'delete' and $cur_user_permissions -> delete_threads() ) or
                    ( $action eq 'edit' and $cur_user_permissions -> edit_threads() ) )
                {
                        $can = 1;
                }
        }
        elsif( not $error and ( not $self -> is_thread_belongs_to_current_user( $thread_id ) ) )
        {
                my $thread = FModel::Threads -> get( id => $thread_id );
                my $author_permissions = FModel::Permissions -> get( id => $thread -> user_id() -> permissions_id() );
                my $author_permissions_title = $author_permissions -> title();

                my $cur_user = FModel::Users -> get( id => $self -> user_id() );
                my $cur_user_permissions = FModel::Permissions -> get( id => $cur_user -> permissions_id() );

                my $can_do_action_with_threads_of;

                if( $action eq 'delete' )
                {
                        $can_do_action_with_threads_of = $cur_user_permissions -> delete_threads_of();
                }
                elsif( $action eq 'edit' )
                {
                        $can_do_action_with_threads_of = $cur_user_permissions -> edit_threads_of();
                }

                for my $title ( split( ', ', $can_do_action_with_threads_of ) )
                {
                        if( $author_permissions_title eq $title ) 
                        {
                                $can = 1;
                                last;
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
        
        my $error = ( ( not $self -> user_id() ) or $self -> check_if_proper_user_id_provided( $user_id ) );

        if( not $error )
        {
                my $cur_user = FModel::Users -> get( id => $self -> user_id() );
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


1;
