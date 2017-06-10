package Data::DTO::GELF::Types;

# ABSTRACT: Special types for log level conversion
# VERSION 1.1
our $VERSION=1.1;
use MooseX::Types -declare => [
    qw(
        LogLevel

        )
];

use MooseX::Types::Moose qw/Int Str/;

use Readonly;
Readonly my %LOGLEVEL_MAP => (
    DEBUG     => 0,
    INFO      => 1,
    NOTICE    => 2,
    WARNING   => 3,
    ERROR     => 4,
    CRITICAL  => 5,
    ALERT     => 6,
    EMERGENCY => 8
);

subtype LogLevel, as Int;

coerce LogLevel, from Str, via { $LOGLEVEL_MAP{ uc $_ } // $_; };

1;
