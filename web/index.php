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
						defaultDate: "-3m",
						changeMonth: true,
						numberOfMonths: 2,
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
						sentiment comments about
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
						<input type="text" name="player2" class="small"/> 
						by the twitter sentiment over dates from  
						<input type="text" id="from1" name="from1" class="mini"/>
						to
						<input type="text" id="to1" name="to1" class="mini"/>
						and return
						<input name="num" type="range" min="1" max="100" value="5" step="1"
						onchange="slider('2range',this.value)"/>
						<span id="2range">20</span> 
						results.
						<input name="q" type="submit" class="primary btn" value="Query 2"/>
						<br/>
					</form>

					<hr/>

					<!-- query 3 -->
					<form action="query3.php" method="GET">
						Give me the
						<select name="sent" type="normalSelect" class="mini">
							<option>+</option>
							<option>o</option>
							<option>-</option>
						</select>	
						sentiment for the  
					top 
						<input name="num" type="range" min="1" max="20" value="5" step="1"
						onchange="slider('3range',this.value)"/>
						<span id="3range">5</span>
						<select name="sent" type="normalSelect" class="mini">
							<option value="rb">running backs</option>
							<option value="qb">quarter backs</option>
							<option value="wr">wide reciever</option>
						</select>
						for tweets.<br/> 
						<input name="q" type="submit" class="primary btn" value="Query 3"/>
					</form>

					<hr/>
					<!-- query 4 -->
					<form action="query4.php" method="GET">
						Return all the named entity tags from the text<br/> 
						<textarea class="xxlarge" id="textarea4" name="comments" rows=3>
Kirn began his career in psychology, graduating from UF with a master’s degree in clinical psychology in 1971 and a doctorate in the same subject in 1974. While at UF, he met his wife, Katrine, who also earned her doctorate in clinical psychology at UF. He worked in the mental health field for six years, first as an intern and later at community mental health centers and in a private practice in Kentucky that he owned with his wife. He also was a full-time faculty member at Bellarmine University in Louisville for six years
						</textarea>
						<input name="q" type="submit" class="primary btn" value="Query 4"/>
					</form>

					<hr/>
				</div> <!-- .span10 -->
				<div class="span3">
					&nbsp;	
				</div> <!-- .span3 -->
			</div> <!-- .row -->

		</div> <!-- .container -->

	</body>


</html>
