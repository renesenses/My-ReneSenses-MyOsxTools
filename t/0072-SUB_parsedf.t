#! /usr/bin/env perl

# To add :
# get user account to compute

# Protocol for easily performs basic tests :
#	- use dmg files (content never changes) 

# NOTES 
# check_os not performed

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

use Capture::Tiny ':all';
 

my $dmg 			= '/Users/renesenses/Downloads/DiskMaker_X_503.dmg';
my $mnt_point 		= '/Volumes/DiskMaker X';

plan skip_all => 'Because DiskMaker_X_503.dmg required in downloads user homedir' if ( !(-e  $dmg) ) ;

# my $dmg = '/Users/renesenses/Downloads/DiskMaker  X 503.dmg';

can_ok('My::ReneSenses::MyOsxTools','parse_df');

SKIP:
{	

	my ($cmd, @args, $stdout, $stderr, $exit); 
	if ( -e $mnt_point ) {
		$cmd = 'lsof';
		@args = ( '-t', $mnt_point ); # ok
		($stdout, $stderr, $exit) = capture {
  			system( $cmd, @args );
		}; 
		is ( $stderr,'','Ok, lsof returns no error' );
		skip_all( 'Because /Volumes/DiskMaker X is already mounted and cant be unmounted due to at least an lsof pid') if ( $stderr ne "" ) ;
	}

	subtest 'attach dmg and check' => sub {
		$cmd = 'hdiutil';
		@args = ('attach', '-noverify', $dmg ); # ok
		($stdout, $stderr, $exit) = capture {
  			system( $cmd, @args );
		}; 
		is ( $stderr,'','Ok, hdiutil attach returns no error' );
		is ( -e($mnt_point),'1','Ok, /Volumes/DiskMaker X attached' );
		skip( 'Because hdiutil attach retunrs an error', 1)  if ( $stderr ne "" ) ;
	};

	subtest 'parse_df dmg' => sub {
			
			local $CWD = $mnt_point;

			my @rs = parse_df($mnt_point);
			
			is ($rs[0],'/dev/disk6','Filesystem');
			is ($rs[1],'28672','512-blocks');
			is ($rs[2],'18472','Used');
			is ($rs[3],'10200','Available');
			is ($rs[4],'65%','Capacity');
			is ($rs[5],'2307','iused');
			is ($rs[6],'1275','ifree');
			is ($rs[7],'64%','%iused');
			is ($rs[8],'/Volumes/DiskMaker X','Mounted on');
	
	};

	subtest 'parse_df /Volumes/DiskMaker\ X' => sub {

		local $CWD = $mnt_point;

		my @resdmg = parse_df('/Volumes/DiskMaker X');
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
}

done_testing;