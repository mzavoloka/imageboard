package FModel::VotingOptions;
use strict;
use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'voting_options' }

has 'title' => ( is => 'rw', isa => 'Str' );

has 'thread_id' => ( is => 'rw',
                     metaclass => 'LittleORM::Meta::Attribute',
                     isa => 'FModel::Threads',
                     description => { foreign_key => 'FModel::Threads',
                                      foreign_key_attr_name => 'id' } );


1;
