package Data::DTO::GELF;

# ABSTRACT: The DTO object for GELF version 1.1
# VERSION 1.4
our $VERSION=1.4;
use strict;
use warnings;

use Moose;
use namespace::autoclean;

use JSON::Tiny qw(encode_json);
use Sys::Hostname;
use Data::UUID;
use POSIX qw(strftime);

use Log::Log4perl;

use Data::DTO::GELF::Types qw( LogLevel );
use Devel::StackTrace;

our $GELF_VERSION = 1.1;

has 'version' => (
    is      => 'ro',
    isa     => 'Str',
    builder => '_build_version',
);

has 'host' => (
    is      => 'rw',
    isa     => 'Str',
    builder => '_build_host',
);

has 'short_message' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    builder => '_long_to_short'
);

has 'full_message' => (
    is  => 'rw',
    isa => 'Str',
);

has 'timestamp' => (
    is      => 'ro',
    isa     => 'Int',
    builder => '_build_timestamp',
);

has 'level' => (
    is     => 'ro',
    isa    => LogLevel,
    coerce => 1,
);
has '_facility' => (
    is  => 'rw',
    isa => 'Str',
);

has '_line' => (
    is  => 'rw',
    isa => 'Int',
);

has '_file' => (
    is  => 'rw',
    isa => 'Str',
);

sub BUILD {
    my $self = shift;
    my $args = shift;
    foreach my $key1 ( keys $args ) {
        if ( ( substr $key1, 0, 1 ) eq "_" ) {
            $self->meta->add_attribute( "$key1" => ( accessor => $key1 ) );
            $self->meta->get_attribute($key1)
                ->set_value( $self, $args->{$key1} );
        }
    }

    
 
my $trace = Devel::StackTrace->new;
foreach my $frame($trace->frames)
{
    if($frame->{subroutine} eq "Log::Log4perl::Logger::__ANON__")
    {
    $self->_line($frame->{line});
    $self->_file( $frame->{filename});
    $self->_facility($frame->{package});
    }
}



}

sub _build_version {
    my $self = shift;
    return "$GELF_VERSION";
}

sub _build_host {
    my $self = shift;
    return hostname();
}

sub _build_timestamp {
    my $self = shift;
    return time();
}

sub message {
    my $self = shift;
    my $m    = shift;
    if ( defined $m ) {
        $self->full_message($m);
    }
    else {
        return $self->full_message();
    }

    return;
}

sub _long_to_short {
    my $self = shift;
    my $msg = substr $self->full_message(), 0, 50;
    $msg =~ s/\n.*//s;
    return $msg;
}
sub TO_HASH {
    my $self = shift;
    { $self->short_message() }    #fire off lazy message builder
    return {%$self};
}
sub TO_JSON {
    my $self = shift;
    { $self->short_message() }    #fire off lazy message builder
    return {%$self};
}

1;

