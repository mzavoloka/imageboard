use Modern::Perl;

package FModel::Sessions;

use FModel::Funcs;
use Wendy::Db qw( dbconnect );
use DateTime 'from_epoch';
use ForumConst 'session_expires_after';

use Moose;
extends 'LittleORM::GenericID'; 

sub _db_table { 'sessions' }

has 'user' => ( is => 'rw',
                metaclass => 'LittleORM::Meta::Attribute',
                isa => 'FModel::Users',
                description => { foreign_key => 'yes',
                                 db_field => 'user_id' } );

has 'session_key' => ( is => 'rw', isa => 'Str' );

has 'expires' => ( is => 'rw',
                   metaclass => 'LittleORM::Meta::Attribute',
                   isa => 'DateTime',
                   description => { coerce_from => sub { &FModel::Funcs::ts2dt( $_[0] ) },
                                    coerce_to   => sub { &FModel::Funcs::dt2ts( $_[0] ) } } );

sub session_expires
{
        return DateTime -> from_epoch( epoch => time() + ForumConst -> session_expires_after(), time_zone => 'local' );
}

sub new_session_key
{
        my $key = Digest::MD5::md5_base64( rand() );

        return $key;
}


1;
