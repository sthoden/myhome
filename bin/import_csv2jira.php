<?php

$user_name = "florian.schaper";
$user_password = "*****";
$jira_project = "STERNCC";
$version_number = 1; // choose a version id (shown after the first run).
$csv_file = "hotels_import.csv";

define( "TASK_REGULAR", 2 );
define( "TASK_CHILD", 5 );

// ---
$soap_url = "https://jira.hmmh.de/rpc/soap/jirasoapservice-v2?wsdl";


$soap = new SoapClient( $soap_url );
$token = $soap->login( $user_name, $user_password );

$versions = $soap->getVersions( $token, $jira_project );

// TODO disable me after choosing a version to import to
if( true ) {
	print_r($versions);
	die("plase choose a version to import into (e.g. sprint2)\n");
}

ini_set("auto_detect_line_endings", true);

$fh = fopen( $csv_file, "r");
while( ! feof($fh) ) {
	$csv_line = fgetcsv( $fh, 0,";" );

	// TODO 
	if( true ) {
		print_r($csv_line);
		die( "adjust your csv -> jira mapping based on your csv file\n");
	}

	// in case the group field is being used a parent task will be created - all following 'regular' tickets will be added as child tasks (until another group gets created)
	$group = $csv_line[0];
	// subject line of the ticket (greenhopper card name)
	$subject = $csv_line[1];
	// estimate (greenhopper time scheduling formatting: e.g. "1d 2m", "12h")
	$estimate = $csv_line[2];
	// body - ticket detail information
	$description = $csv_line[4];
	// Important: you have to pick a version contained in the "$versions" hash table, you have to modify the $version_number variable.
	$fixVersions = $versions[ $version_number ];

	$create_new_group_ticket = ! empty($group);

	// in case a group has been created ( $groupID is non-empty ) all following tickets (that don't have the group field set) will be added to the previously created parent ticket 
	if( $groupID && ! $create_new_group_ticket ) {
		$issue = $soap->createIssueWithParent( $token, 
			array("type" => TASK_CHILD,
				  "project" => $jira_project, 
				  "fixVersions" => array( "version_1" => $fixVersions ),
				  "subject" => $subject,
				  "description" => $description,
				  "summary" => $subject
				  ),
				(string)$groupID
			);
		$soap->updateIssue( $token, $issue->key, array( array("id" => "timetracking", "values" => array( $estimate ) ) ) );

	} else {
		$issue = $soap->createIssue( $token, 
			array("type" => TASK_REGULAR,
				  "project" => $jira_project, 
				  "fixVersions" => array( "version_1" => $fixVersions ),
				  "subject" => $create_new_group_ticket ? $group : $subject,
				  "description" => $description,
				  "summary" => $create_new_group_ticket ? $group : $subject
				  ) 
			);

		// in case the "group" variable is non-empty, no timetracking will be added (the ticket then sums up the estimates from all of it's sub-tasks)
		if( ! $create_new_group_ticket ) {
			$soap->updateIssue( $token, $issue->key, array( array("id" => "timetracking", "values" => array( $estimate ) ) ) );
		} else {
			$groupID = $issue->key;
		}
	}

?>