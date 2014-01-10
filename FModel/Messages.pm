use strict;

package FModel::Messages;

use FModel::Funcs;
use ForumConst qw( pinned_images_dir_url );

use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'messages' }

has 'subject' => ( is => 'rw', isa => 'Str' );

has 'content' => ( is => 'rw', isa => 'Str' );

has 'user' => ( is => 'rw',
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


sub pinned_image_src
{
        my $self = shift;

        my $image_src;

        if( $self -> pinned_img() )
        {
                $image_src = File::Spec -> catfile( ForumConst -> pinned_images_dir_url(), $self -> pinned_img() );
        }

        return $image_src;
}


1;
