#! /usr/bin/env perl

# To add :
# get user account to compute

# Protocol for easily performs basic tests :
#	- use dmg files (content never changes) 

=begin comment

ST FOR Later ...
my @results = map { parse_df($_) } @locations;

subtest 'parse_df locations' => sub {
	isnt (-d($results[0]),'1','ok slash dir exists');
	is (-d($locations[1]),'1','ok dot dir exists');
	isnt (-d($locations[2]),'1','ok foo bar dir does not exist');
	is (-d($locations[3]),'1','ok slash tmp dir exists');
	isnt (-d($locations[4]),'1','user bash_profile file is not a dir');
}; 

=end comment
=cut
# A TE

use lib 'lib';
use lib '../lib';

use 5.006;
use strict;
use warnings;

use Test::Modern;
#use Test::More tests >= 8;
use Test::File::Contents;

use My::ReneSenses::MyOsxTools;

use File::chdir;

my $dmg = '/Users/renesenses/Downloads/DiskMaker_X_503.dmg';
my $mnt_point = '/Volumes/DiskMaker X';

# my $dmg = '/Users/renesenses/Downloads/DiskMaker  X 503.dmg';

can_ok('Test::Modern','require_ok');



subtest 'dmg' => sub {
	is(-e $dmg, '1', 'Ok, dmg available for mounting');
	my $cmd = `hdiutil attach $dmg`;
	is (-e($mnt_point),'1','Ok, dmg mounted and available for, testing');

	local $CWD = $mnt_point;

	my @resdmg = parse_df($CWD);
	is ($resdmg[0],'/dev/disk6','Filesystem');
	is ($resdmg[1],'28672','512-blocks');
	is ($resdmg[2],'18472','Used');
	is ($resdmg[3],'10200','Available');
	is ($resdmg[4],'65%','Capacity');
	is ($resdmg[5],'2307','iused');
	is ($resdmg[6],'1275','ifree');
	is ($resdmg[7],'64%','%iused');
	is ($resdmg[8],'/Volumes/DiskMaker X','Mounted on');
};

can_ok('My::ReneSenses::MyOsxTools','check_os');

can_ok('My::ReneSenses::MyOsxTools','parse_df');

my @locations = ('/','.','/foo/bar','/tmp','~/.bash_profile');

subtest 'chdir locations' => sub {
	is (-d($locations[0]),'1','ok slash dir exists');
	is (-d($locations[1]),'1','ok dot dir exists');
	isnt (-d($locations[2]),'1','ok foo bar dir does not exist');
	is (-d($locations[3]),'1','ok slash tmp dir exists');
	isnt (-d($locations[4]),'1','user bash_profile file is not a dir');
}; 




done_testing;