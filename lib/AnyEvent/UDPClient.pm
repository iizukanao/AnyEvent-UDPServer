package AnyEvent::UDPClient;

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
        host        => undef,
        port        => undef,
        on_complete => undef,
        %args
    }, $class;

    $self->init;

    return $self;
}

sub init {
    my ($self) = @_;

    $self->{client} = IO::Socket::INET->new(
        PeerAddr => $self->{host},
        PeerPort => $self->{port},
        Proto    => 'udp',
        Blocking => 0,
    ) or die "Could not create socket: $!";
    return;
}

sub send {
    my ($self, $data) = @_;

    unless ( $self->{client} ) {
        $self->init;
    }

    $self->{client}->send($data);

    Scalar::Util::weaken($self);

    my $w; $w = AnyEvent->io(
        fh   => $self->{client},
        poll => 'w',
        cb   => sub {
            undef $w;
            if (defined $self->{on_complete}) {
                $self->{on_complete}->($self);
            }
        },
    );
    return 1;
}

1;
__END__

=head1 NAME

AnyEvent::UDPClient -

=head1 SYNOPSIS

  use AnyEvent::UDPClient;

=head1 DESCRIPTION

AnyEvent::UDPClient is

=head1 AUTHOR

Nao Iizuka E<lt>iizuka@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
