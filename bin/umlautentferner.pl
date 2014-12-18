#!/usr/bin/perl
 
&processdir(".");
 
sub processdir
{
	local($path) = @_;
	local(@files);
	# print "Pfad: $path\n";
 
 	opendir(DIR,$path);
 	# @files=sort grep(/.*\.java/,readdir(DIR));
 	@files = readdir(DIR);
 	closedir(DIR);
 
 	for (@files)
	{
  		next if $_ =~ /^\./;
  		if (-d $path . "/" . $_)
  		{
 			&processdir($path . "/" . $_);
   		}
 		else
 		{
 			# print "loading $path/$_\n";
 			open(FILE,$path . "/" . $_);
 			@htmlfile = <FILE>;
 			close(FILE);
 
 			if ( grep(/[äöüßÄÖÜ]/i,@htmlfile) )
 			{
 				print "converting $path/$_\n";
 
 				# open(OUT,">$path/$_") or die "Ausgabedatei '$path/$_' konnte nicht geschrieben werden!";
 				#  				for (@htmlfile)
 				#  				{
 				#  					s/ä/ae/g;
 				#  					s/ö/oe/g;
 				#  					s/ü/ue/g;
 				#  					s/Ä/Ae/g;
 				#  					s/Ö/Oe/g;
 				#  					s/Ü/Ue/g;
 				#  					s/ß/ss/g;
 				#  					print OUT $_;
 				#  				}
 				#  				close(OUT);
 				#  			}
 		}
 	}
}
