package AnyEvent::UDPServer;

use strict;
use warnings;
use AnyEvent (); BEGIN { AnyEvent::common_sense }
use IO::Socket;
use Scalar::Util ();
use Carp ();

our $VERSION = '0.01';

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        on_data => undef,
        host   => '127.0.0.1',
        port   => 4000,
        maxlen => 1024,
        %args
    }, $class;

    $self->{server} = IO::Socket::INET->new(
        LocalAddr => $self->{host},
        LocalPort => $self->{port},
        Proto     => 'udp',
        Blocking  => 0
    ) or Carp::croak "Socket could not be created: $!";

    $self->start;

    return $self;
}

sub on_data {
    my ($self, $sub) = @_;

    $self->{on_data} = $sub;
    return;
}

sub start {
    my ($self) = @_;

    Scalar::Util::weaken($self);

    $self->{watcher} = AnyEvent->io(
        fh   => $self->{server},
        poll => 'r',
        cb   => sub {
            my $buf;
            my $retval = $self->{server}->recv($buf, $self->{maxlen});
            if (defined $retval) {
                my $hersockaddr = $self->{server}->peername;
                my ($port, $iaddr) = sockaddr_in($hersockaddr);
                my $herstraddr = inet_ntoa($iaddr);
                if (defined $self->{on_data}) {
                    my $client = {
                        addr => $herstraddr,
                        port => $port,
                    };
                    $self->{on_data}->($self, $client, $buf);
                }
            }
        },
    );
    return;
}

sub get_watcher {
    my ($self) = @_;

    return $self->{watcher};
}

sub stop {
    my ($self) = @_;

    undef $self->{watcher};
    return;
}

1;
__END__

=head1 NAME

AnyEvent::UDPServer -

=head1 SYNOPSIS

  use AnyEvent::UDPServer;

=head1 DESCRIPTION

AnyEvent::UDPServer is

=head1 AUTHOR

Nao Iizuka E<lt>iizuka@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
