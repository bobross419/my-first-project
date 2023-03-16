#!\usr\bin\perl

#########################################################
# Script is used for the initial cleanup of the HTML code
# This will rip out any HTML tags
# Will leave the pertinent match information
#########################################################


#Specify the file
$file = "ladderleaguegame.txt";

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
open (STDOUT, ">$file") or die "Can't open $file: $!\n";

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
