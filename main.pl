#!/usr/bin/perl -w

use strict;
use warnings;

use Cwd qw(abs_path);
use Path::Class qw(file);

use Text::CSV;
my $csv = Text::CSV->new({ sep_char => ',' });

my $directory = file(abs_path($0))->dir;
my $img_directory = $directory . "/share/img/img/";

opendir (DIR, $img_directory) or die $!;

# create arrays if we successfully opened the dir
my @image_id; # array of image id numbers
my @member_id; # array of member id numbers

# get image file id number for all .JPG files in the /share/img/img 
# directory that match our criteria
while (my $file = readdir(DIR)) {
	if($file =~ /^(?:IMG_)(\d{4})(?:.JPG)$/) { # IMG_3333.JPG format
		my $image_id = $1 || ''; # $1 = 3333 or ''
		if($image_id ne '') { # push id if it exists 
			push(@image_id,$image_id);
		}
	}
}

closedir(DIR);

# see if there is any work to do
my $num_images = @image_id;
if($num_images == 0){
	print "No work to do.\nGoodbye.\n";
	exit();
}else{
	print "Images to process: $num_images\n";
}

my @list = read_list(); # list.csv data as an array
my @roster = read_roster(); # list.csv data as an array

# create_dirs create directories for new members 
sub create_dirs {
	foreach(@member_id) { #
		my $error;
		my $path = $directory . "/share/output/member/$_";
		mkdir $path or $error = $!;
		unless (-d $path) {
		    die "Cannot create directory '$path': $error.";
		}
	}
}

# read_list create an array from list.csv
# refactor read_list and read_roster to a single function 
sub read_list {
	my @list; # local array list
	my $entry_counter = 0;

	my $csv_data = $directory . "/share/img/list/list.csv";
	open(my $data, '<', $csv_data) or die "Could not open '$csv' $!\n";
	while(my $line = <$data>) { # while we have more data
		chomp $line; 

		if($csv->parse($line)) {
			my @row = $csv->fields(); # create local array to hold data
			push @{ $list[$entry_counter] }, @row; # add to local list array
		}
		$entry_counter++;
	}
	return @list; # return list
}

# read_roster create an array from roster.csv
# refactor read_list and read_roster to a single function 
sub read_roster {
	my @roster; # local array roster
	my $entry_counter = 0;

	my $csv_data = $directory . "/share/roster/roster.csv";
	open(my $data, '<', $csv_data) or die "Could not open '$csv' $!\n";
	while(my $line = <$data>) { # while we have more data
		chomp $line; 

		if($csv->parse($line)) {
			my @row = $csv->fields(); # create local array to hold data
			push @{ $roster[$entry_counter] }, @row; # add to local roster array
		}
		$entry_counter++;
	}
	return @roster; # return roster
}