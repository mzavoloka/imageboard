package FModel::Votes;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'votes' }

has 'voting_option' => ( is => 'rw',
                         metaclass => 'LittleORM::Meta::Attribute',
                         isa => 'FModel::VotingOptions',
                         description => { foreign_key => 'yes',
                                          db_field => 'voting_option_id' } );

has 'user' => ( is => 'rw',
                metaclass => 'LittleORM::Meta::Attribute',
                isa => 'FModel::Users',
                description => { foreign_key => 'yes',
                                 db_field => 'user_id' } );


1;
