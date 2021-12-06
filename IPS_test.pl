

use v5.20;
use warnings;
use strict;

use Lab::Moose;
use POSIX qw/ceil floor/;
use List::Util qw/min max sum/;
use Math::Trig;
use Carp;

 
 # my $connection = new Lab::Connection::IsoBus(
  # connection_type => 'IsoBus',
  # isobus_address => 3,
# }
 
 
 
 my $isobus = instrument(
     connection_type => 'VISA::GPIB',
    connection_options => {
        pad => 24}
);


my $ips = instrument(
    type => 'OI_Mercury::Magnet',
    connection_type => 'IsoBus',  isobus_address => 2, 
);






# $instrument = OI_LM210( connection_type => 'IsoBus', isobus_address => 3, );


my $ITC = Instrument('ITC', {connection => Connection('IsoBus', {base_connection => $isobus,isobus_address => 0})
	});

my $lake = Instrument('Lakeshore224',{device_settings => {channel_default => 'ChA'}
	});																															# Für die Temperaturanzeige"

my $ILM = Instrument('ILM', {connection => Connection('IsoBus', {base_connection => $isobus,isobus_address => 6})
	});																															# Für die Heliumfüllstands"anzeige"
	




 
 my $sweep = sweep(
    type => 'Continuous::Magnet',
    instrument => $ips,
    from => -1, # Tesla
    to => 1,
    rate => 0.1, # (Tesla/min, always positive)
    start_rate => 1, # (optional, rate to approach start point)
    interval => 0.5, # one measurement every 0.5 seconds
);
 
 
 

 
 
 my $columns = [qw/
	T_SAMPLE
	HE_LEVEL
	VTI_TEMP

/];
 my $datafile = sweep_datafile(columns => $columns) ;
 
my $meas = sub {
    my $sweep = shift;
		my $t_sample = $lake->get_value();
		my $helium=$ILM->get_value();
		my $heliumTemp=$ITC->get_value();


    $sweep->log(
        T_SAMPLE   => $t_sample,
        HE_LEVEL   => $helium,
        VTI_TEMP     => $heliumTemp
    );
	
	 print "Lakeshore-Temperatur = $t_sample \n";
print "Heliumlevel = $helium \n";
print "Kammertemperatur= $heliumTemp \n";

};
 



 
$sweep->start(
    measurement => $meas,
    datafile    => $datafile,
);




#$ips->config_sweep(point => 0.5, rate => 0.1);