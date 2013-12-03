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
use Wendy::Db qw( dbprepare );
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

        # ORM join
  	my $sth = &dbprepare( "SELECT m.id, m.author, m.date, m.subject, m.content FROM messages AS m
                LEFT JOIN users AS u ON u.name = m.author WHERE 1=1" );
  	$sth -> execute();
  	my $messages_unsorted = $sth -> fetchall_hashref( 'id' );
        $sth -> finish(); 

        my $messages = [];
	for my $id ( sort { $b cmp $a } keys $messages_unsorted )
	{
    		my $msg_hash = $messages_unsorted -> { $id };
                $msg_hash -> { 'date' } = $self -> readable_date( $msg_hash -> { 'date' } );
                $msg_hash -> { 'subject' } = escapeHTML( $msg_hash -> { 'subject' } );
                $msg_hash -> { 'content' } = escapeHTML( $msg_hash -> { 'content' } );
                push( @$messages, $msg_hash );
        }

        if( $messages )
        {
                &ar( MESSAGES => $messages );
        }

        return $messages;
}


1;
