use v5.20;
use warnings;
use strict;

use Lab::Moose;
use Carp;

use Lab::Moose::Connection::VISA_GPIB;


my $isobus = Lab::Moose::Connection::VISA_GPIB->new(pad => 24);

#Einstellung und Initialsierung von Magnet
my $IPS = instrument(
	type => 'OI_IPS',
	connection_type => 'IsoBus',
	connection_options => {
		base_connection => $isobus,
		isobus_address => 2
	},
	max_field_rates => [2],
	max_fields => [1],
);

$IPS->set_switch_heater(value => 1);
# my $ILM = Instrument('ILM', {connection => Connection('IsoBus', {base_connection => $isobus,isobus_address => 6})
	# });

#----------------------------------------------------------------------------------------------------------------------------------

my $magnet_sweep = sweep(
		  type       => 'Continuous::Magnet',
		  instrument => $IPS,
		  points => [-0.1, 0],										#Von Starwert in Volt zu Endwert in Volt
		  # points => [5, 8],										#Von Starwert in Volt zu Endwert in Volt
		  rates => [0.8 ,0.1],											#Rate (max. 0.5!!!) gibt die Geschwindigkeit (T/Minute) and wie schnell zum n�chsten Step gesweept wird
		  delay_before_loop => 5,
			  backsweep => 0,
				);
		
my $datafile = sweep_datafile(
	columns => [qw/B/]);
		
		
my $meas = sub {	
		my $sweep = shift;
		my $f = $IPS->get_field();
		$sweep->log(
			B => $f
		);
	};
	 
	$magnet_sweep->start(
		measurement => $meas,
		datafile    => $datafile,
	);