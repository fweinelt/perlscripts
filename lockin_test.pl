#!C:\strawberry-perl-5.32.1.1-64bit\perl\bin
use v5.20;
use Lab::Moose;
use Data::Dumper;

# The devices won't jump from one voltage level to another, they always sweep there.
# Define the minimum and maximum allowed oscillation amplitude for the measurement
my $lockin_min_amplitude = 0; # [V]
my $lockin_max_amplitude = 1; # [V]

# Specify the Lock-Ins step size to use as well as the sweep speed
my $lockin_max_units_per_second = 1; # [V/s]
my $lockin_max_units_per_step = 0.01; # [V]

#Einstellung und Initialsierung von Lock-In 1
my $LOCKIN_I = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 10
    }
);

my $BACKGATE = instrument(
    type => 'Keithley2400',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 30,
    },
	max_units_per_second => 0.5,
    max_units_per_step => 0.001,
    min_units => -10,
    max_units => 10
);

my $LAKE = instrument(
    type => 'Lakeshore340',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 12
    }
);

say $LAKE->get_T();
