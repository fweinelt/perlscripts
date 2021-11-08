use lib '/media/fabian/Volume/fabian/Documents/Uni/Bachelor Arbeit/Perl/Lab-Measurement/lib';
use Lab::Moose;


my $source = instrument(
    type            => 'Rigol_DG5000',
    connection_type => 'USB',
    connection_options => {host => '192.168.3.34'},
    function => 'PULSE'
);

my $osc = instrument(
  type => 'KeysightDSOS604A',
  connection_type => 'VXI11',
  connection_options => {host => '192.168.3.33'},
  waveform_format => 'FLOat',
  input_impedance => 'DC',
  instrument_nselect => 1
);

my $div = 1;

my $sweep = sweep(
  type       => 'Step::Pulsewidth',
  instrument => $source,
  from => $div*0.0000000025, to => $div*0.000000100, step => $div*0.0000000025,
  constant_delay => 1
);

my $amp = 1;
my $delay = $div*0.000000250;
my $scal = 1;
my $cycles = 2;

$source->set_level(value => $amp);
$source->set_period(value => $delay+$sweep->from);
$source->set_pulsedelay(value => $delay);
$osc->channel_offset(offset => 0.5);
$osc->channel_range(range => 1.5);
$osc->trigger_level(value => 0.5);
$osc->timebase_range(value => $cycles*($sweep->to+$delay));


my $datafile = sweep_datafile(columns => [qw/pulsewidth time voltage/]);

my $meas = sub {
    my $sweep = shift;
    my $waveform = $osc->get_waveform();

    $sweep->log_block(
        prefix => {pulsewidth => $source->get_pulsewidth()},
        block => $waveform
    );
};

$sweep->start(
    measurement => $meas,
    datafile    => $datafile,
    datafile_dim => 1,
    point_dim => 1,
    folder => "Direkt_PWidth_".$sweep->from."s_to_".$sweep->to."s_step_".$sweep->step."s_delay_".$delay."s"
);
