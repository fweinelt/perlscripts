use v5.20;
use warnings;
use strict;

use Lab::Moose;
use POSIX qw/ceil floor/;
use List::Util qw/min max sum/;
use Math::Trig;
use Carp;

### Define all necessary parameters here

# Behind every parameter you will find the corresponding unit in square brackets

# Value of reference resistor
my $R_REF = 100000; # [Ω]

# Number of points per measurement
my $number_of_points = 10; # []

# Delay between measurement points
my $delay_between_points = 0.33; # [s]

# This script implements a method called the simple moving average, it basically
# averages a number of data points in an effort to reduce noise. The amount of
# points to be averaged is called the window and can be specified below.
# see https://en.wikipedia.org/wiki/Moving_average for more information.

# moving average window size, recommended to be around 10% of $number_of_points
my $window = 1; # []

# the lowest n values to be averaged for determining the global minimum
my $lowest = 1; # []

# how often to repeat a single phase or amplitude sweep
my $repeat_measurement = 1; # []

# Setup the sweep, type can be
#   V_DS -
#   V_GS - gate voltage sweep
#   V_DUT - device under test voltage sweep
#   Frequency - lock-in frequency sweep
# Depending on the sweep type, the corresponding parameter will simply be ignored
# when setting the DC voltages or the frequency.
# The from, to and step parameters are in volts, when sweeping V_DUT, V_GS or V_DS
# and in Hertz, when sweeping the frequency.
my %sweep_setup = (
    type => 'V_GS',
    from => -2.5,
    to =>   -3,
    step => 0.25
);

# Below you define the ranges, in which the minimum is searched for.
# Example:
#   my @pha_range = (360, 250, 150, 100, 50, 30, 10, 5, 1);
#   -> First measurement will go from 0 to 360°
#   -> Second one in a range of 250° around the minumum, so at the minimum +-125°
#      Suppose the current minimum is at 175°, the measurement will go from 50° to 300°
#
# - In each range, there will be $number_of_points data points recorded
# - The first sweep will always be from 0 to the first value given in @pha_range and @amp_range respectively
# - It is recommended to start the @phase_range with 360°
# - You don't have to input the same amount of values in the two ranges, there will be
#   as many iterations as maximum range values. Once the first range reaches its lowest
#   value but the second range still has some steps to go, the lowest value of the first
#   range will be used for the remaining measurements

my @pha_range = (360, 50); # [°]
my @amp_range = (0.1, 0.05); # [V]


### SIGNAL RECOVERY LOCK-IN AMPLIFIERS ###

# Oscillation amplitude of the Lock-Ins, the U_osc_ref will be sweeped to determine
# the minimum
my $U_OSC_DUT = 1; # [V]
my $U_OSC_OUT = 0; # [V]

# Lock-In frequency
my $initial_dut_frq = 2005; # [Hz]

# lock-in time constant, accepted values are
# 10us 20us 40us 80us 160us 320us 640us 5ms 10ms 20ms 50ms 100ms 200ms 500ms
# 1 2 5 10 20 50 100 200 500 1ks 2ks 5ks 10ks 20ks 50ks 100ks
my $initial_tc = '500ms';

# The devices won't jump from one voltage level to another, they always sweep there.
# Define the minimum and maximum allowed oscillation amplitude for the measurement
my $lockin_min_amplitude = 0; # [V]
my $lockin_max_amplitude = 1; # [V]

# Specify the Lock-Ins step size to use as well as the sweep speed
my $lockin_max_units_per_second = 1; # [V/s]
my $lockin_max_units_per_step = 0.001; # [V]


### YOKOGAWA DC VOLTAGE SOURCES

# Define a speed as well as step for the Yokos voltage changes
my $yoko_max_units_per_second = 0.33; # [V/s]
my $yoko_max_units_per_step = 0.001; # [V]

# Set the Yoko DC voltages
my $V_DS = 0.5; # [V]
my $V_DS_min_amplitude = 0; # [V]
my $V_DS_max_amplitude = 0.5; # [V]

my $V_GS = -2.87; # [V]
my $V_GS_min_amplitude = -3; # [V]
my $V_GS_max_amplitude = 0; # [V]

my $V_DUT = 0; # [V]
my $V_DUT_min_amplitude = 0; # [V]
my $V_DUT_max_amplitude = 0; # [V]


### Initialization of the devices

my $connection = 'VISA::GPIB';

my $LOCKIN_REF = instrument(
    type => 'SignalRecovery7265',
    connection_type => $connection,
    connection_options => {
        pad => 14
    },
    max_units_per_second => $lockin_max_units_per_second,
    max_units_per_step => $lockin_max_units_per_step,
    min_units => $lockin_min_amplitude,
    max_units => $lockin_max_amplitude
);

my $LOCKIN_DUT = instrument(
    type => 'SignalRecovery7265',
    connection_type => $connection,
    connection_options => {
        pad =>  10
    },
    max_units_per_second => $lockin_max_units_per_second,
    max_units_per_step => $lockin_max_units_per_step,
    min_units => $lockin_min_amplitude,
    max_units => $lockin_max_amplitude
);

my $LOCKIN_OUT = instrument(
    type => 'SignalRecovery7265',
    connection_type => $connection,
    connection_options => {
        pad => 15
    },
    max_units_per_second => $lockin_max_units_per_second,
    max_units_per_step => $lockin_max_units_per_step,
    min_units => $lockin_min_amplitude,
    max_units => $lockin_max_amplitude
);

my $YOKO_V_DS = instrument(
    type => 'Yokogawa7651',
    connection_type => $connection,
    connection_options => {
        pad => 7
    },
    max_units_per_second => $yoko_max_units_per_second,
    max_units_per_step => $yoko_max_units_per_step,
    min_units => $V_DS_min_amplitude,
    max_units => $V_DS_max_amplitude
);

my $YOKO_V_GS = instrument(
    type => 'Yokogawa7651',
    connection_type => $connection,
    connection_options => {
        pad => 5
    },
    max_units_per_second => $yoko_max_units_per_second,
    max_units_per_step => $yoko_max_units_per_step,
    min_units => $V_GS_min_amplitude,
    max_units => $V_GS_max_amplitude
);

my $YOKO_V_DUT = instrument(
    type => 'Yokogawa7651',
    connection_type => $connection,
    connection_options => {
        pad => 4
    },
    max_units_per_second => $yoko_max_units_per_second,
    max_units_per_step => $yoko_max_units_per_step,
    min_units => $V_DUT_min_amplitude,
    max_units => $V_DUT_max_amplitude
);

my $AGILENT_I_D = instrument(
    type => 'Agilent34410A',
    connection_type => $connection,
    connection_options => {
        pad => 22
    },
);

# Safety measure
if ($U_OSC_DUT == 0) {
	croak 'U_OSC_DUT cannot be 0';
}

# Set some parameters

print "Setting inital parameters...\n";

if ($sweep_setup{type} ne 'V_GS') { $YOKO_V_GS->set_level(value => $V_GS); }
else { $YOKO_V_GS->set_level(value => $sweep_setup{from}); }
if ($sweep_setup{type} ne 'V_DS') { $YOKO_V_DS->set_level(value => $V_DS); }
else { $YOKO_V_DS->set_level(value => $sweep_setup{from}); }
if ($sweep_setup{type} ne 'V_DUT') { $YOKO_V_DUT->set_level(value => $V_DUT); }
else { $YOKO_V_DUT->set_level(value => $sweep_setup{from}); }
if ($sweep_setup{type} ne 'Frequency') {
    $LOCKIN_DUT->set_frq(value => $initial_dut_frq);
    $LOCKIN_OUT->set_frq(value => $initial_dut_frq);
    $LOCKIN_REF->set_frq(value => $initial_dut_frq);
}
else {
    $LOCKIN_DUT->set_frq(value => $sweep_setup{from});
    $LOCKIN_OUT->set_frq(value => $sweep_setup{from});
    $LOCKIN_REF->set_frq(value => $sweep_setup{from});
}

$LOCKIN_REF->set_tc(value => $initial_tc);
$LOCKIN_DUT->set_tc(value => $initial_tc);
$LOCKIN_OUT->set_tc(value => $initial_tc);
$LOCKIN_DUT->set_level(value => $U_OSC_DUT); # defines the DUT voltage amplitude - do not set to zero or the amplitude ratio will go to infinity
$LOCKIN_REF->set_level(value => $amp_range[0]);
$LOCKIN_OUT->set_level(value => $U_OSC_OUT);
$LOCKIN_REF->set_phase(value => 0);

$AGILENT_I_D->sense_function(value => 'CURR');

print "Inital parameters set\n";

# Create the datafiles

my $columns = [qw/
    U_ac_out
    U_osc_ref
    Pha_ref
    U_osc_dut
    R_ref
    V_DS
    V_GS
    V_DUT
    I_D
    FRQ
/];

my $folder = datafolder(path => $sweep_setup{type}.'_Sweep', time_prefix => 0);

### DEFINE THE SWEEPS

my $main_sweep;

# Depending on the sweep type, the main sweep is defined for the corresponding device
if ($sweep_setup{type} eq 'Frequency') {
    $main_sweep = sweep(
      type       => 'Step::Frequency',
      instrument => [$LOCKIN_REF, $LOCKIN_DUT, $LOCKIN_OUT],
      from => $sweep_setup{from}, to => $sweep_setup{to}, step => $sweep_setup{step},
      delay_before_loop => 3,
      delay_in_loop => 5
    );
} elsif ($sweep_setup{type} eq 'V_DS') {
    $main_sweep = sweep(
      type       => 'Step::Voltage',
      instrument => $YOKO_V_DS,
      from => $sweep_setup{from}, to => $sweep_setup{to}, step => $sweep_setup{step},
      delay_before_loop => 3,
      delay_in_loop => 5,
    );
} elsif ($sweep_setup{type} eq 'V_GS') {
    $main_sweep = sweep(
      type       => 'Step::Voltage',
      instrument => $YOKO_V_GS,
      from => $sweep_setup{from}, to => $sweep_setup{to}, step => $sweep_setup{step},
      delay_before_loop => 3,
      delay_in_loop => 5,
    );
} elsif ($sweep_setup{type} eq 'V_DUT') {
    $main_sweep = sweep(
      type       => 'Step::Voltage',
      instrument => $YOKO_V_DUT,
      from => $sweep_setup{from}, to => $sweep_setup{to}, step => $sweep_setup{step},
      delay_before_loop => 3,
      delay_in_loop => 5,
    );
}

# The general phase sweep for the capacitance measurement...
my $phase_sweep = sweep(
  type       => 'Step::Phase',
  instrument => $LOCKIN_REF,
  from => 0, to => $pha_range[0], step => $pha_range[0]/$number_of_points,
  delay_before_loop => 3,
  delay_in_loop => $delay_between_points,
);

# ...as well as the amplitude sweep.
my $amp_sweep = sweep(
  type       => 'Step::Voltage',
  instrument => $LOCKIN_REF,
  from => 0, to => $amp_range[0], step => $amp_range[0]/$number_of_points,
  delay_before_loop => 3,
  delay_in_loop => $delay_between_points,
);

# Initialize temporary variables
my $currphase;
my $curramp = $amp_range[0];
my $prel;
my $len;
my @sorted_indexes;
my $pha_from = $phase_sweep->{from};
my $pha_to = $phase_sweep->{to};
my $amp_from = $amp_sweep->{from};
my $amp_to = $amp_sweep->{to};
my %pha_results;
my %amp_results;
my $max_phase_amp = 6e-3;
my $max_amp_amp = 5e-3;

# Define the phase measurement routine...
my $phase_measurement = sub {
    my $sweep = shift;
    my $u_ac_out = $LOCKIN_OUT->query(command => "MAG.");
    my $u_osc_ref = $LOCKIN_REF->cached_source_level();
    my $pha_ref = $LOCKIN_REF->cached_refpha();
    my $u_osc_dut = $LOCKIN_DUT->cached_source_level();
    my $v_ds = $YOKO_V_DS->cached_source_level();
    my $v_gs = $YOKO_V_GS->cached_source_level();
    my $v_dut = $YOKO_V_DUT->cached_source_level();
    my $i_d = $AGILENT_I_D->get_value();
    my $frq = $LOCKIN_REF->cached_frq();

    push @{$pha_results{Pha_ref}}, $pha_ref;
    push @{$pha_results{U_ac_out}}, $u_ac_out;
    $sweep->log(
        U_ac_out    => $u_ac_out,
        U_osc_ref   => $u_osc_ref,
        Pha_ref     => $pha_ref,
        U_osc_dut   => $u_osc_dut,
        R_ref       => $R_REF,
        V_DS        => $v_ds,
        V_GS        => $v_gs,
        V_DUT       => $v_dut,
        I_D         => $i_d,
        FRQ         => $frq
    );
    sleep(0.1);
};

# ...and the amplitude measurement routine.
my $amp_measurement = sub {
    my $sweep = shift;
    my $u_ac_out = $LOCKIN_OUT->query(command => "MAG.");
    my $u_osc_ref = $LOCKIN_REF->cached_source_level();
    my $pha_ref = $LOCKIN_REF->cached_refpha();
    my $u_osc_dut = $LOCKIN_DUT->cached_source_level();
    my $v_ds = $YOKO_V_DS->cached_source_level();
    my $v_gs = $YOKO_V_GS->cached_source_level();
    my $v_dut = $YOKO_V_DUT->cached_source_level();
    my $i_d = $AGILENT_I_D->get_value();
    my $frq = $LOCKIN_REF->cached_frq();

    push @{$amp_results{U_osc_ref}}, $u_osc_ref;
    push @{$amp_results{U_ac_out}}, $u_ac_out;
    $sweep->log(
        U_ac_out    => $u_ac_out,
        U_osc_ref   => $u_osc_ref,
        Pha_ref     => $pha_ref,
        U_osc_dut   => $u_osc_dut,
        R_ref       => $R_REF,
        V_DS        => $v_ds,
        V_GS        => $v_gs,
        V_DUT       => $v_dut,
        I_D         => $i_d,
        FRQ         => $frq
    );
    sleep(0.1);
};

# Balance out the length of the phase and amplitude range arrays by appending the
# lowest range value to the end of the shorter array until they are the same length
if ($#pha_range > $#amp_range) {until ($#pha_range == $#amp_range){$amp_range[$#amp_range+$_+1] = $amp_range[$#amp_range];}}
elsif ($#pha_range < $#amp_range) {until ($#pha_range == $#amp_range){$pha_range[$#pha_range+$_+1] = $pha_range[$#pha_range];}}

# Compute the estimated runtime
my $tm = (($#pha_range+1)*2*$repeat_measurement*($number_of_points*$delay_between_points*1.1+3+0.1)+($#pha_range+1)*3*2)*(abs($sweep_setup{to}-$sweep_setup{from}))/$sweep_setup{step};
my $secs = $tm % 60;
my $mins = $tm/60 % 60;

print "Estimated time: ".floor($tm/(60*60))."h".$mins."m".$secs."s\n";


sleep(3);

my $capacitance_file = sweep_datafile(folder => $folder, columns => [$sweep_setup{type}, 'Capacitance', 'best_phase', 'best_amplitude'], filename => 'capacitance');
$capacitance_file->add_plot(
    x => $sweep_setup{type},
    y => 'Capacitance',
);

# This measurement routine contains the whole process of balancing the ICB-bridge
# by alternately sweeping the phase and amplitude
my $capacitance_measurement = sub {
    my $sweep = shift;
    my $subfolder;
    if ($sweep_setup{type} eq 'V_DUT') {
        $subfolder = datafolder(path => $folder->path().'/V_DUT_'.$YOKO_V_DUT->cached_source_level().'V', time_prefix => 0, date_prefix => 0, copy_script => 0);
    } elsif ($sweep_setup{type} eq 'V_GS') {
        $subfolder = datafolder(path => $folder->path().'/V_GS_'.$YOKO_V_GS->cached_source_level().'V', time_prefix => 0, date_prefix => 0, copy_script => 0);
    } elsif ($sweep_setup{type} eq 'V_DS') {
        $subfolder = datafolder(path => $folder->path().'/V_DS_'.$YOKO_V_DS->cached_source_level().'V', time_prefix => 0, date_prefix => 0, copy_script => 0);
    } elsif ($sweep_setup{type} eq 'Frequency') {
        $subfolder = datafolder(path => $folder->path().'/Frequency_'.$LOCKIN_REF->cached_frq().'Hz', time_prefix => 0, date_prefix => 0, copy_script => 0);
    }

    foreach my $c (0..$#pha_range) {
        $LOCKIN_REF->set_level(value => $curramp);
        $LOCKIN_OUT->auto_sen(value => $max_phase_amp);
        sleep(3);

        ### PHASE SWEEP

        # Firstly, define the phase sweep
        $phase_sweep = sweep(
          type       => 'Step::Phase',
          instrument => $LOCKIN_REF,
          from => $pha_from, to => $pha_to, step => abs($pha_to-$pha_from)/$number_of_points,
          delay_before_loop => 3,
          delay_in_loop => $delay_between_points,
          filename_extension => 'U_osc_ref='.$LOCKIN_REF->cached_source_level()
        );

        # Clear out temporary variables
        @sorted_indexes = ();
        %pha_results = ();

        # Do the measurements $repeat_measurement-times

        my $repeat_phase = sweep(
            type => 'Step::Repeat',
            count => $repeat_measurement,
            before_loop => sub {
                @{$pha_results{Pha_ref}} = ();
                @{$pha_results{U_ac_out}} = ();
            },
            after_loop => sub {
                # Get the length of the resulting data array, should eqal $number_of_points
                $len = @{$pha_results{Pha_ref}};
                # Compute the sliding window average for each data value
                for (0..$len-1) {
                    $prel =  ceil(($_+1)*$window/$len);
                    # All the results are added up to compute the arithmetic mean later
                    @{$pha_results{U_ac_out_sa}}[$_] += sum(@{$pha_results{U_ac_out}}[$_-$prel+1..$_+$window-$prel])/$window;
                }
            }
        );

        my $phase_folder = datafolder(path => $subfolder->path().'/Pha_ref_Sweep', time_prefix => 0, date_prefix => 0, copy_script => 0);
        my $phase_file = sweep_datafile(folder => $phase_folder, columns => $columns, filename => 'pha_ref_sweep');
		if ($c >= $#pha_range-1 || $c == 0) {
			$phase_file->add_plot(
				x => 'Pha_ref',
				y => 'U_ac_out',
			);
		}
        $repeat_phase->start(
            slave => $phase_sweep,
            measurement => $phase_measurement,
            datafile => $phase_file,
            time_prefix => 0,
            folder => $phase_folder
        );

        # Now compute the arithmetic mean
        foreach my $val (@{$pha_results{U_ac_out_sa}}) { $val = $val/$repeat_measurement; }

        # Sort the sliding-window-averaged U_ac_out values in order to identify the
        # U_osc_ref, for which the U_ac_out is lowest
        @sorted_indexes = sort { @{$pha_results{U_ac_out_sa}}[$b] <=> @{$pha_results{U_ac_out_sa}}[$a] } 0..$#{$pha_results{U_ac_out_sa}};

        # Compute the lowest Amplitude as the arithmetic mean of the lowest $lowest data points
        $currphase = sum(@{$pha_results{Pha_ref}}[@sorted_indexes[-$lowest..-1]])/$lowest;
        $max_phase_amp = ${$pha_results{U_ac_out}}[$sorted_indexes[0]];

        # Set the new sweep ranges for the next sweep
        $pha_from = $currphase - $pha_range[$c]/2;
        if ($pha_from < 0) {$pha_from = 0;}
        $pha_to = $currphase + $pha_range[$c]/2;
        if ($pha_to > 360) {$pha_to = 360}

        print "Phase: ".$currphase."\n";

        $LOCKIN_REF->set_phase(value => $currphase);
        $LOCKIN_OUT->auto_sen(value => $max_amp_amp);
        sleep(3);

        ### AMPLITUDE SWEEP

        # Now define the U_osc_ref sweep
        $amp_sweep = sweep(
          type       => 'Step::Voltage',
          instrument => $LOCKIN_REF,
          from => $amp_from, to => $amp_to, step => abs($amp_to-$amp_from)/$number_of_points,
          delay_before_loop => 3,
          delay_in_loop => $delay_between_points,
          filename_extension => 'Pha_ref='.$LOCKIN_REF->cached_refpha()
        );

        # Clear out temporary variables
        @sorted_indexes = ();
        %amp_results = ();

        # Do the measurements $repeat_measurement-times

        my $repeat_amp = sweep(
            type => 'Step::Repeat',
            count => $repeat_measurement,
            before_loop => sub {
                @{$amp_results{U_osc_ref}} = ();
                @{$amp_results{U_ac_out}} = ();
            },
            after_loop => sub {
                # Get the length of the resulting data array, should eqal $number_of_points
                $len = @{$amp_results{U_osc_ref}};
                # Compute the sliding window average for each data value
                for (0..$len-1) {
                    $prel =  ceil(($_+1)*$window/$len);
                    # All the results are added up to compute the arithmetic mean later
                    @{$amp_results{U_ac_out_sa}}[$_] += sum(@{$amp_results{U_ac_out}}[$_-$prel+1..$_+$window-$prel])/$window;
                }
            }
        );

        my $amp_folder = datafolder(path => $subfolder->path().'/U_osc_ref_Sweep', time_prefix => 0, date_prefix => 0, copy_script => 0);
        my $amp_file = sweep_datafile(folder => $amp_folder, columns => $columns, filename => 'u_osc_ref_sweep');
		if ($c >= $#pha_range-1 || $c == 0) {
			$amp_file->add_plot(
				x => 'U_osc_ref',
				y => 'U_ac_out',
			);
		}
        $repeat_amp->start(
            slave => $amp_sweep,
            measurement => $amp_measurement,
            datafile => $amp_file,
            time_prefix => 0,
            folder => $amp_folder
        );

        # Now compute the arithmetic mean
        foreach my $val (@{$amp_results{U_ac_out_sa}}) { $val = $val/$repeat_measurement; }

        # Sort the sliding-window-averaged U_ac_out values in order to identify the
        # U_osc_ref, for which the U_ac_out is lowest
        @sorted_indexes = sort { @{$amp_results{U_ac_out_sa}}[$b] <=> @{$amp_results{U_ac_out_sa}}[$a] } 0..$#{$amp_results{U_ac_out_sa}};

        # Compute the lowest Amplitude as the arithmetic mean of the lowest $lowest data points
        $curramp = sum(@{$amp_results{U_osc_ref}}[@sorted_indexes[-$lowest..-1]])/$lowest;
        $max_amp_amp = ${$amp_results{U_ac_out}}[$sorted_indexes[0]];

        # Set the new sweep ranges for the next sweep
        $amp_from = $curramp - $amp_range[$c]/2;
        if ($amp_from < 0) {$amp_from = 0;}
        $amp_to = $curramp + $amp_range[$c]/2;

        print "Amplitude: ".$curramp."\n";
	}
	
	my $cap = sin(-2*pi()*$currphase/360)*1000000000000*$curramp/($U_OSC_DUT*$R_REF*2*pi()*$LOCKIN_REF->cached_frq());
	$prel = undef;
	$len = undef;
	@sorted_indexes = ();
	$pha_from = 0;
	$pha_to = $pha_range[0];
	$amp_from = 0;
	$amp_to = $amp_range[0];
	%pha_results = ();
	%amp_results = ();
	$max_phase_amp = 6e-3;
	$max_amp_amp = 5e-3;

	if ($sweep_setup{type} eq 'V_DUT') {
		$sweep->log(
			V_DUT       => $YOKO_V_DUT->cached_source_level(),
			Capacitance => $cap,
			best_phase	=> $currphase,
			best_amplitude => $curramp,
		);
	} elsif ($sweep_setup{type} eq 'V_GS') {
		$sweep->log(
			V_GS        => $YOKO_V_GS->cached_source_level(),
			Capacitance => $cap,
			best_phase	=> $currphase,
			best_amplitude => $curramp,
		);
	} elsif ($sweep_setup{type} eq 'V_DS') {
		$sweep->log(
			V_DS        => $YOKO_V_DS->cached_source_level(),
			Capacitance => $cap,
			best_phase	=> $currphase,
			best_amplitude => $curramp,
		);
	} elsif ($sweep_setup{type} eq 'Frequency') {
		$sweep->log(
			Frequency   => $LOCKIN_REF->cached_frq(),
			Capacitance => $cap,
			best_phase	=> $currphase,
			best_amplitude => $curramp,
		);
	}
	
	$currphase = undef;
	$curramp = $amp_range[0];
};

# Simply execute the sweep
print "Starting the sweep lets goooo\n";
$main_sweep->start(
    measurement => $capacitance_measurement,
    datafile => $capacitance_file,
    time_prefix => 0,
    folder => $folder
);

# After everything has finished, set all amplitudes to 0
print "Setting the Yokos to 0...\n";
$YOKO_V_DS->set_level(value => 0);
$YOKO_V_GS->set_level(value => 0);
$YOKO_V_DUT->set_level(value => 0);

print "Setting Lock-In oscillator amplitudes to 0...\n";
$LOCKIN_REF->set_level(value => 0);
$LOCKIN_OUT->set_level(value => 0);
$LOCKIN_DUT->set_level(value => 0);
