use strict;

package localhost::adminka_preferences;

sub wendy_handler
{
        return ForumAdminkaPreferences -> run();
}

package ForumAdminkaPreferences;
use Wendy::Shorts qw( ar );
use Wendy::Util qw( in );
use Carp::Assert 'assert';
use Data::Dumper 'Dumper';
use ForumConst;

use Moose;
extends 'ForumApp';

sub _run_modes { [ 'default', 'cancel_changes', 'save_changes' ] };


sub init
{
        my $self = shift;

        my $rv;

        if( my $error = $self -> SUPER::init() )
        {
                $rv = $error;
        }
        elsif( not $self -> can_use_adminka() )
        {
                $rv = $self -> construct_page( restricted_msg => 'ADMINKA_RESTRICTED' );
        }

        return $rv;
}

sub app_mode_default
{
        my $self = shift;

        my $output = $self -> show_preferences_form();

        return $output;
}

sub app_mode_cancel_changes
{
        my $self = shift;

        my $output = $self -> show_preferences_form();

        return $output;
}

sub app_mode_save_changes
{
        my $self = shift;

        my $output;

        if( my $error_msg = $self -> check_if_can_save_changes() )
        {
                $output = $self -> show_preferences_form( error_msg => $error_msg );
        }
        else
        {
                $self -> do_save_changes();
                $output = $self -> show_preferences_form( success_msg => 'PREFERENCES_EDITED' );
        }

        return $output;
}

sub check_if_can_save_changes
{
        my $self = shift;

        my $error_msg = '';

        unless( $self -> do_all_consts_have_name() )
        {
                $error_msg = 'ALL_CONSTANTS_HAVE_TO_BE_NAMED';
        }
        elsif( not $self -> do_all_consts_have_unique_name() )
        {
                $error_msg = 'CONSTANTS_MUST_HAVE_UNIQUE_NAME';
        }

        return $error_msg;
}

sub do_all_consts_have_unique_name
{
        my $self = shift;

        my $all_consts_have_unique_name = 1;

        my @all_names = ();

        for my $arg_name ( keys $self -> args() )
        {
                if( $arg_name =~ /^const_(\d+)_name$/ )
                {
                        my $const_id = $1;
                        my $const_name = $self -> arg( 'const_' . $const_id . '_name' );
                        
                        if( &in( $const_name, @all_names ) )
                        {
                                $all_consts_have_unique_name = 0;
                                last;
                        }
                        
                        push( @all_names, $const_name );
                }
        }

        return $all_consts_have_unique_name;
}

sub do_all_consts_have_name
{
        my $self = shift;

        my $all_consts_have_name = 1;

        for my $arg_name ( keys $self -> args() )
        {
                if( $arg_name =~ /^const_(\d+)_name$/ )
                {
                        my $const_id = $1;

                        if( not $self -> arg( 'const_' . $const_id . '_name' ) )
                        {
                                $all_consts_have_name = 0;
                                last;
                        }
                }
        }

        return $all_consts_have_name;
}

sub do_save_changes
{
        my $self = shift;

        for my $arg_name ( keys $self -> args() )
        {
                if( $arg_name =~ /^const_(\d+)_to_delete$/ )
                {
                        my $const_to_delete_id = $1;

                        if( $self -> arg( 'const_' . $const_to_delete_id . '_to_delete' ) )
                        {
                                $self -> delete_const( $const_to_delete_id );
                        }
                }
                elsif( $arg_name =~ /^const_(\d+)_added$/ )
                {
                        my $const_added_id = $1;

                        if( $self -> arg( 'const_' . $const_added_id . '_added' ) and ( not $self -> arg( 'const_' . $const_added_id . '_to_delete' ) ) )
                        {
                                $self -> add_const( $const_added_id );
                        }
                }
                elsif( $arg_name =~ /^const_(\d+)_modified$/ )
                {
                        my $const_modified_id = $1;

                        if( $self -> arg( 'const_' . $const_modified_id . '_modified' ) and ( not $self -> arg( 'const_' . $const_modified_id . '_to_delete' ) ) )
                        {
                                $self -> modify_const( $const_modified_id );
                        }
                }
        }
        
        return;
}

sub delete_const
{
        my ( $self, $id ) = @_;

        my $const_to_delete = FModel::Const -> get( id => $id );

        if( defined $const_to_delete )
        {
                $const_to_delete -> delete();
        }

        return;
}

sub modify_const
{
        my ( $self, $id ) = @_;

        my $const_modified = FModel::Const -> get( id => $id );

        my $const_name = $self -> arg( 'const_' . $id . '_name' );
        $const_modified -> name( $const_name );

        my $const_value = $self -> arg( 'const_' . $id . '_value' );
        $const_modified -> value( $const_value );

        $const_modified -> update();

        return;
}

sub add_const
{
        my ( $self, $id ) = @_;

        my $const_name = $self -> arg( 'const_' . $id . '_name' );
        my $const_value = $self -> arg( 'const_' . $id . '_value' );

        assert( FModel::Const -> create( id => $id, name => $const_name, value => $const_value ) );

        return;
}

sub show_preferences_form
{
        my ( $self, %params ) = @_;

        my $error_msg = $params{ 'error_msg' };
        my $success_msg = $params{ 'success_msg' };

        my $id = $self -> arg( 'id' );
        
        my $constants;

        if( $error_msg )
        {
                $constants = $self -> get_constants_from_args();
        }
        else
        {
                $constants = $self -> get_constants_from_db();
        }

        &ar( DYN_ICON_DELETE_URL => ForumConst -> icon_delete_url(),
             DYN_CONSTANTS => $constants );

        my $output = $self -> construct_page( middle_tpl => 'adminka_preferences', error_msg => $error_msg, success_msg => $success_msg );

        return $output;
}

sub get_constants_from_args
{
        my $self = shift;

        my @constants = FModel::Const -> get_many( _sortby => 'name' );

        my @constants_for_replace = ();

        for my $const ( @constants )
        {
                my $hash = { DYN_ID        => $const -> id(),
                             DYN_TO_DELETE => $self -> arg( 'const_' . $const -> id() . '_to_delete' ),
                             DYN_ADDED     => 0 };

                if( $self -> arg( 'const_' . $const -> id() . '_modified' ) )
                {
                        $hash -> { 'DYN_MODIFIED' } = 1;
                        $hash -> { 'DYN_NAME' } = $self -> arg( 'const_' . $const -> id() . '_name' );
                        $hash -> { 'DYN_VALUE' } = $self -> arg( 'const_' . $const -> id() . '_value' );
                }
                else
                {
                        $hash -> { 'DYN_MODIFIED' } = 0;
                        $hash -> { 'DYN_NAME' } = $const -> name();
                        $hash -> { 'DYN_VALUE' } = $const -> value();
                }

                push( @constants_for_replace, $hash );
        }

        @constants_for_replace = sort { $self -> compare_for_constants_sort( $a, $b ) } @constants_for_replace;

        my @added_constants = ();

        for my $arg_name ( keys $self -> args() )
        {
                if( $arg_name =~ /^const_(\d+)_added$/ )
                {
                        my $added_const_id = $1;
                        if( $self -> arg( 'const_' . $added_const_id . '_added' ) )
                        {
                                my $hash = { DYN_ID        => $added_const_id,
                                             DYN_NAME      => $self -> arg( 'const_' . $added_const_id . '_name' ),
                                             DYN_VALUE     => $self -> arg( 'const_' . $added_const_id . '_value' ),
                                             DYN_TO_DELETE => $self -> arg( 'const_' . $added_const_id . '_to_delete' ),
                                             DYN_MODIFIED  => 0,
                                             DYN_ADDED     => 1 };
                                             
                                push( @added_constants, $hash );
                        }
                }
        }

        @added_constants = sort { $a -> { 'DYN_ID' } <=> $b -> { 'DYN_ID' } } ( @added_constants );

        @constants_for_replace = ( @constants_for_replace, @added_constants );

        return \@constants_for_replace;
}

sub compare_for_constants_sort
{
        my ( $self, $a, $b ) = @_;

        my $a_const = FModel::Const -> get( id => $a -> { 'DYN_ID' } );
        my $b_const = FModel::Const -> get( id => $b -> { 'DYN_ID' } );
        
        return( $a_const -> name() cmp $b_const -> name() );
}

sub get_constants_from_db
{
        my $self = shift;

        my @constants = FModel::Const -> get_many( _sortby => 'name' );

        my @constants_for_replace = ();

        for my $const ( @constants )
        {
                push( @constants_for_replace, { DYN_ID        => $const -> id(),
                                                DYN_NAME      => $const -> name(),
                                                DYN_VALUE     => $const -> value(),
                                                DYN_TO_DELETE => 0,
                                                DYN_MODIFIED  => 0,
                                                DYN_ADDED     => 0 } );
        }

        return \@constants_for_replace;
}


1;
