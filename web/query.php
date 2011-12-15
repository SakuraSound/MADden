#!/usr/local/bin/php
<?php

header('Content-type: application/json');

// Check to see if a query was passed in

$pstr = "";
foreach($_POST as $key => $value){
//	$pstr = $pstr." ".$key."=>".$value;
	error_log($key." ".$value, 3, 'query_beta.log');
}
error_log("\n\n");

//print_r($_POST);
//print json_encode($_POST);
//print json_encode($_GET);
//print json_encode($_REQUEST);

error_log($pstr."\n\n", 3, 'query_beta.log');

if(isset($_GET['q'])) {

	$dbconn = pg_connect("host=128.227.176.46 dbname=madlibdb user=john password=madden options='--client_encoding=UTF8'")
    or die('Could not connect: ' . pg_last_error());

	$query = urldecode($_GET['q']);

	$rows = array();

	list($tic_usec, $tic_sec) = explode(" ", microtime());
	$result = pg_query($query) or die('Query failed: ' . pg_last_error());
	list($toc_usec, $toc_sec) = explode(" ", microtime());
	$querytime = $toc_sec + $toc_usec - ($tic_sec + $tic_usec);
	while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
		$rows[] = $line;
	}

	$rows["q"] = urldecode($query);
	$rows["querytime"] = $querytime;
	$rows["rowcount"] = pg_num_rows($result);

	print json_encode($rows);

	// Free resultset
	pg_free_result($result);
	// Closing connection
	pg_close($dbconn);
}
else {
	header('HTTP/1.0 406 Not Acceptable');

//print json_encode($_REQUEST);
//print json_encode($_SERVER);
}



?>
