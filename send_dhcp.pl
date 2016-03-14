#!/usr/bin/perl

=head1 SYNOPSIS

Craft a DHCP packet and send the DHCPREQUEST and DHCPACK on the network

=cut

use warnings;
use strict;
use IO::Socket::INET;
use Net::DHCP::Packet;
use Net::DHCP::Constants;
use Getopt::Long;

my %options = ();
GetOptions (
  \%options,
  "h!",
  "mac=s",
  "ip=s",
  "hostname=s",
  "dhcp-fingerprint=s",
  "dhcp-vendor=s",
  "ack!",
) || die("Invalid options");

$options{mac} =~ s/://g;
$options{mac} = uc($options{mac});

send_packet();
send_packet(1);

sub send_packet {
    my ($ack) = @_;
    my $dhcpreq = new Net::DHCP::Packet(
        Op => $ack ? BOOTREPLY() : BOOTREQUEST(),
        Htype => HTYPE_ETHER(),
        Hops => '0',
        Xid => 0x2d5c8bd7,
        Flags => '0',
        Ciaddr => '0.0.0.0',
        Yiaddr => $options{ip},
        Siaddr => '10.0.0.10',
        Giaddr => '172.21.2.1',
        Chaddr => $options{mac},
        DHO_DHCP_MESSAGE_TYPE() => $ack ? DHCPACK() : DHCPREQUEST(),
        );

    $dhcpreq->addOptionValue(DHO_DHCP_REQUESTED_ADDRESS() , $options{ip});
    $dhcpreq->addOptionValue(DHO_DHCP_MAX_MESSAGE_SIZE() ,'1500');
    $dhcpreq->addOptionValue(DHO_VENDOR_CLASS_IDENTIFIER() , $options{'dhcp-vendor'});
    $dhcpreq->addOptionValue(DHO_HOST_NAME() , $options{hostname});
    $dhcpreq->addOptionValue(DHO_DHCP_PARAMETER_REQUEST_LIST() , join(' ', split(',', $options{'dhcp-fingerprint'})));

    my $sock_in = IO::Socket::INET->new(Type => SOCK_DGRAM, Reuse => 1, LocalPort => 68, Proto => 'udp',Broadcast => 1,PeerAddr => '172.20.20.109:67');
# Send the packet to the network
    $sock_in->send($dhcpreq->serialize());
}
