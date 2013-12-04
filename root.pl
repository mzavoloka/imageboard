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

use Wendy::Templates::TT 'tt';
use Data::Dumper 'Dumper';
use Wendy::Shorts 'ar';
use CGI ( 'escapeHTML' );

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

        my @messages_sorted = sort { $b -> date() cmp $a -> date() } FModel::Messages -> get_many();

        my $messages = [];
        for my $message ( @messages_sorted ) 
        {
                my $msg_hash = {};
                $msg_hash -> { 'DATE' } = $self -> readable_date( $message -> date() );
                $msg_hash -> { 'SUBJECT' } = escapeHTML( $message -> subject() );
                $msg_hash -> { 'CONTENT' } = escapeHTML( $message -> content() );
                $msg_hash -> { 'AUTHOR' } = $message -> author();
                push( $messages, $msg_hash );
        }

        if( scalar( @$messages ) )
        {
                &ar( MESSAGES => $messages );
        }

        return $messages;
}


1;
