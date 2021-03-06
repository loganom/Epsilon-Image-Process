#!/usr/bin/perl -w

use strict;
use warnings;

use Cwd qw(abs_path);
use Path::Class qw(file);
use Data::Dumper qw(Dumper);

use Text::CSV;
my $csv = Text::CSV->new({ sep_char => ',' });

my $directory = file(abs_path($0))->dir;

my $img_directory = $directory . "/share/img/img/";

opendir (DIR, $img_directory) or die $!;

# create arrays if we successfully opened the dir
my @image_id; # array of image id numbers

my $roster_file = "$directory/share/roster/roster.csv";
my $list_file = "$directory/share/img/list/list.csv";

my $roster_length = `wc -l $directory/share/roster/roster.csv`;
my $list_length = `wc -l $directory/share/img/list/list.csv`;

my $roster_line_count;
my $list_line_count;

if($roster_length =~ /^(\d+)(?:.*)$/) {
	$roster_line_count = $1;
}

if($list_length =~ /^(\d+)(?:.*)$/) {
	$list_line_count = $1;
}

if($roster_line_count != $list_line_count){
	die "Verify that roster.csv and list.csv are the same length\n";
}

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

sort_csv("share/img/list/list");
sort_csv("share/roster/roster");

my %first = read_to_hash("$directory/share/roster/roster_sorted.csv");
my %second = read_to_hash("$directory/share/img/list/list_sorted.csv");

my %third = (%first,%second);

create_dirs();

# sort csv sort the csv that is passed to this function
sub sort_csv {
	my $file = $_[0];
	# sort and create a new file in the same directory with sorted data for both files
	system("head -1 $directory/$file.csv > $directory/$file\_sorted.csv");
	system("sed '1d' $directory/$file.csv | sort -d -k3 -t, >> $directory/$file\_sorted.csv");
}

# create_dirs create directories for new members 
sub create_dirs {
	foreach(@image_id) { 
		my $error;
		my $path;
		my $v = 0;
		while($v < $roster_line_count) {
			if($_  == $third{IMG_ID}->[$v]){
				$path = $directory . "/share/output/$third{ID}->[$v]";
				mkdir $path or $error = $!;
				unless (-d $path) {
				    die "Cannot create directory '$path': $error.";
				}
				system("mv $directory/share/img/img/IMG_$third{IMG_ID}->[$v].JPG $path");
				print(".");
			}
			$v++;
		}
	}
	print("DONE\n");
}

# read_to_hash reads in a csv file and converts it to a hash
sub read_to_hash {
	open(INPUT,$_[0]) or die "ERR";
	my @columns;
	my %hash;
	while(<INPUT>) {
		chomp;
		my $index=0;
		push @{$columns[$index++]},$1 while /([^,]+)/g;
	}
	my @headings=map {shift @$_} @columns;
	@hash{@headings}=@columns;
	close(INPUT);
	return %hash;
}