#! /usr/bin/env perl

use lib 'lib';
use lib '../lib';

use 5.006;
use strict;
use warnings;
use Test::Modern;

use My::ReneSenses::MyOsxTools;

use Carp;

	check_os();


	my @input_vols = ('Macintosh_HD', 'foo', 'TIGER');
	my @res_input_vols = map { is_localvolume($_) } ( @input_vols ); 

	is ($res_input_vols[0],'1','is_local_volume(Macinstosh_HD)');
	is ($res_input_vols[1],'0','is_local_volume(foo)'); 
	is ($res_input_vols[2],'1','is_local_volume(TIGER)');

done_testing;