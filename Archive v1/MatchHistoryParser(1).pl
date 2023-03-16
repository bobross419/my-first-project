#!\usr\bin\perl

################################################################
# 
# Parsing Script - Pulls from a locally stored source file,
# then pulls the match specific URLs, then downloads the source
# for the individual matches.  Each match will be parsed into a
# comma-delimited format.
#
# teamgamelist.txt - Source code for the Clan's webpage is stored here
# This file must exist in the same directory as MatchHistoryParser.pl
################################################################

############################################
# teamgamelist.txt - Source code for the Clan's webpage is stored here
## #########################################

use LWP::Simple;
use Text::CSV;
$numberOfMatches = 0; 
$matchNumber = 0;

mkdir("garbage");

ParseGameListToURLs();
PullMatchHTML();

opendir(DIR, "garbage") or die "can't opendir Garbage";

while ($file = readdir(DIR))
{
	unless (-d "$file")
	{
		$numberOfMatches++;
	}
}
closedir(DIR);

for ($count = 1; $count <= $numberOfMatches; $count++)
{
	ParseMatchToCommaDelimited($count);
}

FormatCSV();
rmdir("garbage");



sub ParseGameListToURLs
{
	#Specify the file
	$file = "teamgamelist.txt";
	
	########################################################
	# This section will remove all of the lines that don't
	# contain URL information for the individual matches
	########################################################

	#Open the file and read data
	#Die with grace if it fails
	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;

	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">$file") or die "Can't open $file: $!\n";


	# Walk through lines, delete any line that does not contain 
	# the string "challengeid"
	for ( @lines ) {
		unless (m/challengeid/i)
		{
			s/.*//;
			s/^\s+//;
			s/\s+$//;
		}
    
	print;
	}

	close STDOUT;


	########################################################
	# This section will remove HTML code
	# The remainder will be the URLs needed for
	# individual matches.
	########################################################

	#Open the file and read data
	#Die with grace if it fails
	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;

	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">$file") or die "Can't open $file: $!\n";


	# Walk through each line, remove non-URL information
	for ( @lines ) {
		s/^\s+/http:\/\/www.mechwarriorleagues.com/;
		s/<TD.*?>//;
		s/<A HREF="//;
		s/"><IMG.*>//;
   
	print;
	}

	close STDOUT;
}

sub PullMatchHTML
{
	$file = "teamgamelist.txt";
	
#	$url = "http://www.mechwarriorleagues.com/cgi-bin/leagues/ladderleague.cgi?action=viewChallenge&challengeid=21329";
	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;
	
	for ( @lines )
	{
		$NumberOfMatches++;
		
		$url = $_;
		$fileOut = "garbage/match$NumberOfMatches.txt";
		
		# Save the page locally
		open(STDOUT, ">$fileOut") or die "Couldn't open $fileOut";

		getprint ($url);

		close(STDOUT);
	}
	unlink("$file");
}

sub ParseMatchToCommaDelimited{
	my $matchNum = @_;
	$file = "garbage/match$count.txt";
	$fileOut = "matchData.txt";
	
	#Open the file and read data
	#Die with grace if it fails
	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;

	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">$file") or die "Can't open $file: $!\n";
	$flag = 0;
	#Walk through lines, replace < > tags with nothing.
	for ( @lines ) {
	    # $flag is used to clear out everything down to the Game Type:
	    # No preceding information is needed for tallying results
	    if (m/Game Type:/)
	    {
		$flag = 1;
	    }
	    
	    # Remove extra text at the end of the file
	    if (m/Online League Management Software/)
	    {
		$flag = 2;
	    }
	    # Clear everything, including white space, on the line
	    if ($flag == 0)
	    {
		s/.*//;
		s/^\s+//;
	    }
	    if ($flag == 1)
	    {
		#Remove leading white space
		s/^\s+//;
		#Remove HTML Tags
		s/<.*?>//;
		s/<.*?>//;
		s/<.*?>//;
		s/<.*?>//;
		s/<.*?>//;
		s/<.*?>//;
		#Remove &nbsp tags
		s/&nbsp;//;
	    }
	    if ($flag == 2)
	    {
		s/.*//;
		s/^\s+//;
	    }
	    #Remove Trailing white space
	    #s/\s+$//;
		
	    print;
	}

	#Finish up
	close STDOUT;

	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;

	#########################################
	# Walk through remaining lines
	# Remove white space and empty lines
	#########################################

	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">$file") or die "Can't open $file: $!\n";


	$flag = 0;

	# Step through each line
	for ( @lines ) {
	    # Clear empty lines
	    if ( m/^$/ )
	    {
		s/.*//;
		s/^\s+//;
		s/\s+$//;
	    }
	    unless ( m/\S/ )
	    {
		s/.*//;
		s/^\s+//;
		s/\s+$//;
	    }
	    
	    print ;
	}

	close STDOUT;

	#########################################################################
	# Walk through remaining lines
	# Remove extraneous information
	# Leave in comma-delimited format:
	#
	# League, vs., Date, Chassis Restriction, Weapon Restriction, Map1, 
	# Restrictions1, Map2, Restrictions2, Map3, Restrictions3, Radar, ToD, 
	# Weather, FFP, Stock, JJ Restriction, Map1, Winner1 Score, Loser1 Score,
	# Map2, Winner2 Score, Loser2 Score, Map3, Winner3 Score, Loser3 Score.
	#########################################################################

	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;
	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">>$fileOut") or die "Can't open $file: $!\n";

	# $newflag == 0 causes full line to be deleted.
	$newflag = 1;

	# Step through each line
	for ( @lines ) {
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
	    else
	    {
		    s/\s+$/,/;
	    }
	    
	    $newflag++; 
	    
	   
	    print STDOUT;
	    
	}
	print STDOUT "\n";
	close STDOUT;
	unlink("$file");
	
}

sub FormatCSV
{
	my $fileIn = 'matchData.txt';
	my $oldCSV = Text::CSV->new();
	my $fileOut = 'matchDataParsed.txt';
	
	open (CSV, "<$fileIn") or die "Unable to open $fileIn";
	open (CSVOUT, ">$fileOut") or die "Unable to open $fileOut";
	print CSVOUT "Game Type,League,Attacker,Defender,Date,Randomizer,Chassis Restriction,Weapon Restriction,Map,Drop Restriction,Radar,Time of Day,Weather,FFP,Stock,JJ Restriction,Winner,Loser\n"; 
	close CSVOUT;
	while (<CSV>)
	{
		if ($oldCSV->parse($_))
		{
			my @columns = $oldCSV->fields();
			if (@columns == 25)
			{
				@columns[2]=~s/\svs\.\s/,/;
				@columns[3]= substr(@columns[3],0,10);
				open (CSVOUT, ">>$fileOut") or die "Unable to open $fileOut";
				print CSVOUT "@columns[0],@columns[1],@columns[2],@columns[3],@columns[4],@columns[5],@columns[6],@columns[7],@columns[8],@columns[13],@columns[14],@columns[15],@columns[16],@columns[17],@columns[18],@columns[19],@columns[20]\n";
				print CSVOUT "@columns[0],@columns[1],@columns[2],@columns[3],@columns[4],@columns[5],@columns[6],@columns[9],@columns[10],@columns[13],@columns[14],@columns[15],@columns[16],@columns[17],@columns[18],@columns[21],@columns[22]\n";
				print CSVOUT "@columns[0],@columns[1],@columns[2],@columns[3],@columns[4],@columns[5],@columns[6],@columns[11],@columns[12],@columns[13],@columns[14],@columns[15],@columns[16],@columns[17],@columns[18],@columns[23],@columns[24]\n";
				close CSVOUT;	
			}
		}		
	}
	close CSV;
	close CSVOUT;
	unlink("$fileIn");
}