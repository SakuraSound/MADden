#!/usr/local/bin/php
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<title>MADden: In-Database Text Analytics</title>
		<link rel="stylesheet" type="text/css" href="bootstrap-1.4.0.min.css" />
		<link href="prettify/prettify.css" type="text/css" rel="stylesheet" />
		<link href="jquery.ui.all.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="prettify/prettify.js"></script>
		<script type="text/javascript" src="jquery.min.js"></script>
		<script type="text/javascript" src="jquery.ui.core.js"></script>
		<script type="text/javascript" src="jquery.ui.widget.js"></script>
		<script type="text/javascript" src="jquery.ui.datepicker.js"></script>


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
			$(function() {
					var dates = $( "#from1, #to1" ).datepicker({
						defaultDate: "+1w",
						changeMonth: true,
						numberOfMonths: 3,
						onSelect: function( selectedDate ) {
							var option = this.id == "from1" ? "minDate" : "maxDate",
								instance = $( this ).data( "datepicker" ),
								date = $.datepicker.parseDate(
									instance.settings.dateFormat ||
									$.datepicker._defaults.dateFormat,
									selectedDate, instance.settings );
							dates.not( this ).datepicker( "option", option, date );
						}
					});
				});
		</script>
	</head>

	<body  onload="prettyPrint()">

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
	
			<div class="hero-unit">
				<h1>MADden: In-Database Text Analytics</h1>
			</div> <!-- .hero-unit -->

			<div class="row">
				<div class="span3">
					&nbsp;
				</div> <!-- .span3 -->
				<div class="span10">
					
					<!-- query 1 -->
					<form action="query1.php" method="GET">
						Give me 
						<input name="num" type="range" min="1" max="20" value="5" step="1"
						onchange="slider('1range',this.value)"/>
						<span id="1range">5</span>
						<select name="sent" type="normalSelect" class="mini">
							<option>+</option>
							<option>o</option>
							<option>-</option>
						</select>
						comments about
						<input name="player" class="medium" type="text" value="Revis" /> 
						<input name="q" type="submit" class="primary btn" value="Query 1"/>
					<div class="input">
					</div> <!-- .input -->
					</form> <!-- form -->

					<hr/>

					<!-- query 2 -->
					<form action="query2.php" method="GET">
						Compare players 
						<input type="text" name="player1" class="small"/>
						and 
						<input type="text" name="player1" class="small"/> 
						by the number of 
						<select name="sent" type="normalSelect" class="mini">
							<option>+</option>
							<option>o</option>
							<option>-</option>
						</select>
						stories from 
						<input type="text" id="from1" name="from1" class="mini"/>
						to
						<input type="text" id="to1" name="to1" class="mini"/>
						<input name="q" type="submit" class="primary btn" value="Query 2"/>
					</form>

				</div> <!-- .span10 -->
				<div class="span3">
					&nbsp;	
				</div> <!-- .span3 -->
			</div> <!-- .row -->

		</div> <!-- .container -->

	</body>


</html>
