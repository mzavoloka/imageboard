use strict;

package FModel::Threads;

use Wendy::Db qw( dbconnect );
use FModel::VotingOptions;
use FModel::Funcs;
use ForumConst qw( pinned_images_dir_url );

use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'threads' }

has 'title' => ( is => 'rw', isa => 'Str' );

has 'created' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'DateTime',
                   description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                    coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'content' => ( is => 'rw', isa => 'Str' );

has 'user' => ( is => 'rw',
                metaclass => 'LittleORM::Meta::Attribute',
                isa => 'FModel::Users',
                description => { db_field => 'user_id',
                                 foreign_key => 'yes' } );

has 'updated' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'DateTime',
                   description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                    coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'modified' => ( is => 'rw',
                    metaclass => 'LittleORM::Meta::Attribute',
                    isa => 'Maybe[DateTime]',
                    description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                     coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

has 'pinned_img' => ( is => 'rw', isa => 'Str' );

has 'vote' => ( is => 'rw', isa => 'Bool' );


LittleORM::Db -> init( &dbconnect() );

sub voting_options
{
        my $self = shift;

        my @options = FModel::VotingOptions -> get_many( thread => $self, _sortby => 'id' );

        return @options;
}

sub update_thread
{
        my $self = shift;

        my $success = 0;

        my $thread = FModel::Threads -> get( id => $self -> id() );
        $thread -> updated( &FModel::Funcs::now() );
        $thread -> update();

        $success = 1;

        return $success;
}

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
