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

=begin comment
sub parse_df {
	my $input_loc = shift;
	if (-d $input_loc) { local $CWD = $input_loc; };
	my $SEPARATOR = qw/\s+/;
	my @columns_names = qw(Filesystem 512-blocks Used Available Capacity iused ifree %iused Mounted on);
 	my @rs;
	my $cmd = `df .`;
	
	# split by eol
	
	print Dumper($cmd);
	my @res = split($SEPARATOR,$cmd);
#	print Dumper(@res); 
 	print join(" ",$res[0]),"\n";
 	print join(" ",@columns_names),"\n";
 	if ( !( join(" ",$res[0]) eq join(" ",@columns_names) ) ) {
 		croak "df command result columns names differ from expected";
 	}
 	else {
 		for my $line (1..$#res) {
 			if ( $res[$line] =~ /([0-9]+)([0-9]+)([0-9]+)((?<!-)\b([1-3]?\d{1,2}|100)\b%)([0-9]+)([0-9]+)((?<!-)\b([1-3]?\d{1,2}|100)\b%)/ ) {
 				@rs = ($`, $1, $2, $3, $4, $7, $8, $9, $');
 			}
 			else {
 				croak "Unexpected error";
 			}	
 		}
 	}	
 	return @rs;	 
}




	$test->run(chdir => $mnt_point, 
              stdout => <<_EOF_);
Filesystem 512-blocks  Used Available Capacity iused ifree %iused  Mounted on
/dev/disk6      28672 18472     10200    65%    2307  1275   64%   /Volumes/DiskMaker X
_EOF_

=end comment
=cut


use lib 'lib';
use lib '../lib';

use 5.006;
use strict;
use warnings;

use Test::Modern;
#use Test::More tests >= 3;
use Test::File::Contents;

use My::ReneSenses::MyOsxTools;

use File::chdir;
use Test::Cmd;
use Data::Dumper;

my $test0 = Test::Cmd->new( prog => 'foo', workdir => '' );
$test0->run();
is( $? >> 8,       127,       '127 (command not found) exit status' );


my $test1 = Test::Cmd->new( prog => '/Users/renesenses/MY_GITHUB/My-ReneSenses-MyOsxTools/t/outerr', workdir => '' );
$test1->run();
is( $? >> 8,       1,       '1 (Ok) exit status' );

my $test5 = Test::Cmd->new( prog => './outerr', workdir => '/Users/renesenses/MY_GITHUB/My-ReneSenses-MyOsxTools/t/tmp' );
$test5->run();
is( $? >> 8,       1,       '1 (Ok) exit status with /tmp workdir' );

my $dmg = '/Users/renesenses/Downloads/DiskMaker_X_503.dmg';
my $mnt_point = '/Volumes/DiskMaker X';

is(-e $dmg, '1', 'Ok, dmg available for mounting');
my $cmd = `hdiutil attach $dmg`;
is (-e($mnt_point),'1','Ok, dmg mounted and available for, testing');

my $test7 = Test::Cmd->new( prog => 'hdiutil attach /Users/renesenses/Downloads/DiskMaker_X_503.dmg', workdir => '' );
$test7->run();
is( $? >> 8,1,'1 (Ok) exit status for hdiutil ... Diskmaker.dmg' );


my $test2 = Test::Cmd->new( 	string => 'df .',
							prog => '/bin/df',
							interpreter => '/bin/bash',
							workdir => '',
							args => $mnt_point);
$test2->run;
is( $? >> 8, 126, '126 (Command invoked cannot execute) exit status');


my $test3 = Test::Cmd->new( 	string => 'df .',
							prog => '/bin/df /Volumes/DiskMaker X',
							interpreter => '/bin/bash',
							workdir => '');
$test3->run;
is( $? >> 8, 126, '126 (Command invoked cannot execute) exit status' );
done_testing;