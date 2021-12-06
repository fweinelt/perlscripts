#!C:/Strawberry/perl
use strict;
use warnings;

use lib 'C:/perllibs/Measurement/lib';
use Lab::Measurement;
use Lab::XPRESS::hub;

my $hub = new Lab::XPRESS::hub();

my $sample = 'BundGateSweep';
=head1


#----------------------------------------------------------------------------------------------------------------------------
#Initialisierung und Einstellung der einzelnen Messgeräte und Magneten
 
#Einstellung und Initialsierung von Gate 1
#my $TOPGATE = Instrument('Keithley2400', {connection_type => 'VISA_GPIB',gpib_address => 26,gate_protect => 0});

#Einstellung und Initialsierung von Gate 2
# my $BACKGATE = Instrument('Yokogawa7651', {
	# connection_type => 'VISA_GPIB',
	# gpib_address => 17,
	# gate_protect => 1,
	# 'gp_max_units_per_second' => 0.1, 	# in V/s (?!)
    # 'gp_max_units_per_step' => 0.01,
    # 'gp_min_units' => -50, 
    # 'gp_max_units'  => 50
# });
my $BACKGATE = Instrument('Keithley2400', {connection_type => 'VISA_GPIB',gpib_address => 30,gate_protect => 0});


my $isobus = Connection('VISA_GPIB', {gpib_address => 24});
	
my $ITC = Instrument('ITC', {connection => Connection('IsoBus', {base_connection => $isobus,isobus_address => 0})
	});
	
# my $lake = Instrument('Lakeshore224',{device_settings => {channel_default => 'ChA'}
	# });																															# Für die Temperaturanzeige"

#Einstellung und Initialsierung von Lock-In 1
my $LOCKIN_I = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 16}),});
#Einstellung und Initialsierung von Lock-In 2
my $LOCKIN_U1 = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 17}),});
#Einstellung und Initialsierung von Lock-In 3
my $LOCKIN_U2 = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 10}),});
#Einstellung und Initialsierung von Lock-In 4
my $LOCKIN_U3 = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 14}),});
#Einstellung und Initialsierung von Lock-In 5
my $LOCKIN_U4 = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 15}),});
#Einstellung und Initialsierung von Lock-In 6
my $LOCKIN_U5 = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 8}),});
#Einstellung und Initialsierung von Lock-In 7
my $LOCKIN_U6 = $hub->Instrument('SignalRecovery726x',{connection => $hub->Connection('VISA_GPIB', {gpib_address => 13}),});

#Einstellung und Initialsierung von Magnet
my $IPS = Instrument('IPS', {connection => Connection('IsoBus', {base_connection => $isobus,isobus_address => 2})
	});

=cut







