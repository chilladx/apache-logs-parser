# NAME

ApacheLogsParser - Package for parsing "standard" Apache logs

# SYNOPSIS

	use ApacheLogsParser

# DESCRIPTION

`ApacheLogsParser` provides easy access to logs in a standard apache logs.


FUNCTIONS
=========
## `getTabbedFields()`

#### Usage

`%hLog=ApacheLogsParser::getTabbedFields($line_of_logs);`

#### Arguments

argument should be one apache log line, with std format.

#### Return

returns an hash of all fields, where the keys are:

	"HOST"
	"DATE"
	"REQUEST"
	"STATUS"
	"OBYTES"
	"UA"


## `getHTTPMethod()`

#### Usage

`$sMethod=ApacheLogsParser::getHTTPMethod($line_of_logs);`

#### Arguments

argument should be one apache log line, with std format.

#### Return

returns the HTTP method used by the client in the request

## `getURLFull()`

#### Usage

`$sFullUrl=ApacheLogsParser::getURLFull($line_of_logs);`

#### Arguments

argument should be one apache log line, with std format.

#### Return

returns the full URL (ie page + param) called by the client in the request

## `getURLPage()`

#### Usage

`$sUrlPage=ApacheLogsParser::getURLPage($line_of_logs);`

#### Arguments

argument should be one apache log line, with std format.

#### Return

returns the page called by the client in the request

## `getTabbedURLParam()`

#### Usage

`$hParams=ApacheLogsParser::getTabbedURLParam($line_of_logs);`

#### Arguments

argument should be one apache log line, with std format.

#### Return

returns a hash of all params of the page page called by the client in the request where the keys are the params name and the values are the associated param value.

## `getTabbedDate()`

#### Usage

`%hDate=ApacheLogsParser::getTabbedDate($line_of_logs);`

#### Arguments

argument should be one apache log line, with std format.

#### Return

returns the date in a hash where keys are:

	"DATE_DAY"
	"DATE_MONTH"
	"DATE_YEAR"
	"DATE_HOUR"
	"DATE_MINUTE"
	"DATE_SECOND"
	"DATE_TIMEZONE"


## `getURLFullFromRequest()`

#### Usage

`$sFullUrl=ApacheLogsParser::getURLFullFromRequest("GET /foo.bar HTTP/1.1");`

#### Arguments

argument should be the Request field (ie <methode> <url[+param]> <version>)

#### Return

returns the full URL (ie page + param) called by the client in the request

## `getURLPageFromRequest()`

#### Usage

`$sUrlPage=ApacheLogsParser::getURLPageFromRequest("GET /foo.bar HTTP/1.1");`

#### Arguments

argument should be the Request field (ie <methode> <url[+param]> <version>)

#### Return

returns the page called by the client in the request

## `getTabbedURLParamFromRequest()`

#### Usage

`%hParam=ApacheLogsParser::getTabbedURLParamFromRequest("GET /foo.bar?param=value HTTP/1.1");`

#### Arguments

argument should be the Request field (ie <methode> <url[+param]> <version>)

#### Return

returns a hash of all params of the page page called by the client in the request where the keys are the params name and the values are the associated param value.

## `getTabbedDateFromDate()`

#### Usage

`%hDate=ApacheLogsParser::getTabbedDateFromDate("[01/01/1900:00:00:00 +0100]");`

#### Arguments

argument should be the Date field (ie [DAY/MONTH/YEAR:HOUR:MINUTE:SECOND TIMEZONE])

#### Return

returns the date in a hash where keys are:

	"DATE_DAY"
	"DATE_MONTH"
	"DATE_YEAR"
	"DATE_HOUR"
	"DATE_MINUTE"
	"DATE_SECOND"
	"DATE_TIMEZONE"


## `printTabbedFields()`

#### Usage

`$sOutput=ApacheLogsParser::printTabbedFields("%h %u %r", $line_of_logs);`

#### Arguments

First argument should be the output Format string (see below)
Second argument should be one apache log line, with std format.

#### Return

returns log line according to format string
Here is the format:

	'h' => 'HOST',
	'D' => 'DATE',
	'r' => 'REQUEST',
	's' => 'STATUS',
	'o' => 'OBYTES',
	'U' => 'UA',


# SEE ALSO
