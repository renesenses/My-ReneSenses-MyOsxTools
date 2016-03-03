package My::ReneSenses::MyOsxTools;

use 5.018004;
use strict;
use warnings;

use Data::Dumper;
use XML::Simple qw(:strict);
use Mac::PropertyList qw(:all);
use Ref::Util qw(:all);
use File::stat;
use Mac::Errors qw( $MacError %MacErrors );
use Tie::File;
use Carp;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use My::ReneSenses::MyOsxTools ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.


our %EXPORT_TAGS = ( 'all' => [ qw(
	$default_tmp_file
	check_os
	get_os_error
	is_localvolume	
	write_diskutil_plist
	write_diskutil_byvolname_plist
	get_mountedpoints_in_VolumesDir
	get_diskid_from_volume
	is_anhashkey
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	$default_tmp_file
	check_os
	get_os_error
	is_localvolume	
	write_diskutil_plist
	write_diskutil_byvolname_plist
	get_mountedpoints_in_VolumesDir
	get_diskid_from_volume
	is_anhashkey
);

our $VERSION = '0.01';


# Preloaded methods go here.

our $default_tmp_file = '/tmp/diskutil.plist';  
my $default_perl;
my $vol_file;
# my %vol_perl;
my $vol_perl;

=head1 FUNCTION check_os

 This function die if OS is not Mac OS X.

=cut

sub check_os {
	if ( !($^O eq 'darwin') ) {
		croak "Only Mac OS X supported"; 
	}
}

=head1 FUNCTION get_os_error

 This function prints Text corresponding to OsErrNo.

=cut

sub get_os_error {
	my $err =shift;
	my $errText = $err;
	if ( $MacErrors{$err} ) {
    	printf("%s\n", $errText) ;
	}	
}

=head1 FUNCTION write_diskutil_plist

 This function creates the plist file corresponding to "diskutil list -plist" command .

=cut

sub write_diskutil_plist {
	my $file = shift;
	if (-e $file) {
		unlink $file || croak "Cant remove `$file`";
	}
	open(OUTPUT_PLIST, ">$file")
		or croak "Can't open `$file`";
	my $plist = `diskutil list -plist`;
	print $plist,"\n";
	print(OUTPUT_PLIST $plist)
		or croak "Can't write in `$file`";
	close(OUTPUT_PLIST)
		or carp "Can't close `$file`"; 
}

=head1 FUNCTION write_diskutil_byvolname_plist

 This function creates the plist file corresponding to "diskutil info -plist $vol_name" command.
 Input : a volume's name.

=cut

sub write_diskutil_byvolname_plist {
	my ($vol_name) = shift;
	$vol_file = '/tmp/diskutil-'.$vol_name.'.plist';
	
	if (-e $vol_file) {
		unlink $vol_file || croak "Cant remove `$vol_file`";
	}
	if ( !(is_localvolume($vol_name)) ) {
		croak "`$vol_name` is not recognized";
	}
	else { 
		open(OUTPUT_PLIST, ">$vol_file")
			or croak "Can't open `$vol_file`";
		my $plist = `diskutil info -plist $vol_name`;
		print $plist,"\n";
		print(OUTPUT_PLIST $plist)
			or croak "Can't write in `$vol_file`";
		close(OUTPUT_PLIST)
			or carp "Can't close `$vol_file`"; 
	}
}

sub get_mountedpoints_in_VolumesDir {
	opendir(my $dh, "/Volumes") || croak "Can't get in /Volumes";

	my @mounted_dirs = readdir($dh); 
	my @mounted_points;
	foreach my $ind (0 .. $#mounted_dirs) {
		if ( !($mounted_dirs[$ind] =~ /^\./) ) {
			push @mounted_points,$mounted_dirs[$ind];
		}
	}
	closedir $dh;
	return @mounted_points;
}



sub is_localvolume {
	my $vol =shift;
	my %VOLUMES;
	write_diskutil_plist($default_tmp_file);
	my $data = parse_plist_file($default_tmp_file);
	
	$default_perl = $data->as_perl;
#	print Dumper($perl);
#	check_perl($perl);

	foreach my $hash_vol ( @{ ${ $default_perl}{'VolumesFromDisks'}} ) {
		# stat du mountedpoint
		#$VOLUMES{$hash_vol} = (stat($ARGV[$arg]))[0];;
		$VOLUMES{$hash_vol}++;
	}
#	print Dumper(%VOLUMES);
	if ( $VOLUMES{$vol} ) {return 1}
	else {return 0}; 
}

sub check_perl {
	my $perl = shift;
	foreach my $key ( keys %{$perl} ) {
		print "key : ",$key,"\t";
		if ( is_arrayref(${ $perl}{$key}) ) {
			print join(", ",@{ ${ $perl}{$key}}),"\n";
		}
		elsif ( is_scalarref(${ $perl}{$key}) ) {
			print ${ $perl}{$key},"\n";
		}	
		else {
			print "Value : \t",${ $perl}{$key} ,"\n";
		}
	}
}


sub get_diskid_from_volume {
	my $input = shift;
	my $key = 'DeviceIdentifier';
	if (is_localvolume($input) ) {	
		check_perl($vol_perl);
		return ${ $vol_perl}{$key};
	}			
}


sub build_hash_perl_from_plist {
	my $plist_file = shift;
	my $data = parse_plist_file($plist_file);
	my $vol_perl = $data->as_perl;
	return $vol_perl;
}


sub get_keys_from_hash {
	my $hash = shift;
	my @keys = sort ( keys %{ $hash} );
	return @keys;
}	
	
sub is_anhashkey {
	my ($key, $hash) = @_;
	my @keys = get_keys_from_hash($hash);
	my %KEYS;
	for my $k (@keys) {
		$KEYS{$k}++;
	}
	if ( $KEYS{$key} ) {
		return 1;
	} 
	else {
		return 0;
	}		
}		

sub get_keyvalue_from_volume {
	my ($key,$input) = @_;
	if ( is_localvolume($input) ) {	
		return ${ $vol_perl}{$key};
	}
	else {
		croak "`$key`is not a valid key";
	}		
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

My::ReneSenses::MyOsxTools - Perl extension for Mac OS X Volumes management

=head1 SYNOPSIS

  use My::ReneSenses::MyOsxTools;
  

=head1 DESCRIPTION

A few functions around Volume concept in OS X.

=cut



=head1 SEE ALSO

Didn't find any.

=head1 AUTHOR

renesenses, E<lt>renesenses@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by renesenses

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
