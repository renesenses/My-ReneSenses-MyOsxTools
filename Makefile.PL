use 5.018004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'My::ReneSenses::MyOsxTools',
    VERSION_FROM      => 'lib/My/ReneSenses/MyOsxTools.pm', # finds $VERSION
    PREREQ_PM         => {
    	'Data::Dumper'             => '2.1.54',
        'XML::Simple'        	   => '2.22',
        'Mac::PropertyList'        => '1.41',
        'Ref::Util'                => '0.008',
        'File::stat'               => '1.02',
        'Mac::Errors'              => '1.18',
        'Tie::File'                => '0.99',
        'Carp'                     => '1.29',
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/My/ReneSenses/MyOsxTools.pm', # retrieve abstract from module
       AUTHOR         => 'renesenses <renesenses@gmail.com>') : ()),
);
