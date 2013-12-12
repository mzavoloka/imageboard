use strict;

package localhost::message;

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

        my $subject = $self -> arg( 'subject' ) || '';
        my $content = $self -> arg( 'content' ) || '';

        my $output;

        if( my $error_msg = $self -> can_message_be_posted( $subject, $content ) )
        {
                &ar( SUBJECT => $subject, CONTENT => $content );
                $output = $self -> construct_page( middle_tpl => 'message', error_msg => $error_msg );
        } else
        {
                $self -> post_message( $subject, $content );
                $output = $self -> ncrd( '/' );
        }

        return $output;
}

sub can_message_be_posted
{
        my $self = shift;
        my $subject = shift;
        my $content = shift;

        my $error_msg = '';

        my $fields_are_filled = ( $self -> trim( $subject ) and $self -> trim( $content ) );

        if( not $fields_are_filled )
        {
                $error_msg = 'FIELDS_ARE_NOT_FILLED';
        }
        if( $fields_are_filled and ( not $self -> is_subject_length_accepatable( $subject ) ) )
        {
                $error_msg = 'SUBJECT_TOO_LONG';
        }

        return $error_msg;
}

sub post_message
{
        my $self = shift;
        my $subject = shift;
        my $content = shift;
        
        FModel::Messages -> create( subject   => $subject,
                                    content   => $content,
                                    author    => $self -> user(),
                                    thread_id => 1,
                                    posted    => $self -> now() );

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
