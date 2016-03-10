#! /usr/bin/env perl

use lib 'lib';
use lib '../lib';

use 5.006;
use strict;
use warnings;
use My::ReneSenses::MyOsxTools;
use Test::Modern;

can_ok('Test::Modern','require_ok');
can_ok('Test::Modern','use_ok');

require_ok('My::ReneSenses::MyOsxTools');

can_ok('My::ReneSenses::MyOsxTools','check_os');

done_testing;