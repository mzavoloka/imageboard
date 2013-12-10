package localhost::message;
use strict;

sub wendy_handler
{
        my $self = shift;
        return ForumMessage -> run();
}

package ForumMessage;
use Wendy::Shorts 'ar';

use Moose;
extends 'ForumApp';

has 'subject_length' => ( is => 'rw', isa => 'Int', default => 100 );

sub _run_modes { [ 'default', 'post' ] };

sub always
{
        my $self = shift;

        my $rv;

        unless( $self -> user() )
        {
                $rv = $self -> construct_page( restricted_msg => 'MESSAGE_RESTRICTED' );
        }
        
        return $rv; 
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> construct_page( middle_tpl => 'message' );

  	return $output;
}

sub app_mode_post
{
        my $self = shift;

        my $subject = $self -> arg( 'subject' );
        my $content = $self -> arg( 'content' );
        my $error_msg = '';
        my $output;
        
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
                &ar( SUBJECT => $subject, CONTENT => $content );
                $output = $self -> construct_page( middle_tpl => 'message', error_msg => $error_msg );
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
