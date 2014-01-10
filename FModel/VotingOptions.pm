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


1;
