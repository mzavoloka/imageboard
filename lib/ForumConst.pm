use Modern::Perl;

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

class_has 'vote_question_max_length' => ( is => 'ro', isa => 'Str', default => sub { &get_vote_question_max_length() } );

class_has 'message_subject_max_length' => ( is => 'ro', isa => 'Str', default => sub { &get_message_subject_max_length() } );

class_has 'proper_image_filetypes' => ( is => 'ro', isa => 'ArrayRef[Str]', default => sub { &get_proper_image_filetypes() } );

class_has 'images_tmp_dir' => ( is => 'ro', isa => 'Str', default => sub { &get_images_tmp_dir() } );

class_has 'num_of_adminka_users_cols' => ( is => 'ro', isa => 'Int', default => sub { &get_num_of_adminka_users_cols() } );

class_has 'arrowup_image_url' => ( is => 'ro', isa => 'Str', default => sub { &get_arrowup_image_url() } );

class_has 'arrowdown_image_url' => ( is => 'ro', isa => 'Str', default => sub { &get_arrowdown_image_url() } );

class_has 'arrow_image_width' => ( is => 'ro', isa => 'Int', default => sub { &get_arrow_image_width() } );

class_has 'arrow_image_height' => ( is => 'ro', isa => 'Int', default => sub { &get_arrow_image_height() } );

class_has 'images_dir' => ( is => 'ro', isa => 'Str', default => sub { &get_images_dir() } );

class_has 'icon_delete_url' => ( is => 'ro', isa => 'Str', default => sub { &get_icon_delete_url() } );

class_has 'icon_russian_url' => ( is => 'ro', isa => 'Str', default => sub { &get_icon_russian_url() } );

class_has 'icon_american_url' => ( is => 'ro', isa => 'Str', default => sub { &get_icon_american_url() } );

class_has 'users_on_page' => ( is => 'ro', isa => 'Int', default => sub { &get_users_on_page() } );


sub get_session_expires_after
{
        my $const = FModel::Const -> get( name => 'session_expires_after' );

        my $session_expires_after = $const -> value();

        return $session_expires_after;
}

sub get_htdocs_dir
{
        my $htdocs_dir = File::Spec -> catfile( CONF_VARPATH, '/hosts/mzavoloka.ru/htdocs/' );

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

sub get_vote_question_max_length
{
        my $const = FModel::Const -> get( name => 'vote_question_max_length' );

        my $vote_question_max_length = $const -> value();

        return $vote_question_max_length;
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

sub get_num_of_adminka_users_cols
{
        my $const = FModel::Const -> get( name => 'num_of_adminka_users_cols' );

        my $num_of_adminka_users_cols = $const -> value();

        return $num_of_adminka_users_cols;
}

sub get_images_dir
{
        my $const = FModel::Const -> get( name => 'images_dir' );

        my $images_dir = $const -> value();

        return $images_dir;
}

sub get_arrowup_image_url
{
        my $const = FModel::Const -> get( name => 'arrowup_image' );

        my $arrowup_image = $const -> value();

        my $arrowup_image_url = File::Spec -> catfile( &get_images_dir(), $arrowup_image );

        return $arrowup_image_url;
}

sub get_arrowdown_image_url
{
        my $const = FModel::Const -> get( name => 'arrowdown_image' );

        my $arrowdown_image = $const -> value();

        my $arrowdown_image_url = File::Spec -> catfile( &get_images_dir(), $arrowdown_image );

        return $arrowdown_image_url;
}

sub get_arrow_image_width
{
        my $const = FModel::Const -> get( name => 'arrow_image_width' );

        my $arrow_image_width = $const -> value();

        return $arrow_image_width;
}

sub get_arrow_image_height
{
        my $const = FModel::Const -> get( name => 'arrow_image_height' );

        my $arrow_image_height = $const -> value();

        return $arrow_image_height;
}

sub get_icon_delete_url
{
        my $const = FModel::Const -> get( name => 'icon_delete' );

        my $icon_delete = $const -> value();

        my $icon_delete_url = File::Spec -> catfile( &get_images_dir(), $icon_delete );

        return $icon_delete_url;
}

sub get_icon_russian_url
{
        my $const = FModel::Const -> get( name => 'icon_russian' );

        my $icon_delete = $const -> value();

        my $icon_delete_url = File::Spec -> catfile( &get_images_dir(), $icon_delete );

        return $icon_delete_url;
}

sub get_icon_american_url
{
        my $const = FModel::Const -> get( name => 'icon_american' );

        my $icon_delete = $const -> value();

        my $icon_delete_url = File::Spec -> catfile( &get_images_dir(), $icon_delete );

        return $icon_delete_url;
}

sub get_users_on_page
{
        my $const = FModel::Const -> get( name => 'users_on_page' );

        my $users_on_page = $const -> value();

        return $users_on_page;
}



1;
