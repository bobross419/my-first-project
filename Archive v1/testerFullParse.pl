#!\usr\bin\perl

################################################################
# 
# Parsing Script - Pulls from a locally stored source file,
# then pulls the match specific URLs, then downloads the source
# for the individual matches.  Each match will be parsed into a
# comma-delimited format.
#
################################################################

###########################
# /garbage/ - Directory for waste assets
# teamgamelist.txt - Source code for the Clan's webpage is stored here
# /garbage/match#.txt - Files to store the pulled HTML code
# 

use LWP::Simple;
$numberOfMatches = 664; 
$matchNumber = 0;

ParseGameListToURLs();
#PullMatchHTML();
#while ($matchNumber < $numberOfMatches)
for ($count = 1; $count <= $numberOfMatches; $count++)
{
	ParseMatchToCommaDelimited($count);
}



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

	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">>$fileOut") or die "Can't open $file: $!\n";

	# $flag == 0 causes full line to be deleted.
	$flag = 1;

	# Step through each line
	for ( @lines ) {
	    if (($flag == 1) | ($flag == 3) | ($flag == 4) | ($flag == 5) | ($flag == 7) | ($flag == 9) | ($flag == 10) |
		($flag == 11) | ($flag == 12) | ($flag == 13) | ($flag == 14) | ($flag == 16) | ($flag == 18) | ($flag == 20) | 
		($flag == 22) | ($flag == 24) | ($flag == 27) | ($flag == 30) | ($flag == 32) | ($flag == 34) | ($flag == 36) | 
		($flag == 38) | ($flag == 40) | ($flag == 42) | ($flag == 44) | ($flag == 45) | ($flag == 46) | ($flag == 47) |
		($flag == 48) | ($flag == 49) | ($flag == 50) | ($flag == 53) | ($flag == 54) | ($flag == 57) | ($flag == 58))
	    {
		    s/.*//;
		    s/^\s+//;
		    s/\s+$//;
		    
	    }
	    elsif (($flag == 25) | ($flag == 28) | ($flag == 31))
	    {
		    s/,//;
		    s/,//;
		    s/,//;
		    s/\s+$/,/;
	    }
	    elsif ($flag == 60)
	    {
		    s/\s+$//;
	    }
	    else
	    {
		    s/\s+$/,/;
	    }
	    
	    $flag++; 
	    
	   
	    print STDOUT;
	    
	}
	print STDOUT "\n";
	close STDOUT;
	
}
