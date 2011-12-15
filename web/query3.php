#!/usr/local/bin/php
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<title>MADden: In-Database Text Analytics</title>
		<link rel="stylesheet" type="text/css" href="bootstrap-1.4.0.min.css" />
		<link href="prettify/prettify.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script language='javascript' src='http://embedtweet.com/javascripts/embed_v2.js'></script>
		<script type="text/javascript" src="prettify/prettify.js"></script>
		<!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]--><style type="text/css">
      body {
        padding-top: 20px;
      }
    </style>
		<script type="text/javascript">
			function slider(e,newValue) { 
				document.getElementById(e).innerHTML=newValue;
			}
			$(document).ready(function() { prettyPrint(); });
		</script>
		<style type="text/css">
      /* Override some defaults */
      html, body {
        background-color: #eee;
      }
      body {
        padding-top: 40px; /* 40px to make the container go all the way to the bottom of the topbar */
      }
      .container > footer p {
        text-align: center; /* center align it with the container */
      }
      .container {
        width: 820px; /* downsize our container to make the content feel a bit tighter and more cohesive. NOTE: this removes two full columns from the grid, meaning you only go to 14 columns and not 16. */
      }

      /* The white background content wrapper */
      .content {
        background-color: #fff;
        padding: 20px;
        margin: 0 -20px; /* negative indent the amount of the padding to maintain the grid system */
        -webkit-border-radius: 0 0 6px 6px;
           -moz-border-radius: 0 0 6px 6px;
                border-radius: 0 0 6px 6px;
        -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.15);
           -moz-box-shadow: 0 1px 2px rgba(0,0,0,.15);
                box-shadow: 0 1px 2px rgba(0,0,0,.15);
      }

      /* Page header tweaks */
      .page-header {
        background-color: #f5f5f5;
        padding: 20px 20px 10px;
        margin: -20px -20px 20px;
      }

      /* Styles you shouldn't keep as they are for displaying this base example only */
      .content .span10,
      .content .span4 {
        min-height: 500px;
      }
      /* Give a quick and non-cross-browser friendly divider */
      .content .span4 {
        margin-left: 0;
        padding-left: 19px;
        border-left: 1px solid #eee;
      }

      .topbar .btn {
        border: 0;
      }

    </style>
	</head>

	<body>

		<div class="topbar">
			<div class="fill">
				<div class="container">
					<!-- <a class="brand" href="#">MADden</a> -->
					<ul class="nav">
						<li class="active"><a href="#">Home</a></li>
						<li><a href="http://www.cise.ufl.edu/class/cis6930fa11lad/">cis6930fa11lad</a></li>
						<li><a href="https://github.com/SakuraSound/MADden">The Code</a></li>
					</ul><!-- .nav -->
				</div> <!-- .container -->
			</div> <!-- .fill -->
		</div> <!-- .topbar -->

		<div class="container">
<?php
//error_reporting(E_ALL);
//ini_set('display_errors', '1');

// Connecting, selecting database
$dbconn = pg_connect("host=128.227.176.46 dbname=madlibdb user=john password=madden options='--client_encoding=UTF8'")
    or die('Could not connect: ' . pg_last_error());

$num = $_GET['num'];
$player = implode("&", explode(" ", $_GET["player"]));
$sent = htmlspecialchars($_GET['sent']);
	// Build query

$playertable = "passingstats";
	if($_GET['pos']) {
		$playertable = "rushingstats";
	}
	else if($_GET['pos']) {
		$playertable = "recievingstats";
	}

$query = "select id, fname, lname, yards, tds, doc, sentiment from 
(select id, fname, lname, yards, tds, doc, cgrant_sentiment(doc) as sentiment
from 
(select rb.pid as id, rb.first as fname, rb.last as lname, n.twtext as doc, rb.total_yards as yards, rb.touchdowns as tds 
from tweets n, 
(select pid, first, last, total_yards, touchdowns, first || ' ' || last as tsv
from $playertable 
order by total_yards DESC, touchdowns DESC
LIMIT $num) as rb 
where cgrant_distance(1, rb.tsv, 2, n.twtext, 5) > .5) as docs) as sent 
where sentiment = '$sent'
limit $num;";

error_log($query."\n\n------------", 3, 'query.log');

		list($tic_usec, $tic_sec) = explode(" ", microtime());
		$result = pg_query($query) or die('Query failed: ' . pg_last_error());
		list($toc_usec, $toc_sec) = explode(" ", microtime());
		$querytime = $toc_sec + $toc_usec - ($tic_sec + $tic_usec);
?>	

			<div class="content">
        <div class="page-header">
				<h1>John Madden says <?php echo $_GET["q"];?>	
					<small>...</small>
				</h1>
        </div>
        <div class="row">
          <div class="span10">
            <h2>Answer</h2>
						<?php
							// Printing results in HTML
							echo "<table>\n";
							while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
									echo "\t<tr>\n";
									echo "<td>".$line['fname']."</td>";
									echo "<td>".$line['lname']."</td>";
									echo "<td>".$line['yards']." yards</td>";
									echo "<td>".$line['tds']." touchdowns</td>";
									echo "<td>".$line['doc']."</td>";
									echo "<td>".$line['sentiment']."</td>";
									echo "\t</tr>\n";
							}
							echo "</table>\n";
						?>
          </div>
          <div class="span4">
            <h3>The Query</h3>
						<?php
							//echo "<pre class=\"prettyprint\">"; 
							echo "<code class=\"prettyprint lang-sql\">--\n";
							echo $query;
							echo "</code>";
							//echo "</pre>";
							echo "<div class=\"alert-message info\">";
							echo "<p>".($querytime*100)." msec </p>";
							echo "</div> <!-- alert -->";
						?>
          </div>
        </div>
      </div>
			
			<footer>
				<p>&copy; University of Florida 2011</p>
			</footer>
<?php
// Free resultset
pg_free_result($result);

// Closing connection
pg_close($dbconn);
?>
		</div> <!-- .container -->
	</body>
</html>
