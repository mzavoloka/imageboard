package localhost::message;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumMessage -> run();
}

package ForumMessage;
use Wendy::Templates::TT 'tt';
use Wendy::Shorts 'ar';
use CGI ( 'escapeHTML' );

use Moose;
extends 'ForumApp';

has 'subject_length' => ( is => 'rw', isa => 'Int', default => 100 );

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

        my $error_msg = "";
        if( $self -> user() )
        {
                my $subject = $self -> arg( 'subject' );
                my $content = $self -> arg( 'content' );
                if( $subject and $content )
                {
                        if( $self -> is_subject_length_accepatable( $subject ) )
                        {
                                $self -> post_message( $subject, $content );
                                $output = $self -> ncrd( '/' );
                        } else
                        {
                                $error_msg = 'SUBJECT_TOO_LONG';
                        }
                } else
                {
                        $error_msg = 'FIELDS_ARE_NOT_FILLED';
                }

                if( $error_msg )
                {
                        &ar( SUBJECT => &escapeHTML( $subject ), CONTENT => &escapeHTML( $content ) );
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

        FModel::Messages -> create( subject => $subject, content => $content, author => $self -> user(), date => 'now()' );

        return;
}

sub is_subject_length_accepatable
{
        my $self = shift;
        my $subject = shift;
        
        my $acceptable = 1;
        if( length( $subject ) > $self -> subject_length() )
        {
                $acceptable = 0;
        }

        return $acceptable;
}


1;
