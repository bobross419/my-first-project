#!usr/bin/perl

##############################################################
#
# Contact: dont@gmail.com
# Created: 10/17/2010
# PERL: Strawberry on Padre under Windows XP
#
# Script to parse Matches without needing to use the /garbage/ folder
# or the temporary match#.txt files.  Everything will be handled
# in memory.
#
# This script takes a single argument that is the unit's MWL ID number,
# which can be found at the end of the URL for the unit's View Unit page
# on MWL.
# 
# Example:
# http://www.mechwarriorleagues.com/cgi-bin/leagues/unit.cgi?action=viewUnitOnline&unitid=257
# UnitID = 257
# 
# The output will be an Excel 2003 spreadsheet containing the pertinent data and
# will be named "UNITNAME Battle History TODAYSDATE.xls".
#
# In addition to the base PERL install, the following modules will need to be installed:
#	* Date::Simple
#	* LWP::Simple
#	* Spreadsheet::WriteExcel
#	* WWW::Mechanize
#
# If you need assistance with these installs email me at dont@gmail.com	
##############################################################
$|++;

use WWW::Mechanize;
use LWP::Simple;
use Spreadsheet::WriteExcel;
use Date::Simple ('date','today');

if ($ARGV[0]=~/help/)
{
	printHelp();
}

$unitID = $ARGV[0];
$urlMissingID = "http://www.mechwarriorleagues.com/cgi-bin/leagues/unit.cgi?action=viewUnitOnline&unitid=";
$unitName;
$date = today();

print STDOUT "Getting URL List...\r";
@links = getURLList();
@matches = pullMatchHTML();
@finalText = parseMatchToCommaDelimited();

print STDOUT "Creating Excel Document...";

my $workbook = Spreadsheet::WriteExcel->new("$unitName Battle History $date.xls");
$worksheet = $workbook->add_worksheet('Match Data');

my $headerFormat = $workbook->add_format();
$headerFormat->set_color('white');
$headerFormat->set_bg_color('black');

@header = split(",", "Date,Attacker,Defender,Game Type,League,Randomizer,Chassis Restriction,Weapon Restriction,Map,Drop Restriction,Radar,Time of Day,Weather,FFP,Stock,JJ Restriction,Winner,Loser");

###################
#
# Column Format Information
{
	$worksheet->set_column('N:O', 5, undef, 0, 2);
	$worksheet->set_column('M:M', 8, undef, 0, 2);
	$worksheet->set_column('A:A', 10);
	$worksheet->set_column('F:F', 10, undef, 0, 1);
	$worksheet->set_column('L:L', 10, undef, 0, 2);
	$worksheet->set_column('P:P', 11, undef, 0, 2);
	$worksheet->set_column('K:K', 15, undef, 0, 2);
	$worksheet->set_column('D:D', 20);
	$worksheet->set_column('B:C', 25);
	$worksheet->set_column('I:I', 28);
	$worksheet->set_column('E:E', 33);
	$worksheet->set_column('H:H', 33, undef, 0, 1);
	$worksheet->set_column('J:J', 33);
	$worksheet->set_column('Q:R', 33);
	$worksheet->set_column('G:G', 53, undef, 0, 1);
	
	$worksheet->autofilter('D1:P1');
	$worksheet->freeze_panes('A2');
	
	$workbook->set_properties(
		author => 'Bob Ross',
		comments => 'Created with PERL and Spreadsheet::WriteExcel for Clan WidowMaker');
	
	$worksheet->add_write_handler(qr/^=/, \&write_my_id);
}
# End column format
# 
####################	

for (@finalText)
{
	my @columns = split(",", $_);
	$length = @columns;
	if ($length == 25)
	{
		@columns[2] =~ m/(.+) vs. (.+)/i;
		@columns[3] = substr(@columns[3],0,10);
		push (my @row1, (@columns[3],$1,$2,@columns[0],@columns[1],@columns[4],@columns[5],@columns[6],@columns[7],@columns[8],@columns[13],@columns[14],@columns[15],@columns[16],@columns[17],@columns[18],@columns[19],@columns[20]));
		push (my @row2, (@columns[3],$1,$2,@columns[0],@columns[1],@columns[4],@columns[5],@columns[6],@columns[9],@columns[10],@columns[13],@columns[14],@columns[15],@columns[16],@columns[17],@columns[18],@columns[21],@columns[22]));
		push (my @row3, (@columns[3],$1,$2,@columns[0],@columns[1],@columns[4],@columns[5],@columns[6],@columns[11],@columns[12],@columns[13],@columns[14],@columns[15],@columns[16],@columns[17],@columns[18],@columns[23],@columns[24]));
		push(@final, \@row1);
		push(@final, \@row2);
		push(@final, \@row3);
	}
}

$worksheet->write(A1, \@header, $headerFormat);$worksheet->write(A2, [\@final]);
print "DONE!\n";




sub getURLList
{
	my $mech = WWW::Mechanize->new();
	
	$mech->get("$urlMissingID$unitID") or die "\nUnable to Reach $urlMissingID$unitID type -help for assistance.\n";
	
	$mech->content() =~ /CLASS=NewHeaderSectionTop>(.+)<\/TD>/i;
	if ($1 eq "ERROR!")
	{
		die "\nInvalid Unit ID ($unitID), please check the URL and try again.  Type -help for assistance.\n";
	}
	
	
	$unitName = $1;
	
	
	my @linkList;
	my @links = $mech->find_all_links(url_regex => qr/challengeid/i);
	for (@links)
	{
		$_->url() =~ /challengeid=(\d+)/i;
		push(@linkList, "http://www.mechwarriorleagues.com" . $_->url());
	}
	
	print STDOUT "Getting URL List...DONE!\n";
	return @linkList;
}

sub pullMatchHTML
{
	@htmlcode;
	print STDOUT "Getting HTML Code..";
	
	for (@links)
	{
		print STDOUT ".";
		push(@htmlcode, get($_));
		print STDOUT "\b";
	}
	print STDOUT ".DONE!\n";
	return @htmlcode;
}

sub parseMatchToCommaDelimited
{
	@finalInformation;
	
	for (@matches)
	{
		
		print STDOUT "Parsing Matches..\r";
		my @lines = split("\n", $_);
		$flag = 0;
		
		for (@lines)
		{
			$flag = 1 if ($_ =~/Game Type:/);
			$flag = 0 if ($_ =~m/Online League Management Software/);
			
			if ($flag == 1)
			{
				s/^\s//;
				s/<.*?>//g;
				s/&nbsp;//;
			}
			else
			{
				s/.*//;
				s/^\s+//;
			}
			s/^\s+//;
		}
		
		@lines = grep (m/\S/, @lines);
		
		my $newflag = 1;
		for ( @lines ) 
		{
			if (($newflag == 1) | ($newflag == 3) | ($newflag == 4) | ($newflag == 5) | ($newflag == 7) | ($newflag == 9) | ($newflag == 10) |
				($newflag == 11) | ($newflag == 12) | ($newflag == 13) | ($newflag == 14) | ($newflag == 16) | ($newflag == 18) | ($newflag == 20) | 
				($newflag == 22) | ($newflag == 24) | ($newflag == 27) | ($newflag == 30) | ($newflag == 32) | ($newflag == 34) | ($newflag == 36) | 
				($newflag == 38) | ($newflag == 40) | ($newflag == 42) | ($newflag == 44) | ($newflag == 45) | ($newflag == 46) | ($newflag == 47) |
				($newflag == 48) | ($newflag == 49) | ($newflag == 50) | ($newflag == 53) | ($newflag == 54) | ($newflag == 57) | ($newflag == 58))
			{
				s/.*//;
				s/^\s+//;
				s/\s+$//;
			}
			elsif (($newflag == 25) | ($newflag == 28) | ($newflag == 31))
			{
				s/,//;
				s/,//;
				s/,//;
				s/\s+$/,/;
			}
			elsif ($newflag == 60)
			{
				s/\s+$//;
			}
			$newflag++; 
			
		}
		@lines = grep (m/\S/, @lines);
		push(@finalInformation, join(",", @lines));
		
	}
	print STDOUT "Parsing Matches...DONE!\n";
	return @finalInformation;	
}

sub printHelp
{
	die "
Contact: dont\@gmail.com
Created: 10/17/2010
PERL: Strawberry on Padre under Windows XP


This script takes a single argument that is the unit's MWL ID number,
which can be found at the end of the URL for the unit's View Unit page
on MWL.

Example:
http://www.mechwarriorleagues.com/cgi-bin/leagues/unit.cgi?action=viewUnitOnline&unitid=257

UnitID = 257

Command Line should read:
> perl MMPv2.pl 257

The output will be an Excel 2003 spreadsheet containing the pertinent data and
will be named 'UNITNAME Battle History TODAYSDATE.xls'.

In addition to the base PERL install, the following modules will need to be installed:
	* Date::Simple
	* LWP::Simple
	* Spreadsheet::WriteExcel
	* WWW::Mechanize

This may not function properly if you need to connect through a proxy, the functionality
is very limited and other methods may be required for pulling the information.

If you need assistance with these installs or running the program in general email me at dont\@gmail.com\n";
}


sub write_my_id {
       my $worksheet = shift;
       return $worksheet->write_string(@_);
}
