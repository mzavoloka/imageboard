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

has 'author' => ( is => 'rw',
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

has 'vote_question' => ( is => 'rw', isa => 'Str' );

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
                $self -> pinned_img( '' );
        }

        return;
}

sub delete_voting_options
{
        my $self = shift;

        for my $option ( $self -> voting_options() )
        {
                $option -> delete();
        }

        return;
}

sub delete_voting_options_that_have_no_votes
{
        my $self = shift;

        for my $option ( $self -> voting_options() )
        {
                unless( $option -> has_votes() )
                {
                        $option -> delete();
                }
        }

        return;
}

sub delete_votes
{
        my $self = shift;

        for my $option ( $self -> voting_options() )
        {
                $option -> delete_votes();
        }

        return;
}

sub did_certain_user_voted_in_this_thread
{
        my ( $self, $user ) = @_;

        my $voted = 0;

        for my $option ( $self -> voting_options() )
        {
                if( $option -> did_certain_user_voted_for_this_option( $user ) )
                {
                        $voted = 1;
                        last;
                }
        }

        return $voted;
}

sub has_votes
{
        my ( $self, $user ) = @_;

        my $has = 0;

        for my $option ( $self -> voting_options() )
        {
                if( $option -> has_votes() )
                {
                        $has = 1;
                        last;
                }
        }

        return $has;
}

sub option_that_certain_user_voted_for
{
        my ( $self, $user ) = @_;

        my $rv;

        for my $option ( $self -> voting_options() )
        {
                if( $option -> did_certain_user_voted_for_this_option( $user ) )
                {
                        $rv = $option;
                        last;
                }
        }

        return $rv;
}

sub option_that_author_voted_for
{
        my ( $self, $user ) = @_;

        my $option = $self -> option_that_certain_user_voted_for( $self -> author() );

        return $option;
}

sub option_title_that_author_voted_for
{
        my ( $self, $user ) = @_;

        my $title = $self -> option_that_author_voted_for() ? $self -> option_that_author_voted_for() -> title() : '';

        return $title;
}

sub delete_user_vote
{
        my ( $self, $user ) = @_;

        for my $option ( $self -> voting_options() )
        {
                if( $option -> did_certain_user_voted_for_this_option( $user ) )
                {
                        my $vote = FModel::Votes -> get( user => $user, voting_option => $option );
                        $vote -> delete();
                        last;
                }
        }

        return;
}

sub clear_vote_data
{
        my $self = shift;
        
        $self -> vote( 0 );
        $self -> vote_question( '' );
        $self -> delete_votes();
        $self -> delete_voting_options();

        return;
}


1;
