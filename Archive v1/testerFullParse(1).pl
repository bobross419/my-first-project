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
$numberOfMatches = 0; 
$matchNumber = 1000;

ParseGameListToURLs();
#PullMatchHTML();

while ($matchNumber < $numberOfMatches)
{
	++$matchNumber;
	ParseMatchToCommaDelimited();
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

ParseMatchToCommaDelimited{
	$file = "garbage/match$matchNumber.txt";
	$fileOut = "matchData.txt";
	
	#Open the file and read data
	#Die with grace if it fails
	open (FILE, "<$file") or die "Can't open $file: $!\n";
	@lines = <FILE>;
	close FILE;

	#Open same file for writing, reusing STDOUT
	open (STDOUT, ">$fileOut") or die "Can't open $file: $!\n";
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
	open (STDOUT, ">$fileOut") or die "Can't open $file: $!\n";


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
	    
	    print;
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
	open (STDOUT, ">$fileOut") or die "Can't open $file: $!\n";

	# $flag == 0 causes full line to be deleted.
	$flag = 0;

	# Step through each line
	for ( @lines ) {
	    
	    if ( m/(League|Challenge|Scheduled|Randomizer|Mech Chassis|Weapons Restrictions|Radar Setting|Time of Day|Weather|FFP|Stock|Jump Jets|Maps|Defender|Winner|Loser)/i)
	    {
		if (m/Challenge Issued/i)
		{
		    $flag = 0;
		}
		elsif (m/Challenge Results/i)
		{
		    $flag = 3;
		}
		else
		{
		    s/.*//;
		    s/^\s+//;
		    s/\s+$//;
		    $flag = 1;
		}
	    }
	    if ( m/Preferred Playtimes/i )
	    {
		s/.*//;
		s/^\s+//;
		s/\s+$//;
		$flag = 0;
	    }
	    
	    if ( m/^[1-3]/ )
	    {
		s/.*//;
		s/^\s+//;
		s/\s+$//;
	    }  
	    
	    # If $flag == 0 then the line should be deleted
	    if ( $flag != 1 )
	    {
		s/.*//;
		s/^\s+//;
		s/\s+$//;
	    }
	    
	    
	    # If $flag > 0 then only the next line should be saved and delimited
	    if ( $flag == 1 )
	    {
		s/\s+$/,/;
		#$flag--;
	    }
	   
	    print;
	}

	close STDOUT;
	
}
