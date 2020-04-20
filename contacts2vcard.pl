#! /usr/bin/perl -w

# Copyright (C) 2020 Thomas More (tmore1@gmx.com)
# contacts2vcard is free software, released under the terms of the Clarified  Artistic
# License (1.0), contained in the included file 'LICENSE'
# contacts2vcard comes with ABSOLUTELY NO WARRANTY
# contacts2vcard is available at https://github.com/tmo1/contacts2vcard
# contacts2vcard is documented in its README

# contacts2vcard was designed based on the very helpful (unofficial)
# documentation of the Android contacts database ('contacts2.db')
# at https://www.dev2qa.com/android-contacts-database-structure/
# and https://www.dev2qa.com/android-contacts-fields-data-table-columns-and-data-mimetype-explain/

use Getopt::Std;

use DBI;
use DBD::SQLite::Constants qw/:extended_result_codes/;
use vCard;

use strict;

# configuration and setup

my %opts;
getopts('a:d:v:', \%opts);
$opts{'d'} //= "contacts2.db";
$opts{'a'} //= "address_book.vcf";

my %vcards;
my %mimetypes = (1 => \&email_v2, 5 => \&phone_v2, 7 => \&name); # taken from the 'mimetypes' table in 'contacts2.db', explained here https://www.dev2qa.com/android-contacts-fields-data-table-columns-and-data-mimetype-explain/ 
my %email_v2_types = (1 => 'home', 2 => 'work', 3 => 'other', 4 => 'mobile');

# read database

my $dbh = DBI->connect("dbi:SQLite:$opts{'d'}", undef, undef, {RaiseError => 1, PrintError => 0, AutoCommit => 0, sqlite_extended_result_codes => 1});
my $data = $dbh->selectall_arrayref("SELECT * FROM data");

# process all database rows and create vCards

foreach (@{$data}) {
	if (exists $mimetypes{${$_}[2]}) {
		unless (exists $vcards{${$_}[3]}) {
			$vcards{${$_}[3]} = vCard->new;
			if ($opts{'v'}) {$vcards{${$_}[3]}->version($opts{'v'})}
		}
		&{$mimetypes{${$_}[2]}}($_);
		#print "Row ${$_}[0] successfully processed.\n";
	}
}

# create and write address book

my $address_book = vCard::AddressBook->new();
foreach (values %vcards) {
	unless (eval {$address_book->load_string($_->as_string)}) {
		print "vCard processing failed for:\n\n", $_->as_string, "\n$@This may be due to contact information that does not convert to a valid (RFC 6350) vCard.\n";
	}
}
$address_book->as_file($opts{'a'});

# done!
	
sub email_v2 {
	my $row = shift;
	my $vcard = $vcards{@{$row}[3]};
	my @previous_addresses;
	if (my $a = $vcard->email_addresses) {@previous_addresses = @{$a}}
	$vcard->email_addresses([@previous_addresses, {type => [$email_v2_types{@{$row}[10]}], address => @{$row}[9]}]); # we (currently?) ignore email display name (data4)
	
}

sub phone_v2 {
	my $row = shift;
	my $vcard = $vcards{@{$row}[3]};
	my @previous_phones;
	if (my $p = $vcard->phones) {@previous_phones = @{$p}}
	$vcard->phones([@previous_phones, {type => [@{$row}[10]], number => @{$row}[9]}]);
}

sub name {
	my $row = shift;
	my $vcard = $vcards{@{$row}[3]};
	$vcard->full_name(@{$row}[9] // "");
	$vcard->given_names([@{$row}[10] // ""]);
	$vcard->family_names([@{$row}[11] // ""]); # we (currently?) ignore prefix, middle name, and suffix (data4, data5, data6)
}
