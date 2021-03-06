use strict;
use Test::More tests => 18;
use AnyEvent::UDPServer;
use Encode;
use FindBin;
use Path::Class;
use utf8;

my $expected_data;
my $cv = AE::cv;

my $server = AnyEvent::UDPServer->new(
    maxlen  => 1024,
    port    => 4000,
    on_data => sub {
        my ($self, $remote, $data) = @_;

        is $remote->{addr}, '127.0.0.1';
        isnt $remote->{port}, 4000;
        is $data, $expected_data;
        $cv->send;
    },
);

my $client = IO::Socket::INET->new(
    PeerAddr => '127.0.0.1',
    PeerPort => 4000,
    Proto    => 'udp',
) or die "Could not create socket: $!";

$expected_data = 'hello world';
$client->send($expected_data) or die "Send error: $!";

$cv->recv;
$cv = AE::cv;

$expected_data = encode('utf8', 'あのイーハトーヴォのすきとほった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモーリオ市、郊外のぎらぎらひかる草の波');
$client->send($expected_data) or die "Send error: $!";

$cv->recv;
$cv = AE::cv;

$expected_data = '01234567' x 128;  # 1024 characters
$client->send($expected_data.'abc') or die "Send error: $!";

$cv->recv;
$cv = AE::cv;

$expected_data = "\0";
$client->send($expected_data) or die "Send error: $!";

$cv->recv;
$cv = AE::cv;

$expected_data = ' ';
$client->send($expected_data) or die "Send error: $!";

$cv->recv;
$cv = AE::cv;

$expected_data = dir($FindBin::Bin)->file('blank.gif')->slurp;
$client->send($expected_data) or die "Send error: $!";

$cv->recv;
