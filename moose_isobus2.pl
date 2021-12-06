#!C:\strawberry-perl-5.32.1.1-64bit\perl\bin
use v5.20;
use Lab::Moose;

use Lab::Moose::Connection::VISA_GPIB;

my $connection = Lab::Moose::Connection::VISA_GPIB->new(pad => 24);

my $ITC = instrument(
	type => 'OI_ITC503', 
	connection_type => 'IsoBus', 
	connection_options => {
		base_connection => $connection,
		isobus_address => 0
	}
);

my $IPS = instrument(
	type => 'OI_IPS', 
	connection_type => 'IsoBus', 
	connection_options => {
		base_connection => $connection,
		isobus_address => 2
	},
	max_field_rates => [0.2, 0.1],
	max_fields => [0.1, 0.2],
);

