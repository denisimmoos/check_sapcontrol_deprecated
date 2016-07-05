package SAPControl::ABAPGetWPTable;

#===============================================================================
#
#         FILE: ABAPGetWPTable.pm
#      PACKAGE: SAPControl::ABAPGetWPTable
#
#  DESCRIPTION: The SAPControl::ABAPGetWPTable module
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
# ORGANIZATION: Sopra Steria Switzerland
#      VERSION: 1.0
#      CREATED: 11/20/2015 03:25:01 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

sub new
{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
} 


sub error {
	my $caller = shift;
	my $msg = shift || $caller;
	die( "ERROR($caller): $msg" );
}

sub verbose {
	my $caller = shift;
	my $msg = shift || $caller;
	print( "INFO($caller): $msg" . "\n" );
}

sub sapcontrol {

	my $self = shift;
	my $ref_Options = shift;
	my %Options = %{ $ref_Options };
	my $caller = (caller(0))[3];
	my $linecount = 0;
	my $hash_nr;
	my $hash_key;
	my $hash_value;
    my @sapcontrol;
    my %sapcontrol;

	open(SAPCONTROL,"$Options{'sapcontrolcmd'} -host $Options{'hostname'} -user $Options{'username'} $Options{'password'} -nr $Options{'nr'} -function $Options{'function'} -format $Options{'format'} |") or &error($caller,'open(SAPCONTROL)');

	while ( my $line = <SAPCONTROL> ) {

		++$linecount;
		chomp($line);


		&verbose($caller,'$line[' . $linecount . ']: ' . $line ) if ( $Options{'v'} or $Options{'verbose'} );

		# conditions
		if (!defined $line){ next; };

		# error
		if ( $linecount == 4 ) {
			if ( $line !~ /^OK/) {
				&error($caller,$line);
			}
		}

		if ($line !~ /^[0-9]+\ / ){ next; };

		# get the record set number
		$hash_nr = ( split(/\ /,$line))[0];

		# cut leeding and ending whitespaces
		$hash_nr =~ s/^\s+|\s+$//g;


		# split it to an array
		@sapcontrol = ( split(/^[0-9]+\ /,$line));

		# split key value pairs
		@sapcontrol = ( split(/\:/,$sapcontrol[1]) );

		# clean \n
		chomp(@sapcontrol);

		# cut leeding and ending whitespaces
		$hash_key = $sapcontrol[0];
		$hash_key =~ s/^\s+|\s+$//g;

		# cut leeding and ending whitespaces
		$hash_value = $sapcontrol[1];
		$hash_value =~ s/^\s+|\s+$//g;

		# alles in klein 
		$hash_key =~ tr/A-Z/a-z/;

	    $sapcontrol{$hash_nr}{$hash_key} = $hash_value;
	}

#	close(SAPCONTROL) or &error($caller,'close(SAPCONTROL)');

	return %sapcontrol;

}

sub match {

	my $self = shift;
	my $ref_Options = shift;
	my $ref_SAPControl = shift;
	my %Options = %{ $ref_Options };
	my %SAPControl = %{ $ref_SAPControl };
	my $caller = (caller(0))[3];
	my $hash_nr;
	my $hash_key;
	my $hash_value;
	my @hash_nr =();
	my @hash_nr_all =();
	my @hash_nr_total =();
	my $hash_count =();
	my %SAPControlMatch;

	foreach $hash_nr (keys(%SAPControl)) {

		 push(@hash_nr_total,$hash_nr);

		# 
		# suchen nach match 
		#
		if (defined($Options{'typ'})) {

		  if (defined($Options{'status'}) and $Options{'typ'} eq $SAPControl{$hash_nr}{'typ'}) {
			push(@hash_nr,$hash_nr) if ( $Options{'status'} eq $SAPControl{$hash_nr}{'status'} );
		    push(@hash_nr_all,$hash_nr);
		  }

	    } else {
			# ohne type alles zählen
			push(@hash_nr,$hash_nr) if ( $Options{'status'} eq $SAPControl{$hash_nr}{'status'} );
		}
	}

	# uniq
	@hash_nr = keys { map { $_ => 1 } @hash_nr };
	@hash_nr_total = keys { map { $_ => 1 } @hash_nr_total };

	$SAPControlMatch{'hash_count'} = scalar(@hash_nr);
	$SAPControlMatch{'hash_count_total'} = scalar(@hash_nr_total);

	if (defined($Options{'typ'})) {
	    @hash_nr_all = keys { map { $_ => 1 } @hash_nr_all };
		$SAPControlMatch{'hash_count_all'} = scalar(@hash_nr_all);
		$SAPControlMatch{'hash_count_percent'} = ($SAPControlMatch{'hash_count'} * 100)/ $SAPControlMatch{'hash_count_all'};
	}

	return %SAPControlMatch;

}


sub out_nagios {

	my $self = shift;
	my $ref_Options = shift;
	my $ref_SAPControl = shift;
	my %Options = %{ $ref_Options };
	my %SAPControl = %{ $ref_SAPControl };
	my $caller = (caller(0))[3];
	my $hash_nr;
	my $hash_key;
	my $count = 0;
	my $count_all = 0;
	my $count_total = 0;
	my $count_percent = 0;
	my $status; 
	my $msg; 
    

	my %NagiosStatus = (
		GREEN    => 'OK',
		RED      => 'CRITICAL',
		GRAY     => 'UNKNOWN',
		YELLOW   => 'WARNING',
        
		OK       => 0,
		WARNING  => 1,
		CRITICAL => 2,
		UNKNOWN  => 3,
	);

	# default
    $status = $NagiosStatus{'OK'};
    $msg = 'OK';

	$count = $SAPControl{'hash_count'};
	$count_all = $SAPControl{'hash_count_all'};
	$count_total = $SAPControl{'hash_count_total'};
	$count_percent = $SAPControl{'hash_count_percent'};



	# reverse the logic 
	# 
	# CRITICAL if no more "Wait" statuses available
	#
	# ./check_sapcontrol.pl -H 10.122.4.75 --authfile /etc/icinga2/auth/hostname.auth  -F ABAPGetWPTable  --status Wait  --critical NULL --reverse --typ DIA
	#
	# Note the --reverse option.
	#
	# CRITICAL if one status "Ended"
	# ./check_sapcontrol.pl -H 10.122.4.75 --authfile /etc/icinga2/auth/hostname.auth  -F ABAPGetWPTable  --status Ended  --critical 1 
	# 
	if ($Options{'reverse'}) {
	
		if ($Options{'warning'} ) {
			if ($count <= $Options{'warning'} ) {
				$status = $NagiosStatus{'WARNING'};
				$msg = 'WARNING';
			} 
		}

		if ( $Options{'critical'} ne 'NULL' ) {
			if ($count <= $Options{'critical'} ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			}
		} else {
			if ($count <= 0 ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			
			}
		}
	
	} elsif ( defined($Options{'percent'}) ) {

		if ( $Options{'warning'} ) {
			if ($count_percent >= $Options{'warning'} ) {
				$status = $NagiosStatus{'WARNING'};
				$msg = 'WARNING';
			} 
		}

		if ($count_percent >= $Options{'critical'} ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
		}

	} else { 

		if ($Options{'warning'} ) {
			if ($count <= $Options{'warning'} ) {
				$status = $NagiosStatus{'WARNING'};
				$msg = 'WARNING';
			} 
		}

		if ( $Options{'critical'} ne 'NULL' ) {
			if ($count >= $Options{'critical'} ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			}
		} else {
			if ($count >= 0 ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			
			}
		}
	
	
	}	
	



	# ;) 
	if( not $Options{'warning'} ){ $Options{'warning'}='-'; }

	if ($Options{'typ'}) {
	  
	  # formating 
	  if ($Options{'percent'}) {
	      $count_percent=$count_percent . '%' . ';' . $Options{'warning'} .  ';' . $Options{'critical'} . ';0;100';
	  } else {
		  $count_percent=$count_percent . '%';
	  }
	  
	  print "$msg - $Options{'typ'}($Options{'status'})[$count/$count_all][$count_percent%][W:$Options{'warning'}][C:$Options{'critical'}] | count=$count percent=$count_percent" . "\n";
	} else {
	  print "$msg - ($Options{'status'})[$count/$count_total][W:$Options{'warning'}][C:$Options{'critical'}] | count=$count" . "\n";
	}

	# return 0,1,2,3
	$status = $NagiosStatus{$status};
	exit $status;

}


1;
__END__

=head1 NAME

SAPControl::ABAPGetWPTable - SAPControl::ABAPGetWPTable module

=head1 SYNOPSIS

use SAPControl::ABAPGetWPTable;

my $object = SAPControl::ABAPGetWPTable->new();

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

=cut


