#!/usr/bin/perl -w


####################Aritmethic functions:###############################
#Log base two
sub log2 {
	$number = $_[0];
	return log($number)/log(2);
}

sub open_default_browser {
	my $url = shift;
	my $platform = $^O;
	my $cmd;
	if    ($platform eq 'darwin')  { $cmd = "open \"$url\"";          } # Mac OS X
	elsif ($platform eq 'linux')   { $cmd = "x-www-browser \"$url\""; } # Linux
	elsif ($platform eq 'MSWin32') { $cmd = "start $url";             } # Win95..Win7
	if (defined $cmd) {
		system($cmd);
	} else {
		die "Can't locate default browser";
	}
}

1;
