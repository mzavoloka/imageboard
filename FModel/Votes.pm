package FModel::Votes;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'votes' }

has 'voting_option_id' => ( is => 'rw',
                            metaclass => 'LittleORM::Meta::Attribute',
                            isa => 'FModel::VotingOptions',
                            description => { foreign_key => 'FModel::VotingOptions' } );

has 'user_id' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'FModel::Users',
                   description => { foreign_key => 'FModel::Users' } );

1;
