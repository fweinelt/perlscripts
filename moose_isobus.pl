#!C:\strawberry-perl-5.32.1.1-64bit\perl\bin
use v5.20;
use Lab::Moose;

use Lab::Moose::Connection::VISA_GPIB;

my $connection = Lab::Moose::Connection::VISA_GPIB->new(pad => 24);


$connection->set_termchar(termchar => "\r");
$connection->enable_read_termchar();

$connection->set_termchar(termchar => "\r");
$connection->enable_read_termchar();


say $connection->Query(command => "\@0V\r");