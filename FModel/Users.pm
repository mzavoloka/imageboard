use strict;

package FModel::Users;

use FModel::Funcs;
use ForumConst qw( avatars_dir_url );

use Moose;
extends 'LittleORM::GenericID';

sub _db_table { 'users' }

has 'name' => ( is => 'rw', isa => 'Str' );

has 'password' => ( is => 'rw', isa => 'Str' );

has 'email' => ( is => 'rw',
                 metaclass => 'LittleORM::Meta::Attribute',
                 isa => 'Str',
                 # description => { coerce_to => sub { &FModel::Funcs::validate_email( $_[0] ) } }
                 );

has 'registered' => ( is => 'rw',
                      metaclass => 'LittleORM::Meta::Attribute',
                      isa => 'DateTime',
                      description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                       coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'avatar' => ( is => 'rw', isa => 'Str' );

has 'permission' => ( is => 'rw',
                      metaclass => 'LittleORM::Meta::Attribute',
                      isa => 'FModel::Permissions',
                      description => { foreign_key => 'yes',
                                       db_field => 'permission_id' } );

has 'banned' => ( is => 'rw', isa => 'Bool' );

sub get_permission_title
{
        my $self = shift;

        my $title = $self -> permission() -> title();

        return $title;
}

sub get_special_permission_title
{
        my $self = shift;

        my $title = $self -> get_permission_title();

        my $special_title = '';

        if( $title ne 'regular' )
        {
                $special_title = $title;
        }

        return $special_title;
}

sub is_regular
{
        my $self = shift;

        my $regular = 0;

        if( $self -> get_permission_title() eq 'regular' )
        {
                $regular = 1;
        }

        return $regular;
}

sub avatar_url
{
        my $self = shift;

        my $avatar_url = ForumConst -> avatars_dir_url();

        if( $self -> avatar() )
        {
                $avatar_url = File::Spec -> catfile( $avatar_url, $self -> avatar() );
        } else
        {
                $avatar_url = File::Spec -> catfile( $avatar_url, 'default' ); 
        }

        return $avatar_url;
}

sub avatar_abs
{
        my $self = shift;

        my $avatar_abs = ForumConst -> avatars_dir_abs();

        if( $self -> avatar() )
        {
                $avatar_abs = File::Spec -> catfile( $avatar_abs, $self -> avatar() );
        } else
        {
                $avatar_abs = File::Spec -> catfile( $avatar_abs, 'default' ); 
        }

        return $avatar_abs;
}

sub delete_avatar
{
        my $self = shift;

        if( $self -> avatar() )
        {
                unlink $self -> avatar_abs();
        }

        return;
}



1;
