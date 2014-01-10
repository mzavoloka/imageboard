use strict;

package ForumConst;

use FModel::Const;
use Wendy::Db qw( dbconnect );
use File::Spec;

use Wendy::Config 'CONF_VARPATH';

use Moose;
use MooseX::ClassAttribute;

LittleORM::Db -> init( &dbconnect() );

class_has 'session_expires_after' => ( is => 'ro', isa => 'Int', default => sub { &get_session_expires_after() } );

class_has 'htdocs_dir' => ( is => 'ro', isa => 'Str', default => sub { &get_htdocs_dir() } );

class_has 'avatars_dir_url' => ( is => 'ro', isa => 'Str', default => sub { &get_avatars_dir_url() } );

class_has 'avatars_dir_abs' => ( is => 'ro', isa => 'Str', default => sub{ &get_avatars_dir_abs() } );

class_has 'avatar_max_filesize' => ( is => 'ro', isa => 'Int', default => sub { &get_avatar_max_filesize() } );

class_has 'pinned_images_dir_url' => ( is => 'ro', isa => 'Str', default => sub { &get_pinned_images_dir_url() } );

class_has 'pinned_images_dir_abs' => ( is => 'ro', isa => 'Str', default => sub { &get_pinned_images_dir_abs() } );

class_has 'pinned_image_max_filesize' => ( is => 'ro', isa => 'Int', default => sub { &get_pinned_image_max_filesize() } );

class_has 'messages_on_page' => ( is => 'ro', isa => 'Str', default => sub { &get_messages_on_page() } );

class_has 'thread_title_max_length' => ( is => 'ro', isa => 'Str', default => sub { &get_thread_title_max_length() } );

class_has 'message_subject_max_length' => ( is => 'ro', isa => 'Str', default => sub { &get_message_subject_max_length() } );

class_has 'proper_image_filetypes' => ( is => 'ro', isa => 'ArrayRef[Str]', default => sub { &get_proper_image_filetypes() } );

class_has 'images_tmp_dir' => ( is => 'ro', isa => 'Str', default => sub { &get_images_tmp_dir() } );


sub get_session_expires_after
{
        my $const = FModel::Const -> get( name => 'session_expires_after' );

        my $session_expires_after = $const -> value();

        return $session_expires_after;
}

sub get_htdocs_dir
{
        my $htdocs_dir = File::Spec -> catfile( CONF_VARPATH, '/hosts/localhost/htdocs/' );

        return $htdocs_dir;
}

sub get_avatars_dir_url
{
        my $const = FModel::Const -> get( name => 'avatars_dir' );

        my $avatars_dir = $const -> value();

        my $avatars_dir_url = $avatars_dir;

        return $avatars_dir_url;
}

sub get_avatars_dir_abs
{
        my $avatars_dir_abs = File::Spec -> catfile( &get_htdocs_dir(), &get_avatars_dir_url() );

        return $avatars_dir_abs;
}

sub get_avatar_max_filesize
{
        my $const = FModel::Const -> get( name => 'avatar_max_filesize' );

        my $avatar_max_filesize = $const -> value();

        return $avatar_max_filesize;
}

sub get_pinned_images_dir_url
{
        my $const = FModel::Const -> get( name => 'pinned_images_dir' );

        my $pinned_images_dir = $const -> value();

        my $pinned_images_dir_url = $pinned_images_dir;

        return $pinned_images_dir_url;
}

sub get_pinned_images_dir_abs
{
        my $pinned_images_dir_abs = File::Spec -> catfile( &get_htdocs_dir(), &get_pinned_images_dir_url() );

        return $pinned_images_dir_abs;
}

sub get_pinned_image_max_filesize
{
        my $const = FModel::Const -> get( name => 'pinned_image_max_filesize' );

        my $pinned_image_max_filesize = $const -> value();

        return $pinned_image_max_filesize;
}

sub get_messages_on_page
{
        my $const = FModel::Const -> get( name => 'messages_on_page' );

        my $messages_on_page = $const -> value();

        return $messages_on_page;
}

sub get_thread_title_max_length
{
        my $const = FModel::Const -> get( name => 'thread_title_max_length' );

        my $thread_title_max_length = $const -> value();

        return $thread_title_max_length;
}

sub get_message_subject_max_length
{
        my $const = FModel::Const -> get( name => 'message_subject_max_length' );

        my $message_subject_max_length = $const -> value();

        return $message_subject_max_length;
}

sub get_proper_image_filetypes
{
        my $const = FModel::Const -> get( name => 'proper_image_filetypes' );
        
        my @filetypes = split( ', ', $const -> value() );

        return \@filetypes;
}

sub get_images_tmp_dir
{
        my $const = FModel::Const -> get( name => 'images_tmp_dir' );

        my $images_tmp_dir = File::Spec -> catfile( &get_htdocs_dir(), $const -> value() );

        return $images_tmp_dir;
}


1;
