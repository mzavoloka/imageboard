use strict;

package ForumConst;

use Moose;
extends 'ForumApp';

sub get_some_const
{
        my $self = shift;
        my $some_const = FModel::Const -> get( name => 'some_const' );

        my $some_$value = $self -> do_some_things_with_some_const( $some_const -> value() );

        return $some_value;
}


1;
