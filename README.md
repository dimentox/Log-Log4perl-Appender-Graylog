# NAME

Log::Log4perl::Appender::Graylog; - Log to a Graylog server

# SYNOPSIS

       use Log::Log4perl::Appender::Graylog;
    
       my $appender = Log::Log4perl::Appender::Graylog->new(
         PeerAddr => "glog.foo.com",
         PeerPort => 12209,
         Gzip => 1, # Glog2 usually requires gzip but can send plain text
       );
    
       $appender->log(message => "Log me\n");
    
       or
       log4perl.appender.SERVER          = Log::Log4perl::Appender::Graylog
       log4perl.appender.SERVER.layout = NoopLayout
       log4perl.appender.SERVER.PeerAddr = <ip>
       log4perl.appender.SERVER.PeerPort = 12201
       log4perl.appender.SERVER.Gzip    = 1
    

# DESCRIPTION

This is a simple appender for writing to a graylog server.

    It relies on L<IO::Socket::INET>. L<Log::GELF::Util>. This sends in the 1.1
    format. 

# CONFIG

       log4perl.appender.SERVER          = Log::Log4perl::Appender::Graylog
       log4perl.appender.SERVER.layout = NoopLayout
       log4perl.appender.SERVER.PeerAddr = <ip>
       log4perl.appender.SERVER.PeerPort = 12201
       log4perl.appender.SERVER.Gzip    = 1
       log4perl.appender.SERVER.Chunked = <0|lan|wan> 
       
           layout This needs to be NoopLayout as we do not want any special formatting.
           Gzip Accepts an integer specifying if to compress the message. 
           Chunked Accepts an integer specifying the chunk size or the special string values lan or wan corresponding to 8154 or 1420 respectively.
    

# EXAMPLE

Write a server quickly using the IO::Socket:
(based on orelly-perl-cookbook-ch17)

       use strict;
       use IO::Socket;
       my($sock, $oldmsg, $newmsg, $hisaddr, $hishost, $MAXLEN, $PORTNO);
       $MAXLEN = 8192;
       $PORTNO = 12201;
       $sock = IO::Socket::INET->new(LocalPort => $PORTNO, Proto => 'udp')
           or die "socket: $@";
       print "Awaiting UDP messages on port $PORTNO\n";
       $oldmsg = "This is the starting message.";
       while ($sock->recv($newmsg, $MAXLEN)) {
           my($port, $ipaddr) = sockaddr_in($sock->peername);
           $hishost = gethostbyaddr($ipaddr, AF_INET);
           print "Client $hishost said ``$newmsg''\n";
           $sock->send($oldmsg);
           $oldmsg = "[$hishost] $newmsg";
       } 
       die "recv: $!";
    

Start it and then run the following script as a client:

       use Log::Log4perl qw(:easy);
       my $conf = q{
               log4perl.category                  = WARN, Graylog
               log4perl.appender.Graylog           = Log::Log4perl::Appender::Graylog
               log4perl.appender.Graylog.PeerAddr  = localhost
               log4perl.appender.Graylog.PeerPort  = 12201
               log4perl.appender.Graylog.layout    = SimpleLayout
               
           };
       
       Log::Log4perl->init( \$conf );
       
       sleep(2);
       
       for ( 1 .. 10 ) {
           ERROR("Quack!");
           sleep(5);
       }
    

# COPYRIGHT AND LICENSE

Copyright 2017 by Brandon "Dimentox Travanti" Husbands <xotmid@gmail.com> 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 
