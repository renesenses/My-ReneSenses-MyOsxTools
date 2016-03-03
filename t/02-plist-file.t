#! /usr/bin/env perl

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

if (-e $test_file) { unlink $test_file; }
 
my $test = `touch $test_file`;

file_contents_eq('/tmp/test.txt','', 'Writing /tmp/test.txt');
file_contents_ne($default_tmp_file,'','Non empty our default_tmp_file');
 
#file_contents_eq($default_tmp_file,   'ååå', { encoding => 'UTF-8' });

done_testing;