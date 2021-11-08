use Lab::Measurement;
use 5.010;
use warnings;
use strict;


#--------preample---------

#my $vorwiderstand = 100000;
# my $R_LOAD=1000; #load resistor value, usually 1000 ohms
# my $Trafo_DUT=0.125; #transformator AC attenuation factor which goes to DUT
# my $Trafo_REF=0.125; #transformator AC attenuation factor which goes to reference resistor
my $R_REF=100000; #value of reference resistor in ohms
my $initial_dut_frq = 2005;
my $initial_tc = 0.5;

#---------device-init----------

# my $YOKO_SD = Instrument('Yokogawa7651', {   #yoko - controls DC voltage input of source drain-channel
	# connection => Connection('VISA_GPIB', {gpib_address => 4}),
	# gate_protect => 0,
	# # 'gp_max_units_per_second' => 0.1, 	# in V/s
    # # 'gp_max_units_per_step' => 0.05,
    # # 'gp_min_units' => -3, 
    # # 'gp_max_units'  => 5
	# gp_max_units_per_second  => 0.05,
	# gp_max_units_per_step    => 0.005,
	# gp_max_step_per_second  => 5,
	# gp_min_units => -3,
	# gp_max_units => 6,
# });

# my $YOKO_REF = Instrument('Yokogawa7651', {   #yoko - controls DC voltage input of Referenceresistor
	# connection => Connection('VISA_GPIB', {gpib_address => 4}),
	# gate_protect => 0,
	# # 'gp_max_units_per_second' => 0.1, 	# in V/s
    # # 'gp_max_units_per_step' => 0.05,
    # # 'gp_min_units' => -3, 
    # # 'gp_max_units'  => 5
	# gp_max_units_per_second  => 0.05,
	# gp_max_units_per_step    => 0.005,
	# gp_max_step_per_second  => 5,
	# gp_min_units => -3,
	# gp_max_units => 0,
# });

# my $YOKO_DUT = Instrument('Yokogawa7651', {   #yoko - controls DC voltage input of device under test
	# connection => Connection('VISA_GPIB', {gpib_address => 4}),
	# gate_protect => 0,
	# # 'gp_max_units_per_second' => 0.1, 	# in V/s
    # # 'gp_max_units_per_step' => 0.05,
    # # 'gp_min_units' => -3, 
    # # 'gp_max_units'  => 5
	# gp_max_units_per_second  => 0.05,
	# gp_max_units_per_step    => 0.005,
	# gp_max_step_per_second  => 5,
	# gp_min_units => -3,
	# gp_max_units => 6,
# });


my $LOCKIN_REF = Instrument('SignalRecovery726x', { #sends out AC signal to the reference resistor
	connection => Connection('VISA_GPIB', {gpib_address => 14}), 
	
	tc => $initial_tc, 	
});

my $LOCKIN_DUT = Instrument('SignalRecovery726x', { #sends out AC signal to the DUT
	connection => Connection('VISA_GPIB', {gpib_address => 10}),

	frq => $initial_dut_frq,
	tc => $initial_tc, 
});

my $LOCKIN_OUT = Instrument('SignalRecovery726x', { #detects V_Out (the signal after the transistor)
	connection => Connection('VISA_GPIB', {gpib_address => 15}), 

	tc => $initial_tc, 
});


# my $Multimeter = Instrument('Agilent34410A', {    	# detects current after transistor which goes to the ground
	# connection => Connection('VISA_GPIB', {gpib_address => 18}),

	# nplc => 10                						#integrationszeit 10x netzfrequenz
	# });






# KRYO2control -------------------------------------------------------

# my $isobus = Connection('VISA_GPIB', {
	# gpib_address => 24});
	
# my $IPS = Instrument('IPSWeiss2', {
	# connection => Connection('IsoBus', {
		# base_connection => $isobus,
		# isobus_address => 2})
 # });
 
# my $ITC = Instrument('ITC', {
	# connection => Connection('IsoBus', {
		# base_connection => $isobus,
		# isobus_address => 0})
# });

# my $lake = Instrument('Lakeshore224');  # Temperature at the sampleholder 


# my $ILM = Instrument('ILM', {				# shows the helium level
	# connection => Connection('IsoBus', {
		# base_connection => $isobus,
		# isobus_address => 6})
 # });
# #----------------------------------------------------------
 

# my $sweep_sd = Sweep('Voltage', { #controls DC of source drain-channel
	# instrument => $YOKO_SD,	
	# mode => 'list',
	# interval => 2,         						# modes: list, step, continuous, 
	# points => [0.4], #source drain voltage of the transistor is at 0.4V	
	# stepwidth => [0],  
	# rate => [0.02], #0.005, 0.0004
	# delay_before_loop => 10,
	# backsweep => 0,
# });

# my $sweep_dut = Sweep('Voltage', { #controls the DC voltage of the device under test
	# instrument => $YOKO_DUT,	
	# mode => 'list',
	# interval => 2,         						
	# points => [0], #is usually zero for you stephen. only relevant once we use the Graphen sample
	# stepwidth => [0.1],	
	# rate => [0.02], #0.005, 0.0004
	# delay_before_loop => 10,
	# backsweep => 0,
# });

# my $sweep_ref = Sweep('Voltage', { 	#controls the DC voltage which drops at the reference resistor
	# instrument => $YOKO_REF,		#and at the transistor topgate. MUST BE NEGATIVE
	# mode => 'list',
	# interval => 2,         						 
	# points => [-3], #for example -3 Volts: -2 Volts drop at the resistor, -1 Volt drops at the transistor topgate
	# stepwidth => [0.1],	
	# rate => [0.02], #0.005, 0.0004
	# delay_before_loop => 10,
	# backsweep => 0,
# });


# my $sweep_LIref = Sweep('SignalRecoveryOsc', { 	#controls the DC voltage which drops at the reference resistor
	# instrument => $LOCKIN_REF,		#and at the transistor topgate. MUST BE NEGATIVE
	# mode => 'continuous',
	# interval => 1,         						 
	
	# points => [0.1, 1], #for example -3 Volts: -2 Volts drop at the resistor, -1 Volt drops at the transistor topgate
	# stepwidth => [0.1],	
	# rate => [0.02], #0.005, 0.0004
	
	# delay_before_loop => 10,
	# backsweep => 0,
# });


my $sweep_REFphase = Sweep('SignalRecoveryPhase', #this sweeps the amplitude step by step
	{
	instrument => $LOCKIN_REF,
	points => [0, 360], #defines the reference phase value
	stepwidth => [10],
	mode => 'step',		
	backsweep => 0,
	delay_before_loop => 5,
});




# my $magnet_sweep = Sweep('Magnet', {
	# mode => 'continuous',
	# instrument => $IPS,
	# interval => 2,
	
	# points => [-6, 6], #0 bis 6 flussquanten pro Antidot #-0.04595, 0.344625
	# stepwidth => [0.1], #ein SC flussquant hat man bei B=0.022975 in einem sample mit 300nm periode#0.002871875
	# rate => [0.5], #0.05
	
	# delay_in_loop => 10,
	# backsweep => 1,
	# # separate_files => 1,
# });

# my $temp_sweep = Sweep('Temperature', {
	# mode => 'step',
	# instrument => $ITC->Ch1,
	# sensor => $lake,
	
	# points => [5.5, 1.25], #gap bei ??
	# stepwidth => [0.25],
	
	# pid => [(90, 1, 0.5)], #kryo mit wenig helium: 90, 1, 0.5; oder 100, 2.5, 0.25?? oder 100, 1.5, 0.3, 100, 1.8, 0.25
	
	# stabilize_observation_time => 5*60,		
	# tolerance_setpoint => 0.015, #gilt fürs ITC			
	# std_dev_instrument => 0.02, #gilt fürs ITC				
	# std_dev_sensor => 0.1, #gilt fürs lakeshore
# });


#-------------------------------------------------------

my $file = DataFile('ICB_balancing.dat');

$file->add_column('TIME');

# $file->add_column('T_SAMPLE');
# $file->add_column('T_VTI');

# $file->add_column('B');

$file->add_column('U_osc_ref'); 
$file->add_column('U_osc_dut');
$file->add_column('U_ac_out');

$file->add_column('U_ac_ratio');

# $file->add_column('U_ref'); 
# $file->add_column('U_dut');
# $file->add_column('U_out');

$file->add_column('Frq_osc');
$file->add_column('Pha_dut');
$file->add_column('Pha_ref');



# my $plot = {
# 		#'autosave' => 'last', # last, allways, never
# 		'title' => 'U_ac_out vs Phase difference ',
# 		'type' => 'point', #'lines', #'linetrace', #point
# 		'x-axis' => 'PHASE DIFFERENCE MISSING',
# 		'x-format' => '%1.2e',
# 		#'x-min' => -1,
# 		#'x-max' => 1,
# 		'y-axis' => 'U_ac_out',
# 		'y-format' => '%1.2e',
# 		#'y-min' => -1,
# 		#'y-max' => 1,
# 		'grid' => 'xtics ytics',		
# 		};
# $file->add_plot($plot);

my $plot = {
		'title' => 'U_ac_out vs Pha_ref',
		'type' => 'lines', 
		'x-axis' => 'Pha_ref',
		#'x-min' => -1,
		#'x-max' => 1,
		
		'y-axis' => 'U_ac_out',
		#'y-min' => -1,
		#'y-max' => 1,
		};
$file->add_plot($plot);

# say "after addplot";  #this can be used to debug the script 

#-------------------------------------------------------------

my $meas = sub {
	sleep 1;
	my $sweep = shift;
	my $time = $sweep->{Time};
	
	
	# my $t_sample = $lake->get_value();
	# my $t_vti = $ITC->get_value(1);
	
	# my $b =$IPS->get_value();
	
	#lockins
	my $u_osc_ref = $LOCKIN_REF->get_osc();
	my $u_osc_dut = $LOCKIN_DUT->get_osc();
	my $u_ac_out_mp = $LOCKIN_OUT->get_value('MP');		# 'MP': readout of Magnitude and Phase; 'MAG': magnitude only; 'PHA': phase only, 'XY':..
	my $u_ac_out = $u_ac_out_mp->{MAG}; #takes the magnitude (=amplitude) of u_ac_out_mp
	my $u_ac_out_pha = $u_ac_out_mp->{PHA}; #takes the phase of u_ac_out_mp
	
	my $u_ac_ratio = ($u_osc_dut != 0) ? $u_osc_ref / $u_osc_dut : '?'; #devides u_osc_ref by u_osc_dut and if u_osc_dut=0 it prints ?
	
	#yokogawas
	# my $u_ref = $YOKO_REF->get_level();
	# my $u_dut = $YOKO_DUT->get_level();
	# my $u_sd = $YOKO_SD->get_level();		
	
	my $osc_frq = $LOCKIN_DUT->get_frq();
	my $pha_dut = $LOCKIN_DUT->get_refpha();
	my $pha_ref = $LOCKIN_REF->get_refpha();

	
	
	
	$sweep->LOG({
	
		TIME => $time,
		
		# T_SAMPLE => $t_sample,
		# T_VTI => $t_vti,
		
		# B => $b,
		
		U_osc_ref => $u_osc_ref,
		U_osc_dut => $u_osc_dut,
		U_ac_out => $u_ac_out,
		
		U_ac_ratio => $u_ac_ratio,
		
		# U_ref => $u_ref,
		# U_dut => $u_dut,
		# U_sd => $u_sd,

		Frq_osc => $osc_frq,
		Pha_dut => $pha_dut,
		Pha_ref => $pha_ref,
	});
	
};

#-----------------------------------------------------------------------------
$file->add_measurement($meas);

#define which sweep creates the data you want saved in file
$sweep_REFphase->add_DataFile($file);


# $YOKO_REF->sweep_to_level(0, 0.05);
$LOCKIN_DUT->set_osc(1); #defines the DUT voltage amplitude - do not set to zero or the amplitude ratio will go to infinity
$LOCKIN_REF->set_osc(0.01); 

#start sweep
$sweep_REFphase->start();



