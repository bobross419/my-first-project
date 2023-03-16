#!\usr\bin\perl

##################################
# Proof of Concept for pulling HTML Source Code from a webpage
##################################

#########################################################
# Script is used to obtain the Source Code
# from the MWL website.
#########################################################

use LWP::Simple;
#use LWP::UserAgent;

      #$ua = new LWP::UserAgent;
      #$ua->timeout(5);
      #$ua->env_proxy; # initialize from environment variables
      # or
      #$ua->proxy(http  => 'www-proxy.sct.com:8080');
      #$ua->proxy(ftp  => 'www-proxy.sct.com:8080');
      #$ua->proxy(wais => 'www-proxy.sct.com:8080');
      #$ua->no_proxy(qw(no se fi));


$url = "http://www.mechwarriorleagues.com/cgi-bin/leagues/ladderleague.cgi?action=viewChallenge&challengeid=21329";

#my $html = get $url or die "Couldn't fetch page";


# Save the page locally
open(STDOUT, ">sourcecode.txt") or die "Couldn't open sourcecode.txt";

#getstore($url, "sourcecode.txt");
getprint ($url);


close(STDOUT);
