#!/usr/bin/perl
#
# Package for parsing Apache logs
#
# by <chilladx@gmail.com>
#
# $Id$
#

package ApacheLogsParser;

# Uses
use warnings;
use strict;

# Constants
my $RE_INQUOTED='(?:[^"]*(?:\\\")*)*';
my $RE_HOST='(?:\d+\.){3}\d+';
my $RE_USER=$RE_INQUOTED;

my $RE_DATE_DAY='\d+';
my $RE_DATE_MONTH='[A-Za-z]*';
my $RE_DATE_YEAR='\d+';
my $RE_DATE_HOUR='\d+';
my $RE_DATE_MINUTE='\d+';
my $RE_DATE_SECOND='\d+';
my $RE_DATE_TIMEZONE='[+-]\d+';
my $RE_DATE='\['. $RE_DATE_DAY .'/'. $RE_DATE_MONTH .'/'. $RE_DATE_YEAR .':'. $RE_DATE_HOUR .':'. $RE_DATE_MINUTE .':'. $RE_DATE_SECOND .' '. $RE_DATE_TIMEZONE .'\]';

my $RE_REQUEST=$RE_INQUOTED;
my $RE_STATUS='\d+';
my $RE_OBYTES='\d+';
my $RE_DELAY='\d+';
my $RE_PID='\d+';
my $RE_REFERER=$RE_INQUOTED;
my $RE_UA=$RE_INQUOTED;

# Error handling
my $ERR_HASH="-_Error_-";
# code or litteral ?
# if this turn into code, we can then reuse them with standard function
# returning scalar (with x < 0)
my $ERR_NOTMWSTD="not a proper logformat";
my $ERR_NOPARAM="bad parameters";

##################################
# function getTabbedFields()
# arg: one apache log line, with  std format
# returns an hash of all fields
sub getTabbedFields
{
	# get the param
	my $line_of_logs = shift;
	my $wantnumeric = shift;

	# variables
	my %ret;
	
	# try to pattern match
	if ($line_of_logs =~ m/^($RE_HOST) - - ($RE_DATE) "($RE_REQUEST)" ($RE_STATUS) ($RE_OBYTES) "($RE_REFERER)" "($RE_UA)"/o)
	{
		# populate to hash
		$ret{ "HOST" } = $1;
		$ret{ "DATE" } = $2;
		$ret{ "REQUEST" } = $3;
		$ret{ "STATUS" } = $4;
		$ret{ "OBYTES" } = $5;
		$ret{ "REFERER" } = $6;
		$ret{ "UA" } = $7;
	} else {
		# logs are not std format
		$ret{ $ERR_HASH } = $ERR_NOTMWSTD;
	}
	# return the hash
	return %ret;
}

##################################
# function getHTTPMethod()
# arg: one apache log line, with std format
# returns the HTTP method used by the client in the request
sub getHTTPMethod($)
{
	# get the param
	my $line_of_logs = shift;
	# variables
	my ($method, $URL, $version);
	
	# try to pattern match
	if ($line_of_logs =~ m/^$RE_HOST - - $RE_DATE "($RE_REQUEST)" $RE_STATUS $RE_OBYTES "$RE_REFERER" "$RE_UA"/o)
	{
		# split the <space> separated string
		($method, $URL, $version) = split(/ /, $1);
	
		# return the value
		return $method;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getURLFull()
# arg: one apache log line, with std format
# returns the full URL (ie page + param) called by the client in the request
sub getURLFull($)
{
	# get the param
	my $line_of_logs = shift;
	# variables
	my ($method, $URL, $version);
	
	# try to pattern match
	if ($line_of_logs =~ m/^$RE_HOST - - $RE_DATE "($RE_REQUEST)" $RE_STATUS $RE_OBYTES "$RE_REFERER" "$RE_UA"/o)
	{
		# split the <space> separated string
		($method, $URL, $version) = split(/ /, $1);
	
		# return the value
		return $URL;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getURLPage()
# arg: one apache log line, with std format
# returns the page called by the client in the request
sub getURLPage($)
{
	# get the param
	my $line_of_logs = shift;
	# variables
	my ($page, $method, $URL, $version, $params);
	
	# try to pattern match
	if ($line_of_logs =~ m/^$RE_HOST - - $RE_DATE "($RE_REQUEST)" $RE_STATUS $RE_OBYTES "$RE_REFERER" "$RE_UA"/o)
	{
		# split the <space> separated string
		($method, $URL, $version) = split(/ /, $1);
		# the URL is either page?param or page, so we split on ?
		($page, $params) = split(/\?/, $URL);
	
		# return the value
		return $page;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getURLParam()
# arg: one apache log line, with std format
# returns the params of the page called by the client in the request
sub getURLParam($)
{
	# get the param
	my $line_of_logs = shift;
	# variables
	my ($page, $method, $URL, $version, $params);
	
	# try to pattern match
	if ($line_of_logs =~ m/^$RE_HOST - - $RE_DATE "($RE_REQUEST)" $RE_STATUS $RE_OBYTES "$RE_REFERER" "$RE_UA"/o)
	{
		# split the <space> separated string
		($method, $URL, $version) = split(/ /, $1);
		# the URL is either page?param or page, so we split on ?
		($page, $params) = split(/\?/, $URL);
	
		# return the value
		return $params;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getTabbedURLParam()
# arg: one apache log line, with std format
# returns a hash of all params of the page page called by the client in the request
sub getTabbedURLParam($)
{
	# get the param
	my $line_of_logs = shift;
	# variables
	my ($page, $method, $URL, $version, $params, $param, $value, $itemParam);
	my %ret;
	my @tabParams ;
	
	# try to pattern match
	if ($line_of_logs =~ m/^$RE_HOST - - $RE_DATE "($RE_REQUEST)" $RE_STATUS $RE_OBYTES "$RE_REFERER" "$RE_UA"/o)
	{
		# split the <space> separated string
		($method, $URL, $version) = split(/ /, $1) ;
		# the URL is either page?param or page, so we split on ?
		($page, $params) = split(/\?/, $URL) ;
		# if there are parameters
		if (defined $params) {
			# split the & separated string
			@tabParams = split(/&/, $params) ;
			# populate to hash
			foreach $itemParam (@tabParams)
			{
				# params look like param=value, so we split on =
				($param, $value) = split(/=/, $itemParam) ;
				$ret{ $param } = $value ;
			}
		} else {
			# there is no param
			$ret{ $ERR_HASH } = $ERR_NOPARAM;
		}
	} else {
		# logs are not std format
		$ret{ $ERR_HASH } = $ERR_NOTMWSTD;
	}
	# return the hash
	return %ret ;
}

##################################
# function getTabbedDate()
# arg: one apache log line, with std format
# returns the date in a hash
sub getTabbedDate($)
{
	# get the param
	my $line_of_logs = shift;
	# variables
	my %ret;
	
	# try to pattern match
	if ($line_of_logs =~ m/^$RE_HOST - - \[($RE_DATE_DAY)\/($RE_DATE_MONTH)\/($RE_DATE_YEAR):($RE_DATE_HOUR):($RE_DATE_MINUTE):($RE_DATE_SECOND) ($RE_DATE_TIMEZONE)\] "$RE_REQUEST" $RE_STATUS $RE_OBYTES "$RE_REFERER" "$RE_UA"/o)
	{
		#populate to hash 
		$ret{ "DATE_DAY" } = $1 ;
		$ret{ "DATE_MONTH" } = $2 ;
		$ret{ "DATE_YEAR" } = $3 ;
		$ret{ "DATE_HOUR" } = $4 ;
		$ret{ "DATE_MINUTE" } = $5 ;
		$ret{ "DATE_SECOND" } = $6 ;
		$ret{ "DATE_TIMEZONE" } = $7 ;
	} else {
		# logs are not std format
		$ret{ $ERR_HASH } = $ERR_NOTMWSTD;
	}
	# return the hash
	return %ret;
}

##################################
# function getURLFullFromRequest()
# arg: Request field (ie <methode> <url[+param]> <version>)
# returns the full URL (ie page + param) called by the client in the request
sub getURLFullFromRequest($)
{
	# get the param
	my $request = shift;
	# variables
	my ($method, $URL, $version);
	
	# split the <space> separated string
	($method, $URL, $version) = split(/ /, $request);
	
	# just check the result
	if (defined $URL)
	{
		# return the value
		return $URL;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getURLPageFromRequest()
# arg: Request field (ie <methode> <url[+param]> <version>)
# returns the page called by the client in the request
sub getURLPageFromRequest($)
{
	# get the param
	my $request = shift;
	# variables
	my ($page, $method, $URL, $version, $params);
	
	# split the <space> separated string
	($method, $URL, $version) = split(/ /, $request);

	if (defined $URL)
	{
		# the URL is either page?param or page, so we split on ?
		($page, $params) = split(/\?/, $URL);
	
		# return the value
		return $page;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getURLParamFromRequest()
# arg: Request field (ie <methode> <url[+param]> <version>)
# returns the param of the page called by the client in the request
sub getURLParamFromRequest($)
{
	# get the param
	my $request = shift;
	# variables
	my ($page, $method, $URL, $version, $params);
	
	# split the <space> separated string
	($method, $URL, $version) = split(/ /, $request);

	if (defined $URL)
	{
		# the URL is either page?param or page, so we split on ?
		($page, $params) = split(/\?/, $URL);
	
		# return the value
		return $params;
	} else {
		# logs are not std format
		return 0;
	}
}

##################################
# function getTabbedURLParamFromRequest()
# arg: Request field (ie <methode> <url[+param]> <version>)
# returns a hash of all params of the page page called by the client in the request
sub getTabbedURLParamFromRequest($)
{
	# get the param
	my $request = shift;
	# variables
	my ($page, $method, $URL, $version, $params, $param, $value, $itemParam);
	my %ret;
	my @tabParams ;
	
	# split the <space> separated string
	($method, $URL, $version) = split(/ /, $request) ;
	# just check it worked
	if (defined $URL)
	{
		# the URL is either page?param or page, so we split on ?
		($page, $params) = split(/\?/, $URL) ;
		# if there are parameters
		if (defined $params) {
			# split the & separated string
			@tabParams = split(/&/, $params) ;
			# populate to hash
			foreach $itemParam (@tabParams)
			{
				# params look like param=value, so we split on =
				($param, $value) = split(/=/, $itemParam) ;
				if (defined $param) {
					$ret{ $param } = $value ;
				}
			}
		} else {
			# there is no param
			$ret{ $ERR_HASH } = $ERR_NOPARAM;
		}
	} else {
		# logs are not std format
		$ret{ $ERR_HASH } = $ERR_NOTMWSTD;
	}
	# return the hash
	return %ret ;
}

##################################
# function getTabbedDateFromDate()
# arg: Date field (ie [DAY/MONTH/YEAR:HOUR:MINUTE:SECOND TIMEZONE])
# returns the date in a hash
sub getTabbedDateFromDate($)
{
	# get the param
	my $date = shift;
	# variables
	my %ret;
	
	# try to pattern match
	if ($date =~ m/^\[($RE_DATE_DAY)\/($RE_DATE_MONTH)\/($RE_DATE_YEAR):($RE_DATE_HOUR):($RE_DATE_MINUTE):($RE_DATE_SECOND) ($RE_DATE_TIMEZONE)\]/o)
	{
		#populate to hash 
		$ret{ "DATE_DAY" } = $1 ;
		$ret{ "DATE_MONTH" } = $2 ;
		$ret{ "DATE_YEAR" } = $3 ;
		$ret{ "DATE_HOUR" } = $4 ;
		$ret{ "DATE_MINUTE" } = $5 ;
		$ret{ "DATE_SECOND" } = $6 ;
		$ret{ "DATE_TIMEZONE" } = $7 ;
	} else {
		# logs are not std format
		$ret{ $ERR_HASH } = $ERR_NOTMWSTD;
	}
	# return the hash
	return %ret;
}

##################################
# function printTabbedFields
# arg: Format string (see below)
# arg2: log line
# return log line according to format string
sub printTabbedFields($$)
{
	my $format = shift;
	my $line = shift;

	my %translators = (
	  'h' => 'HOST',
	  'D' => 'DATE',
	  'r' => 'REQUEST',
	  's' => 'STATUS',
	  'o' => 'OBYTES',
	  'R' => 'REFERER',
	  'U' => 'UA'
	);
	my %fields = getTabbedFields($line);

	# XXX error checking
    my $key;
	foreach $key (keys %translators)
	{
	  $format =~ s/\%$key/$fields{$translators{$key}}/g;
	}
	return $format;
}

1;  # Keep require happy

__END__

=head1 NAME

ApacheLogsParser - Package for parsing "standard" Apache logs

=head1 SYNOPSIS

	use ApacheLogsParser

=head1 DESCRIPTION

C<ApacheLogsParser> provides easy access to logs in a standard apache logs.


=head1 FUNCTIONS

=head2 C<getTabbedFields()>

=head4 Usage

C<%hLog=ApacheLogsParser::getTabbedFields($line_of_logs);>

=head4 Arguments

argument should be one apache log line, with std format.

=head4 Return

returns an hash of all fields, where the keys are:

	"HOST"
	"DATE"
	"REQUEST"
	"STATUS"
	"OBYTES"
	"UA"


=head2 C<getHTTPMethod()>

=head4 Usage

C<$sMethod=ApacheLogsParser::getHTTPMethod($line_of_logs);>

=head4 Arguments

argument should be one apache log line, with std format.

=head4 Return

returns the HTTP method used by the client in the request

=head2 C<getURLFull()>

=head4 Usage

C<$sFullUrl=ApacheLogsParser::getURLFull($line_of_logs);>

=head4 Arguments

argument should be one apache log line, with std format.

=head4 Return

returns the full URL (ie page + param) called by the client in the request

=head2 C<getURLPage()>

=head4 Usage

C<$sUrlPage=ApacheLogsParser::getURLPage($line_of_logs);>

=head4 Arguments

argument should be one apache log line, with std format.

=head4 Return

returns the page called by the client in the request

=head2 C<getTabbedURLParam()>

=head4 Usage

C<$hParams=ApacheLogsParser::getTabbedURLParam($line_of_logs);>

=head4 Arguments

argument should be one apache log line, with std format.

=head4 Return

returns a hash of all params of the page page called by the client in the request where the keys are the params name and the values are the associated param value.

=head2 C<getTabbedDate()>

=head4 Usage

C<%hDate=ApacheLogsParser::getTabbedDate($line_of_logs);>

=head4 Arguments

argument should be one apache log line, with std format.

=head4 Return

returns the date in a hash where keys are:

	"DATE_DAY"
	"DATE_MONTH"
	"DATE_YEAR"
	"DATE_HOUR"
	"DATE_MINUTE"
	"DATE_SECOND"
	"DATE_TIMEZONE"


=head2 C<getURLFullFromRequest()>

=head4 Usage

C<$sFullUrl=ApacheLogsParser::getURLFullFromRequest("GET /foo.bar HTTP/1.1");>

=head4 Arguments

argument should be the Request field (ie <methode> <url[+param]> <version>)

=head4 Return

returns the full URL (ie page + param) called by the client in the request

=head2 C<getURLPageFromRequest()>

=head4 Usage

C<$sUrlPage=ApacheLogsParser::getURLPageFromRequest("GET /foo.bar HTTP/1.1");>

=head4 Arguments

argument should be the Request field (ie <methode> <url[+param]> <version>)

=head4 Return

returns the page called by the client in the request

=head2 C<getTabbedURLParamFromRequest()>

=head4 Usage

C<%hParam=ApacheLogsParser::getTabbedURLParamFromRequest("GET /foo.bar?param=value HTTP/1.1");>

=head4 Arguments

argument should be the Request field (ie <methode> <url[+param]> <version>)

=head4 Return

returns a hash of all params of the page page called by the client in the request where the keys are the params name and the values are the associated param value.

=head2 C<getTabbedDateFromDate()>

=head4 Usage

C<%hDate=ApacheLogsParser::getTabbedDateFromDate("[01/01/1900:00:00:00 +0100]");>

=head4 Arguments

argument should be the Date field (ie [DAY/MONTH/YEAR:HOUR:MINUTE:SECOND TIMEZONE])

=head4 Return

returns the date in a hash where keys are:

	"DATE_DAY"
	"DATE_MONTH"
	"DATE_YEAR"
	"DATE_HOUR"
	"DATE_MINUTE"
	"DATE_SECOND"
	"DATE_TIMEZONE"


=head2 C<printTabbedFields()>

=head4 Usage

C<$sOutput=ApacheLogsParser::printTabbedFields("%h %u %r", $line_of_logs);>

=head4 Arguments

First argument should be the output Format string (see below)
Second argument should be one apache log line, with std format.

=head4 Return

returns log line according to format string
Here is the format:

	'h' => 'HOST',
	'D' => 'DATE',
	'r' => 'REQUEST',
	's' => 'STATUS',
	'o' => 'OBYTES',
	'U' => 'UA',


=head1 SEE ALSO



=cut
