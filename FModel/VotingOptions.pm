use strict;

package FModel::VotingOptions;

use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'voting_options' }

has 'title' => ( is => 'rw', isa => 'Str' );

has 'thread' => ( is => 'rw',
                  metaclass => 'LittleORM::Meta::Attribute',
                  isa => 'FModel::Threads',
                  description => { foreign_key => 'yes',
                                   db_field => 'thread_id' } );

sub votes
{
        my $self = shift;

        my @votes = FModel::Votes -> get_many( voting_option => $self -> id() );

        return @votes;
}

sub num_of_votes
{
        my $self = shift;
        
        my $votes = FModel::Votes -> count( voting_option => $self -> id() );

        return scalar $votes;
}

sub has_votes
{
        my $self = shift;

        my $has = 0;

        if( $self -> num_of_votes() )
        {
                $has = 1;
        }

        return $has;
}

sub percentage
{
        my $self = shift;

        my $total_votes = 0;

        for my $option ( $self -> thread() -> voting_options() )
        {
                $total_votes += $option -> num_of_votes();
        }

        my $percentage = 0;

        if( $total_votes )
        {
                $percentage = $self -> num_of_votes() / $total_votes * 100;
        }

        return $percentage;
}

sub did_certain_user_voted_for_this_option
{
        my ( $self, $user ) = @_;

        my $voted = 0;

        # Делать через гет
        for my $vote ( $self -> votes() )
        {
                if( $user -> id() == $vote -> user() -> id() )
                {
                        $voted = 1;
                        last;
                }
        }

        return $voted;
}

sub delete_votes
{
        my $self = shift;

        # transaction
        for my $vote ( $self -> votes() )
        {
                $vote -> delete();
        }

        return;
}


1;
