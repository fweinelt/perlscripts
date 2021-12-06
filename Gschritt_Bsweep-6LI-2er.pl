use strict;
use warnings;

use lib 'C:\perllibs\Measurement\lib';
use Lab::Measurement;
use Lab::XPRESS::hub;

my $hub = new Lab::XPRESS::hub();

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

# my $ILM = Instrument('ILM', {connection => Connection('IsoBus', {base_connection => $isobus,isobus_address => 6})
	# });	
	
#----------------------------------------------------------------------------------------------------------------------------------
 
 
 
#Magnetsweep 
	my $magnet_sweep = Sweep('Magnet', {
		instrument => $IPS,
		mode =>	'continuous',
		points => [-0.1, 0],										#Von Starwert in Volt zu Endwert in Volt
		# points => [5, 8],										#Von Starwert in Volt zu Endwert in Volt
		rate => [0.8 ,0.2],											#Rate (max. 0.5!!!) gibt die Geschwindigkeit (T/Minute) and wie schnell zum nächsten Step gesweept wird
		delay_before_loop => 5,
		backsweep => 0,
	});
 
 
	my $sweep_gate2 = $hub->Sweep('Voltage', {
		 instrument => $BACKGATE,	
		 mode => 'step',									# modes: step, continuous, 
		 points => [-0.2,0],									#Von Starwert in Volt zu Endwert in Volt
		 # points => [-110,-50],									#Von Starwert in Volt zu Endwert in Volt
		 stepwidth => [0.25],										#notwendig, da zu diesem Zeitpunkt immer gespeichert wird und gibt die größer der Zwischenschritte an
		 rate => [0.1],											#Sweeprate in Volt/Sekunde
		 interval => 1,											#Interval x gibt an, dass alle x Sekunden ein Messpunkt gemacht	wird
		 delay_before_loop => 5,	
		 #backsweep => 1
	});


#-------------------------------------------------------
#Erstellt neues File mit einzelnen Spalten, die gemessen werden sollen

#Definiert neues File mit Namen in Klammer von my_DataFile
my $file = my_DataFile('BundGatesweep'.$sample);

sub my_DataFile {
 #Füllt die Daten in den Array
	 my $filename = shift;

	 my $DataFile = DataFile($filename);
	
	 #Fügt einzlene Spalten und deren Benennung hinzu, Werte kommen aber erst im nächsten Abschnitt/Block
	 $DataFile->add_column('TIME');
	 # $DataFile->add_column('T_SAMPLE');
	 $DataFile->add_column('B_Z');
	 $DataFile->add_column('BACKGATE');
	 $DataFile->add_column('X_I');
	 $DataFile->add_column('Y_I');
	 $DataFile->add_column('X_U1');
	 $DataFile->add_column('X_U2');
	 $DataFile->add_column('X_U3');
	 $DataFile->add_column('X_U4');
	 $DataFile->add_column('X_U5');
	 $DataFile->add_column('X_U6');
	 $DataFile->add_column('Y_U1');
	 $DataFile->add_column('Y_U2');
	 $DataFile->add_column('Y_U3');
	 $DataFile->add_column('Y_U4');
	 $DataFile->add_column('Y_U5');
	 $DataFile->add_column('Y_U6');
	 $DataFile->add_column('Heliumstand');
	 $DataFile->add_column('T_VTI');

	 return $DataFile;
 }

#-------------------------------------------------------------

my $plot = {
			'title' => 'Helium vs time',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'TIME',										# refers to columns
			'x-label' => 'TIME',
					
			'y-axis' => 'Heliumstand',										# refers to columns
			'y-label' => 'Helium',
			};
			
$file->add_plot($plot);

my $plot1 = {
			'title' => 'Temp vs time',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'TIME',										# refers to columns
			'x-label' => 'TIME',
					
			'y-axis' => 'T_VTI',										# refers to columns
			'y-label' => 'T_VTI',
			};
			
$file->add_plot($plot1);

my $plot2 = {
			'title' => 'U1 vs B_r',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'B_Z',										# refers to columns
			'x-label' => 'B_Z / T',
			
			'y-axis' => 'X_U1',										# refers to columns
			'y-label' => 'X_U1 / volt',
			
			};
			
$file->add_plot($plot2);
my $plot3 = {
			'title' => 'U2 vs B_r',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'B_Z',										# refers to columns
			'x-label' => 'B_Z / T',
			
			'y-axis' => 'X_U2',										# refers to columns
			'y-label' => 'X_U2 / volt',
			
			};
			
$file->add_plot($plot3);
my $plot4 = {
			'title' => 'U3 vs B_r',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'B_Z',										# refers to columns
			'x-label' => 'B_Z / T',
			
			'y-axis' => 'X_U3',										# refers to columns
			'y-label' => 'X_U3 / volt',
			
			};
			
$file->add_plot($plot4);
my $plot5 = {
			'title' => 'U4 vs B_r',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'B_Z',										# refers to columns
			'x-label' => 'B_Z / T',
			
			'y-axis' => 'X_U4',										# refers to columns
			'y-label' => 'X_U4 / volt',
			
			};
			
$file->add_plot($plot5);
my $plot6 = {
			'title' => 'U5 vs B_r',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'B_Z',										# refers to columns
			'x-label' => 'B_Z / T',
			
			'y-axis' => 'X_U5',										# refers to columns
			'y-label' => 'X_U5 / volt',
			
			};
			
$file->add_plot($plot6);
my $plot7 = {
			'title' => 'U6 vs B_r',
			'type' => 'point', 										#'lines', #'linetrace', #point

			'x-axis' => 'B_Z',										# refers to columns
			'x-label' => 'B_Z / T',
			
			'y-axis' => 'X_U6',										# refers to columns
			'y-label' => 'X_U6 / volt',
			
			};
			
$file->add_plot($plot7);

#-------------------------------------------------------------


my $measurement = sub {

	my $sweep = shift;
	my $time = $sweep->{Time};

	my $b_z = $IPS->get_value();
	my $gate = $BACKGATE->get_level({'read_mode' => 'fetch'});
	
	
	my $I_X = $LOCKIN_I -> get_value('X');		# 'MP': readout of MAG & PHA; 'MAG': only; 'PHA': phase only, 'XY': X & Y..
	my $I_Y = $LOCKIN_I -> get_value('Y');
	
	#Realteil von U
	my $U_X1 = $LOCKIN_U1 -> get_value('X');		
	my $U_X2 = $LOCKIN_U2 -> get_value('X');
	my $U_X3 = $LOCKIN_U3 -> get_value('X');	
	my $U_X4 = $LOCKIN_U4 -> get_value('X');
	my $U_X5 = $LOCKIN_U5 -> get_value('X');	
	my $U_X6 = $LOCKIN_U6 -> get_value('X');
	
	#Imaginarteil von U
	my $U_Y1 = $LOCKIN_U1 -> get_value('Y');		
	my $U_Y2 = $LOCKIN_U2 -> get_value('Y');
	my $U_Y3 = $LOCKIN_U3 -> get_value('Y');	
	my $U_Y4 = $LOCKIN_U4 -> get_value('Y');
	my $U_Y5 = $LOCKIN_U5 -> get_value('Y');	
	my $U_Y6 = $LOCKIN_U6 -> get_value('Y');	
	
	# my $helium=$ILM->get_value();
	my $helium = $IPS->get_level();
	
	my $t_vti = $ITC->get_value(1);					# Temperatur
	
	#Weist den einzelnen Spalten (Name davon steht links) die Werte auf der rechten Seite zu. Die Werte von rechter Seite werden oben gleich unter my $measurment von den Geräten geholt
	$sweep->LOG({
		TIME => $time,
		# T_SAMPLE => $lake->get_value('A'),
		B_Z => $b_z,
		BACKGATE => $gate,
		X_I		=> $I_X,
		Y_I		=> $I_Y,
		X_U1	=> $U_X1,
		X_U2	=> $U_X2,
		X_U3	=> $U_X3,		
		X_U4	=> $U_X4,
		X_U5	=> $U_X5,		
		X_U6	=> $U_X6,
		Y_U1	=> $U_Y1,
		Y_U2	=> $U_Y2,
		Y_U3	=> $U_Y3,
		Y_U4	=> $U_Y4,
		Y_U5	=> $U_Y5,
		Y_U6	=> $U_Y6,		
		Heliumstand => $helium,
		T_VTI => $t_vti,
		});
};

#-----------------------------------------------------------------------------

my $check_helium = sub {
	my $he_level = $IPS->get_level();
	print "Helium check: Level = $he_level ... ";
	if ($he_level <= 15) {
		print "\n\nLow Helium Level! Sweep to zero and enable persistent mode \n";
		my $field = $IPS->get_value();
		$IPS->sweep_to_level(0);
		$IPS->set_persistent_mode(1);
		print "Pause... Press Enter to proceed\n";
		# ReadMode('normal');
		<>;
		ReadMode('cbreak');
		$IPS->set_persistent_mode(0);
		$IPS->sweep_to_field($field);
		print "Go! \n";
	}
	else {
		print "OK \n";
	}
};

#-----------------------------------------------------------------------------

$file->add_measurement($measurement);

$sweep_gate2->add_DataFile($file);
$magnet_sweep->add_DataFile($file);

my $frame = $hub->Frame();
$frame->add_master($sweep_gate2);
$frame->add_slave($magnet_sweep);
$frame->add_slave($check_helium);


#$sweep_gate2->start(); 


$frame->start();




#$IPS->sweep_to_level(0,1);
#$IPS->trg();
#$IPS->wait();	









