#! /usr/bin/env perl

# testing sub write_diskutil_byvolname_plist

# can be rewritten with SKIP 

use lib 'lib';
use lib '../lib';

use 5.006;
use strict;
use warnings;
use Test::Modern;
use utf8;
# use Test::More tests => 1;
use Test::File::Contents;
use My::ReneSenses::MyOsxTools;

use Carp;

#check_os();

# Must ensure tha status of all inputs 


my @input_vols = ('Macintosh_HD', 'foo', 'TIGER');
my @res_input_vols = map { is_localvolume($_) } ( @input_vols ); 

subtest 'is_localvolume' => sub {
	is ($res_input_vols[0],'1','is_local_volume(Macinstosh_HD)');
	is ($res_input_vols[1],'0','is_local_volume(foo)'); 
	is ($res_input_vols[2],'1','is_local_volume(TIGER)');
};

subtest 'check plist file does not exist' => sub {
	for my $ind (0..$#input_vols) {
		my $vol_file = '/tmp/diskutil-'.$input_vols[$ind].'.plist';
		if (-e $vol_file) { unlink $vol_file };
		isnt (-e $vol_file, 1, 'ok : plist file does not exists');
	}	
};

subtest 'check plist file exists' => sub {
	for my $ind (0..$#input_vols) {
		my $vol_file = '/tmp/diskutil-'.$input_vols[$ind].'.plist';
		if ($res_input_vols[$ind] == '1') { 
			write_diskutil_byvolname_plist($input_vols[$ind]); 
			is (-e $vol_file, 1, 'ok : plist file created');
			file_contents_ne($vol_file,'','Non empty `$vol_file`');
		} else {
			isnt (-e $vol_file, 1, 'ok : plist file not created vol does not exists');
		}
	}		
};

done_testing;