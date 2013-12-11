package localhost::root;
use strict;

sub wendy_handler()
{
        my $self = shift;
        return ForumMainpage -> run();
}

package ForumMainpage;
use Moose;
extends 'ForumApp';

use Data::Dumper 'Dumper';
use Wendy::Shorts 'ar';

sub _run_modes { [ 'default' ] };

sub app_mode_default
{
	my $self = shift;
        
        $self -> add_messages();
        my $output = $self -> construct_page( middle_tpl => 'mainpage' );

  	return $output;
}

sub add_messages
{
        my $self = shift;

        my @messages_sorted = sort { $b -> posted() cmp $a -> posted() } FModel::Messages -> get_many();
        my $messages = [];
         
        for my $message ( @messages_sorted ) 
        {
                my $msg_hash = { POSTED  => $self -> readable_date( $message -> posted() ),
                                 SUBJECT => $message -> subject(),
                                 CONTENT => $message -> content(),
                                 AUTHOR  => $message -> author() -> name() };
                push( $messages, $msg_hash );
        }

        if( scalar( @$messages ) )
        {
                &ar( MESSAGES => $messages );
        }

        return $messages;
}


1;
