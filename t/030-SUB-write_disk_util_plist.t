#! /usr/bin/env perl

# testing sub write_diskutil_plist

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

my $test_file = '/tmp/test.txt';

if (-e $default_tmp_file) { unlink $default_tmp_file; }
is (-e $default_tmp_file, undef, 'default_tmp_file does not exists'); 

write_diskutil_plist($default_tmp_file);

is (-e $default_tmp_file, 1, 'default_tmp_file created');

file_contents_ne($default_tmp_file,'','Non empty our default_tmp_file');
 
#file_contents_eq($default_tmp_file,   'ååå', { encoding => 'UTF-8' });

done_testing;