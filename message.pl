package localhost::message;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumMessage -> run();
}

package ForumMessage;
use Moose;
extends 'ForumApp';

use Wendy::Templates::TT 'tt';
use Wendy::Db qw( wdbconnect wdbprepare );
use Wendy::Shorts 'ar';
use CGI ( 'escapeHTML' );

sub _run_modes { [ 'default', 'post' ] };

sub app_mode_default
{
        my $self = shift;

        my $output = {};
        if( $self -> user() )
        {
                $output = $self -> construct_page( middle_tpl => 'message' );
        } else
        {
                $output = $self -> construct_page( restricted_msg => 'MESSAGE_RESTRICTED' );
        }

  	return $output;
}

sub app_mode_post
{
        my $self = shift;

        my $output = {};

        if( $self -> user() )
        {
                my $subject = $self -> arg( 'subject' );
                my $content = $self -> arg( 'content' );
                if( $subject and $content )
                {
                        $self -> post_message( $subject, $content );
                        $output = $self -> ncrd( '/' );
                } else
                {
                        &ar( SUBJECT => &escapeHTML( $subject ), CONTENT => &escapeHTML( $content ) );
                	my $error_msg = 'FIELDS_ARE_NOT_FILLED';
                        $output = $self -> construct_page( middle_tpl => 'message', error_msg => $error_msg );
                }
        } else
        {
                $output = $self -> construct_page( restricted_msg => 'MESSAGE_RESTRICTED' );
        }

        return $output;
}

sub post_message
{
        my $self = shift;
        my $subject = shift;
        my $content = shift;

        &wdbconnect();
        my $sth = &wdbprepare( "INSERT INTO messages (subject, content, author, date) VALUES (?, ?, ?, now())" );
        $sth -> bind_param( 1, $subject );
        $sth -> bind_param( 2, $content );
        $sth -> bind_param( 3, $self -> user() );
        $sth -> execute();

        return;
}


1;
