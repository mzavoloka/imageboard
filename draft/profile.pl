use strict;

package localhost::profile;

use Wendy::Templates::TT ( 'tt' );
use Wendy::Db ( 'wdbconnect', 'dbprepare', 'wdbprepare' );
use Wendy::Shorts ( 'ar' );
use Data::Dumper 'Dumper';
use CGI::Cookie ();
use CGI ();
use Carp::Assert 'assert';

use FUser ();



sub wendy_handler
{
	my $WOBJ = shift;
  	my $cgi = $WOBJ -> { "CGI" };
  	my $action = $cgi -> param( "action" ) || "";
        my $tpl = "";

	my ( $middle, $output ) = ( "", "" );
	my $header = &tt( "header" );
	my $footer = &tt( "footer" );


	if( my $username = &FUser::init_user() )
	{

		$middle = &profile_page_for_authorized_user( $cgi );
        } else
	{
		$middle = &tt( "restricted" );
	}

        &ar( HEADER => $header, MIDDLE => $middle, FOOTER => $footer );

        $output = {};
        $output -> { "data" } = &tt( "carcass" );
        $output -> { "nocache" } = 1;

  	return $output;
}


sub profile_page_for_authorized_user
{
	my ( $cgi ) = @_;

	my $middle;
	assert( my $username = &FUser::init_user() );

		&ar( NAME => "", ID => "", REGISTERED => "", EMAIL => "", NUM_OF_MESSAGES => "" );
		my $error_msg = "";
		my $success_msg = "";
		my $no_such_user = 0;

#                my $new_cgi = CGI -> new();
                my $action = $cgi -> param( "action" ) || "";
                if( $action eq "" )
                {
                        my $username = $cgi -> param( "search_user" ) || $username || "";
                        $error_msg = &search_user( $username );

                } elsif( $action eq "change_email" )
                {
                        my $email = $cgi -> param( "email" ) || "";
                        $error_msg = &change_email( $username, $email );
                        $success_msg = "Вы успешно изменили свой email" if( not $error_msg );
                        &search_user( $username );

                } elsif( $action eq "change_password" )
                {

			my $all_you_need = &do_action_change_password( $all_that_it_requires );

                        # my $current_password = $cgi -> param( "current_password" ) || "";
                        # my $new_password = $cgi -> param( "new_password" ) || "";
                        # my $new_password_confirmation = $cgi -> param( "new_password_confirmation" ) || "";
                        # my $change_button_pressed = $cgi -> param( "change" ) || "";
                        # if( $change_button_pressed )
                        # {
                        #         $error_msg = &change_password( $username, $current_password, $new_password, $new_password_confirmation );
                        #         # Can I use this? Or this construction:     ? :     ????

			$success_msg = $error_msg ? '' : &gr( "PASSWORD_CHANGE_OK" );#"Вы успешно изменили свой пароль";

                        #         $success_msg = "Вы успешно изменили свой пароль" if( not $error_msg );
                        #         &search_user( $username );
                        # }
                        # if( $error_msg or ( not $change_button_pressed ) )
                        # {
                        #         $tpl = "change_password";
                        # }
                }


#		my $output = "";
		&ar( CURRENT_USER => $username, ERROR_MSG => $error_msg, SUCCESS_MSG => $success_msg );

	$middle = &tt( $tpl or "profile" );

		# if( $tpl )
		# {
		# 	$middle = &tt( $tpl );
		# } else
		# {
		# 	$middle = &tt( "profile" );
		# }

		return $middle;

}


sub search_user
{
        my $user = shift;

        my $error_msg = "";
        my $sth = &dbprepare( "SELECT id, name, registered, email FROM users WHERE name = ?" );
        $sth -> bind_param( 1, $user );
        $sth -> execute();
        my ( $id, $name, $registered, $email ) = $sth -> fetchrow_array();

        if ( $id )
        {
                my $sth = &dbprepare( "SELECT date FROM messages WHERE author = ?" ); 
                $sth -> bind_param( 1, $user );
                $sth -> execute();
                my $num_of_messages = scalar( @{ $sth -> fetchall_arrayref() } );
                &ar( NAME => $name, ID => $id, REGISTERED => &__readable_date( $registered ), EMAIL => $email, NUM_OF_MESSAGES => $num_of_messages );
        }
        else
        {
                $error_msg = "Пользователь не найден";
        }
        return $error_msg;
}

sub change_email
{
        my $current_user = shift;
        my $email = shift;
        my $error_msg = "";

        if( &is_email_valid( $email ) )
        {
                &wdbconnect();
                my $sth = &wdbprepare( "UPDATE users SET email = ? WHERE name = ?" );
                $sth -> bind_param( 1, $email );
                $sth -> bind_param( 2, $current_user );
                $sth -> execute();
        }
        else
        {
                $error_msg = "Вы ввели некорректный email";
        }

        return $error_msg;
}

sub check_mode_error
{
	my $error = undef;

	unless( $error )
	{

		unless( ( $current_password ne "" )
			and
			( $new_password ne "" )
			and
			( $new_password_confirmation ne "" ) )
		{
			$error = &gr( 'NOT_ALL_DATA_FILLED' );
		}

	}

	unless( $error )
	{
		unless( $new_password_confirmation eq $new_password )
		{
			$error = &gr( 'PASS_MISMATCH' );
		}
	}

	return $error;

}

sub change_password
{
        my $current_user = shift;
        my $current_password = shift;
        my $new_password = shift;
        my $new_password_confirmation = shift;
        my $error_msg = "";

        #&dbconnect();
        my $all_fields_are_filled = ( ( $current_password ne "" )
				      and
				      ( $new_password ne "" )
				      and
				      ( $new_password_confirmation ne "" ) );


	if( my $error = &check_mode_error() )
	{
		&ar( DYN_ERR_MSG => $error );
		1;
	} else
	{
		# !!!
	}

        if( $all_fields_are_filled )
        {
                my $sth = &dbprepare( "SELECT password FROM users WHERE name = ?" );
                $sth -> bind_param( 1, $current_user );
                $sth -> execute();
                my ( $current_password_db ) = $sth -> fetchrow_array();
                my $current_password_correct = ( $current_password eq $current_password_db );
                if( $current_password_correct )
                {
                        my $new_password_confirmed = ( $new_password eq $new_password_confirmation );
                        if ( $new_password_confirmed )
                        {
                                &wdbconnect();
                                my $sth = &wdbprepare( "UPDATE users SET password = ? WHERE name = ?" );
                                $sth -> bind_param( 1, $new_password );
                                $sth -> bind_param( 2, $current_user );
                                $sth -> execute();
                        }
                        else
                        {
                                $error_msg = "Вы неправильно подтвердили новый пароль";
                        }
                }
                else
                {
                        $error_msg = "Вы ввели неправильный текущий пароль";
                }
        }
        else
        {
                $error_msg = "Вы должны заполнить все поля";
        }

        return $error_msg;
}

sub logout
{
        my $WOBJ = shift;
    	my $user_cookie = CGI::Cookie -> new( -name => "user", -value => "" );
    	$WOBJ -> { "REQREC" } -> headers_out() -> add( "Set-Cookie" => $user_cookie );
    	$WOBJ -> { "CUR_USER" } = "";
    	my $rv = &mainpage();
        return $rv;
}

sub __compare_dates
{
 	my $first_date = shift;
 	my $second_date = shift;
 
 	my ( $part1_fd, $part2_fd ) = split ( ' ', $first_date );
 	my ( $year, $month, $day ) = split ( '-', $part1_fd );
 	my ( $part2_fd, $milliseconds ) = split ( /\./, $part2_fd );
 	my ( $hours, $minutes, $seconds ) = split ( ':', $part2_fd );
 	my @first_date_priority_desc = ( $year, $month, $day, $hours, $minutes, $seconds, $milliseconds );
 
 	my ( $part1_sd, $part2_sd ) = split ( ' ', $second_date );
 	my ( $year, $month, $day ) = split ( '-', $part1_sd );
 	my ( $part2_sd, $milliseconds ) = split ( /\./, $part2_sd );
 	my ( $hours, $minutes, $seconds ) = split ( ':', $part2_sd );
 	my @second_date_priority_desc = ( $year, $month, $day, $hours, $minutes, $seconds, $milliseconds );

	my $rv = 0;
 
 	for my $index ( 0 .. ( scalar( @first_date_priority_desc ) - 1 ) )
 	{
 		if( $second_date_priority_desc[ $index ] <=> $first_date_priority_desc[ $index ] )
 		{
 			$rv = $second_date_priority_desc[ $index ] <=> $first_date_priority_desc[ $index ];
			last;
 		}
 	}

 	return $rv;
}

sub __readable_date
{
	my $date = shift;
	my ( $part1, $part2 ) = split ( ' ', $date );
	my ( $year, $month, $day ) = split ( '-', $part1 );
	my ( $time, $milliseconds ) = split ( /\./, $part2 );
	return ( $day . '.' . $month . '.' . $year . ' ' . $time );
}

sub is_email_valid
{
        my $email = shift;
        return ( $email =~ /.+@.+\..+/i );
}

sub redir_to_mainpage
{
        return { nocache => 1,
                 code => 302,
                 headers => { Location => '/' } };
}

sub redir_to_profile
{
        return { nocache => 1,
                 code => 302,
                 headers => { Location => '/profile' } };
}

sub __log_user_in
{
	my $WOBJ = shift;
  	my $username = shift;

  	my $user_cookie = CGI::Cookie -> new( -name => "user", -value => $username );
	$WOBJ -> { "REQREC" } -> headers_out() -> add( "Set-Cookie" => $user_cookie );
	$WOBJ -> { "CUR_USER" } = $username;
        return $username;
}

1;
