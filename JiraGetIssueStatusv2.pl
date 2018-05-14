#!/bin/env perl
use strict;
use warnings;

use JIRA::REST;
#use JIRA::Client::Automated;
use Getopt::Long;
use FindBin qw($Bin);
use Data::Dumper;

my $DEBUG=0;


BEGIN {
     push @INC, "C:/Perl64/site/lib"; # for windows compile only
};

open(DATA," > perl_file".getLoggingTime().".csv") || die "Couldn't open file file.txt, $!";

my $jira;
$jira->{jiraserver} = 'ilptlppjir01';
$jira->{jiraport} = '8080';
$jira->{jirauser} = 'cm';
$jira->{jirapass} = 'cm';


my $jira_url ="http://$jira->{jiraserver}\:$jira->{jiraport}";
my $jirareq = JIRA::REST->new("$jira_url","$jira->{jirauser}","$jira->{jirapass}");

print "Started > ";
print  DATA "From, To, reported, resolved , difference";

my $count;
for ($count = 20 ; $count >= 1 ; $count--) {
	
	my $previous = "-".$count;
	my $current = $count-1;
	
	if($current==0) {
		$current = "";
	}else{
		$current = "-".$current;
	}
	
	my $issueCreatedLastWeek = "project = SwiftEmb AND createdDate >= startOfWeek($previous) AND createdDate <= startOfWeek($current) AND issuetype in (PR, CR, \"Sub PR\", \"Sub CR\", Sub-Task)";
	my $dataCreated = getData($issueCreatedLastWeek, $jirareq);
	
	my $issueResolvedLastWeek = "project = SwiftEmb AND status changed to validating before startOfWeek($current)  AND status changed to validating after startOfWeek($previous)";
	my $dataResolved = getData($issueResolvedLastWeek, $jirareq);
	
	if ($@) {
		print STDERR "***ERROR***. Please check the values in command line are correct\n";
		exit 255;
	}

	my $createdData = $dataCreated ->{total};
	my $resolvedData = $dataResolved ->{total};
	my $diff = $createdData - $resolvedData;

	print  DATA $previous.", ".$current." , ".$createdData.", ".$resolvedData.", ".$diff." \n";
	print ".";	
}

sub getData {

	my ($query, $jirareq) = @_;
 
 	my $search;
	eval { $search = $jirareq->POST('/search', undef, {
		jql        => "$query",
		startAt    => 0,
		maxResults => 2000,
		fields     => [ qw/total /] #summary status assignee creator fixVersions issuetype/ ],
		})
	};
	
	return $search;
 
 }

 close DATA;
 
 sub getLoggingTime {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $nice_timestamp = sprintf ( "%04d%02d%02d_%02d_%02d_%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
	print $nice_timestamp;
    return $nice_timestamp;
}

#foreach my $issue (@{$search->{issues}}) {
#    my $key = $issue->{key};
#   my $status = $issue->{fields}{status}{name};
#	my $assignee = $issue->{fields}{assignee}{name};
#	my $creator = $issue->{fields}{creator}{name};
#   my $fixversion = $issue->{fields}{fixVersions}[0]{name};
#	my $Summary = $issue-> {fields}{summary};
#	my $Type = $issue-> {fields}{issuetype}{name};
#	print "Key: [$key]  Status: [$status]  FixVersion: [$fixversion]  Summary: [$Summary] Type: [$Type]\n";
#}





