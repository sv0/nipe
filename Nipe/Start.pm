#!/usr/bin/perl

#########################################################
# Nipe developed by Heitor Gouvea                       #
# This work is licensed under MIT License               #
# Copyright (c) 2015-2016 Heitor Gouvea                 #
#                                                       #
# [+] AUTOR:        Heitor Gouvea                       #
# [+] EMAIL:        hi@heitorgouvea.me                  #
# [+] GITHUB:       https://github.com/GouveaHeitor     #
# [+] TWITTER:      https://twitter.com/GouveaHeitor    #
# [+] FACEBOOK:     https://fb.com/GouveaHeitor         #
#########################################################

package Nipe::Start;

my $os = `cat /etc/os-release | grep 'ID' | cut -d '=' -f 2`;
my $username;

if    ($os =~ /[U,u]buntu/) { $username = "debian-tor"; }
elsif ($os =~ /[D,d]ebian/) { $username = "debian-tor"; }
elsif ($os =~ /[F,f]edora/) { $username = "toranon"; }
elsif ($os =~ /[A,a]rch/)   { $username = "tor"; }
else  { $username = "tor"; }


sub new {
	my $dns_port   = "9061";
	my $trans_port = "9051";
	my @table      = ("nat","filter");
	my $network    = "10.66.0.0/255.255.0.0";

	foreach my $nipe(@table) {
		my $target = "ACCEPT";

		if ($nipe eq "nat") {
			$target = "RETURN";
		}

		system ("sudo iptables -t $nipe -F OUTPUT");
		system ("sudo iptables -t $nipe -A OUTPUT -m state --state ESTABLISHED -j $target");
		system ("sudo iptables -t $nipe -A OUTPUT -m owner --uid $username -j $target");

		my $match_dns_port = $dns_port;

		if ($nipe eq "nat") {
			$target = "REDIRECT --to-ports $dns_port";
			$match_dns_port = "53";
		}

		system ("sudo iptables -t $nipe -A OUTPUT -p udp --dport $match_dns_port -j $target");
		system ("sudo iptables -t $nipe -A OUTPUT -p tcp --dport $match_dns_port -j $target");

		if ($nipe eq "nat") {
			$target = "REDIRECT --to-ports $trans_port";
		}

		system ("sudo iptables -t $nipe -A OUTPUT -d $network -p tcp -j $target");

		if ($nipe eq "nat") {
			$target = "RETURN";
		}

		system ("sudo iptables -t $nipe -A OUTPUT -d 127.0.0.1/8    -j $target");
		system ("sudo iptables -t $nipe -A OUTPUT -d 192.168.0.0/16 -j $target");
		system ("sudo iptables -t $nipe -A OUTPUT -d 172.16.0.0/12  -j $target");
		system ("sudo iptables -t $nipe -A OUTPUT -d 10.0.0.0/8     -j $target");

		if ($nipe eq "nat") {
			$target = "REDIRECT --to-ports $trans_port";
		}

		system ("sudo iptables -t $nipe -A OUTPUT -p tcp -j $target");
	}

	system ("sudo iptables -t filter -A OUTPUT -p udp -j REJECT");
	system ("sudo iptables -t filter -A OUTPUT -p icmp -j REJECT");

	Nipe::Check -> new;
}

1;