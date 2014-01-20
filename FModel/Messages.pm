use strict;

package FModel::Messages;

use FModel::Funcs;
use ForumConst qw( pinned_images_dir_url pinned_images_dir_abs );

use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'messages' }

has 'subject' => ( is => 'rw', isa => 'Str' );

has 'content' => ( is => 'rw', isa => 'Str' );

has 'author' => ( is => 'rw',
                metaclass => 'LittleORM::Meta::Attribute',
                isa => 'FModel::Users',
                description => { foreign_key => 'yes',
                                 db_field => 'user_id' } );

has 'posted' => ( is => 'rw',
                  metaclass => 'LittleORM::Meta::Attribute',
                  isa => 'DateTime',
                  description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                   coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'thread' => ( is => 'rw',
                  metaclass => 'LittleORM::Meta::Attribute',
                  isa => 'FModel::Threads',
                  description => { foreign_key => 'yes',
                                   db_field => 'thread_id' } );

has 'modified' => ( is => 'rw',
                    metaclass => 'LittleORM::Meta::Attribute',
                    isa => 'Maybe[DateTime]',
                    description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                     coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'pinned_img' => ( is => 'rw', isa => 'Str' );


sub pinned_image_url
{
        my $self = shift;

        my $image_url;

        if( $self -> pinned_img() )
        {
                $image_url = File::Spec -> catfile( ForumConst -> pinned_images_dir_url(), $self -> pinned_img() );
        }

        return $image_url;
}

sub pinned_image_abs
{
        my $self = shift;

        my $image_abs;

        if( $self -> pinned_img() )
        {
                $image_abs = File::Spec -> catfile( ForumConst -> pinned_images_dir_abs(), $self -> pinned_img() );
        }

        return $image_abs;
}

sub delete_pinned_image
{
        my $self = shift;

        if( $self -> pinned_img() )
        {
                unlink $self -> pinned_image_abs();
        }

        return;
}

sub option_that_author_voted_for
{
        my $self = shift;

        my $option = $self -> thread() -> option_that_certain_user_voted_for( $self -> author() );

        return $option;
}

sub option_title_that_author_voted_for
{
        my $self = shift;

        my $title = $self -> option_that_author_voted_for() ? $self -> option_that_author_voted_for() -> title() : '';

        return $title;
}


1;
