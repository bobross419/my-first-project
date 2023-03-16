#!\usr\bin\perl


##################################
# Proof of Concept for creating a list of match URLs
##################################


#########################################################
# Script is used for the initial cleanup of the HTML code
# This will rip out any HTML tags
# Will leave the URLs for each match
#########################################################


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