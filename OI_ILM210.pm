package Lab::Moose::Instrument::OI_ILM210;
$Lab::Moose::Instrument::OI_ILM210::VERSION = '3.792';
#ABSTRACT: Oxford Instruments ILM Intelligent Helium Level Meter

use v5.20;

use Moose;
use Lab::Moose::Instrument qw/
    validated_no_param_setter
/;
use Lab::Moose::Instrument::Cache;
use Carp;
use namespace::autoclean;

extends 'Lab::Moose::Instrument';

sub BUILD {
    my $self = shift;

    warn "The ILM driver is work in progress. You have been warned\n";

    # Unlike modern GPIB equipment, this device does not assert the EOI
    # at end of message. The controller shell stop reading when receiving the
    # eos byte.

    $self->connection->set_termchar( termchar => "\r" );
    $self->connection->enable_read_termchar();
    $self->clear();

}

cache level => (getter => 'get_level');

sub get_level {
    my ( $self, %args ) = validated_no_param_setter(
		\@_,
        channel => { isa => 'Int' , default => 1},
    );
	
	my $channel = delete %args{channel};

    my $level = $self->query(command => "R$channel\r");
    $level =~ s/^R//;
    $level /= 10;
    return $self->cached_level($level);
}

__PACKAGE__->meta()->make_immutable();

1;