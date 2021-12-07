use v5.20;
use warnings;
use strict;

use Lab::Moose;
use Carp;

use Lab::Moose::Connection::VISA_GPIB;

my $sample = 'BundGateSweep';

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

my $isobus = Lab::Moose::Connection::VISA_GPIB->new(pad => 24);

my $BACKGATE = instrument(
    type => 'Keithley2400',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 30,
    },
	max_units_per_second => 0.2,
    max_units_per_step => 0.01,
    min_units => -111,
    max_units => 10
);

my $ITC = instrument(
	type => 'OI_ITC503',
	connection_type => 'IsoBus',
	connection_options => {
		base_connection => $isobus,
		isobus_address => 0
	}
);

# Für die Temperaturanzeige
my $LAKE = instrument(
    type => 'Lakeshore340',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 12
    }
);

#Einstellung und Initialsierung von Lock-In 1
my $LOCKIN_I = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 16
    }
);

#Einstellung und Initialsierung von Lock-In 2
my $LOCKIN_U1 = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 17
    }
);

#Einstellung und Initialsierung von Lock-In 3
my $LOCKIN_U2 = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 10
    }
);

#Einstellung und Initialsierung von Lock-In 4
my $LOCKIN_U3 = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 14
    }
);

#Einstellung und Initialsierung von Lock-In 5
my $LOCKIN_U4 = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 15
    }
);

#Einstellung und Initialsierung von Lock-In 6
my $LOCKIN_U5 = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 8
    }
);

#Einstellung und Initialsierung von Lock-In 7
my $LOCKIN_U6 = instrument(
    type => 'SignalRecovery7265',
    connection_type => 'VISA_GPIB',
    connection_options => {
        pad => 13
    }
);

#Einstellung und Initialsierung von Magnet
my $IPS = instrument(
	type => 'OI_IPS',
	connection_type => 'IsoBus',
	connection_options => {
		base_connection => $isobus,
		isobus_address => 2
	},
	max_field_rates => [1],
	max_fields => [8],
);

my $ILM = instrument(
	type => 'OI_ILM210', 
	connection_type => 'IsoBus', 
	connection_options => {
		base_connection => $isobus,
		isobus_address => 6
	}
);

#----------------------------------------------------------------------------------------------------------------------------------

my $magnet_sweep = sweep(
	type       => 'Continuous::Magnet',
	instrument => $IPS,
	points => [5, 8],										#Von Starwert in Volt zu Endwert in Volt
	# points => [5, 8],										#Von Starwert in Volt zu Endwert in Volt
	rates => [0.8 ,0.2],											#Rate (max. 0.5!!!) gibt die Geschwindigkeit (T/Minute) and wie schnell zum n�chsten Step gesweept wird
	delay_before_loop => 5,
	backsweep => 0,
);

my $sweep_gate2 = sweep(
	type       => 'Step::Voltage',
	instrument => $BACKGATE,
	points => [-110,-60],									#Von Starwert in Volt zu Endwert in Volt
	# points => [-110,-50],									#Von Starwert in Volt zu Endwert in Volt
	steps => [0.25],										#notwendig, da zu diesem Zeitpunkt immer gespeichert wird und gibt die größer der Zwischenschritte an											#Interval x gibt an, dass alle x Sekunden ein Messpunkt gemacht	wird
	delay_before_loop => 5,	
	#backsweep => 1
);

#-------------------------------------------------------
#Erstellt neues File mit einzelnen Spalten, die gemessen werden sollen

my $folder = datafolder(path => "C:/Users/User/Desktop/SofiaF/P26/Landau/BundGateSweep");
my $file = sweep_datafile(
	folder => $folder,
	columns => [qw/

		T_SAMPLE
		B_Z
		BACKGATE
		X_I
		Y_I
		X_U1
		X_U2
		X_U3
		X_U4
		X_U5
		X_U6
		Y_U1
		Y_U2
		Y_U3
		Y_U4
		Y_U5
		Y_U6
		Heliumstand
		T_VTI
	/]
);

#-------------------------------------------------------------

=head1

$file->add_plot(
	x => 'TIME',
	y => 'Heliumstand',
	plot_options => {
		title => 'Helium vs time',
		xlabel => 'TIME',
		ylabel => 'Helium'
	},
	hard_copy => 'HeliumTime.png'
);

$file->add_plot(
	x => 'TIME',
	y => 'T_VTI',
	plot_options => {
		title => 'Temp vs time',
		xlabel => 'TIME',
		ylabel => 'T_VTI'
	},
	hard_copy => 'TempTime.png'
);

=cut

$file->add_plot(
	x => 'B_Z',
	y => 'X_U1',
	plot_options => {
		title => 'U1 vs B_r',
		xlabel => 'B_Z / T',
		ylabel => 'X_U1 / volt'
	},
	hard_copy => 'U1Br.png'
);

$file->add_plot(
	x => 'B_Z',
	y => 'X_U2',
	plot_options => {
		title => 'U2 vs B_r',
		xlabel => 'B_Z / T',
		ylabel => 'X_U2 / volt'
	},
	hard_copy => 'U2Br.png'
);

$file->add_plot(
	x => 'B_Z',
	y => 'X_U3',
	plot_options => {
		title => 'U3 vs B_r',
		xlabel => 'B_Z / T',
		ylabel => 'X_U3 / volt'
	},
	hard_copy => 'U3Br.png'
);

$file->add_plot(
	x => 'B_Z',
	y => 'X_U4',
	plot_options => {
		title => 'U4 vs B_r',
		xlabel => 'B_Z / T',
		ylabel => 'X_U4 / volt'
	},
	hard_copy => 'U4Br.png'
);

$file->add_plot(
	x => 'B_Z',
	y => 'X_U5',
	plot_options => {
		title => 'U5 vs B_r',
		xlabel => 'B_Z / T',
		ylabel => 'X_U5 / volt'
	},
	hard_copy => 'U5Br.png'
);

$file->add_plot(
	x => 'B_Z',
	y => 'X_U6',
	plot_options => {
		title => 'U6 vs B_r',
		xlabel => 'B_Z / T',
		ylabel => 'X_U6 / volt'
	},
	hard_copy => 'U6Br.png'
);

#-------------------------------------------------------------

my $measurement = sub {
	my $sweep = shift;
	#my $time = $sweep->{Time};

	my $b_z = $IPS->get_value();
	my $t_sample = $LAKE->get_value(channel => 'A');
	my $gate = $BACKGATE->get_level();


	my $I_X = $LOCKIN_I -> get_value(channel => 'X');		# 'MP': readout of MAG & PHA; 'MAG': only; 'PHA': phase only, 'XY': X & Y..
	my $I_Y = $LOCKIN_I -> get_value(channel => 'Y');

	#Realteil von U
	my $U_X1 = $LOCKIN_U1 -> get_value(channel => 'X');
	my $U_X2 = $LOCKIN_U2 -> get_value(channel => 'X');
	my $U_X3 = $LOCKIN_U3 -> get_value(channel => 'X');
	my $U_X4 = $LOCKIN_U4 -> get_value(channel => 'X');
	my $U_X5 = $LOCKIN_U5 -> get_value(channel => 'X');
	my $U_X6 = $LOCKIN_U6 -> get_value(channel => 'X');

	#Imaginarteil von U
	my $U_Y1 = $LOCKIN_U1 -> get_value(channel => 'Y');
	my $U_Y2 = $LOCKIN_U2 -> get_value(channel => 'Y');
	my $U_Y3 = $LOCKIN_U3 -> get_value(channel => 'Y');
	my $U_Y4 = $LOCKIN_U4 -> get_value(channel => 'Y');
	my $U_Y5 = $LOCKIN_U5 -> get_value(channel => 'Y');
	my $U_Y6 = $LOCKIN_U6 -> get_value(channel => 'Y');

	my $helium = $ILM->get_level();

	my $t_vti = $ITC->get_value();					# Temperatur

	#Weist den einzelnen Spalten (Name davon steht links) die Werte auf der rechten Seite zu. Die Werte von rechter Seite werden oben gleich unter my $measurment von den Ger�ten geholt
	$sweep->log(
		#TIME => 		$time,
		T_SAMPLE => 	$t_sample,
		B_Z => 			$b_z,
		BACKGATE =>		$gate,
		X_I		=> 		$I_X,
		Y_I		=> 		$I_Y,
		X_U1	=> 		$U_X1,
		X_U2	=> 		$U_X2,
		X_U3	=> 		$U_X3,
		X_U4	=> 		$U_X4,
		X_U5	=> 		$U_X5,
		X_U6	=> 		$U_X6,
		Y_U1	=> 		$U_Y1,
		Y_U2	=> 		$U_Y2,
		Y_U3	=> 		$U_Y3,
		Y_U4	=> 		$U_Y4,
		Y_U5	=> 		$U_Y5,
		Y_U6	=> 		$U_Y6,
		Heliumstand => 	$helium,
		T_VTI => 		$t_vti,
	);
};

#-----------------------------------------------------------------------------

my $check_helium = sub {
	my $he_level = $ILM->get_level();
	print "Helium check: Level = $he_level ... ";
	if ($he_level <= 15) {
		print "\n\nLow Helium Level! Sweep to zero and enable persistent mode \n";
		my $field = $IPS->get_value();
		$IPS->to_zero();
		$IPS->set_persistent_mode(value => 1);
		print "Pause... Press Enter to proceed\n";
		# ReadMode('normal');
		<>;
		ReadMode('cbreak');
		$IPS->set_persistent_mode(value => 0);
		$IPS->sweep_to_field(target => $field, rate => 0.1);
		print "Go! \n";
	}
	else {
		print "OK \n";
	}
};

#-----------------------------------------------------------------------------

$sweep_gate2->start(
	slave => $magnet_sweep,
    measurement => $measurement,
    datafile => $file
);

#$IPS->sweep_to_level(0,1);
#$IPS->trg();
#$IPS->wait();