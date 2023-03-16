#!\usr\bin\perl

##################################
# Proof of Concept for pulling HTML Source Code from a webpage
##################################

#########################################################
# Script is used to obtain the Source Code
# from the MWL website.
#########################################################

use LWP::Simple;

$url = "http://www.mechwarriorleagues.com/cgi-bin/leagues/ladderleague.cgi?action=viewChallenge&challengeid=21329";

# Save the page locally
open(STDOUT, ">test/sourcecode.txt") or die "Couldn't open sourcecode.txt";

getprint ($url);


close(STDOUT);
