package Log::Log4perl::Appender::Graylog;
our @ISA = qw(Log::Log4perl::Appender);

use strict;
use warnings;



use JSON -convert_blessed_universally;
use Sys::Hostname;
use Data::UUID;
use POSIX qw(strftime);
use IO::Socket;
use Data::DTO::GELF;

##################################################
# Log dispatcher writing to a string buffer
##################################################
# cmd line example echo -n '{ "version": "1.1", "host": "example.org", "short_message": "A short message", "level": 5, "_some_info": "foo" }' | nc -w0 -u graylog.xo.gy 12201
##################################################
sub new {
##################################################
    my $proto  = shift;
    my $class  = ref $proto || $proto;
    my %params = @_;

    my $self = {
        name     => "unknown name",
        PeerAddr => "",
        PeerPort => "",
        %params,
    };

    bless $self, $class;
}

##################################################
sub log {
##################################################
    my $self   = shift;
    my %params = @_;

    my $packet = Data::DTO::GELF->new(
        'full_message' => $params{'message'},
        'level'        => $params{level},
        'host'         => $params{server} || $params{host} || hostname(),
        '_uuid'        => Data::UUID->new()->create_str(),
        '_name'        => $params{name},
        '_category'    => $params{log4p_category},
        "_pid"         => $$,

    );

    my $json = JSON->new->utf8->space_after->allow_nonref->convert_blessed;
    my $j_packet = $json->encode($packet);

    my $socket = IO::Socket::INET->new(
        PeerAddr => "$self->{'PeerAddr'}",
        PeerPort => $self->{'PeerPort'},
        Type     => SOCK_DGRAM,
        Proto    => 'udp'
    ) or die "Socket error";
    $socket->send( $j_packet . "\n" );

    $socket->close();

}

1;
