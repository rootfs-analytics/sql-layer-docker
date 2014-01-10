<html>
<head>
<title>LEFP</title>
</head>

<body>

<h1>LE<del>M</del><ins>F</ins>P</h1>

<p>PHP + FoundationDB SQL Layer</p>

<p>Version: 
<?php
$host = $_SERVER['FDBSQL_PORT_15432_TCP_ADDR'];
$dbh = new PDO("pgsql:host=$host port=15432 dbname=test");
$stmt = $dbh->prepare('SELECT version()');
$stmt->execute();
$row = $stmt->fetch();
echo $row[0];
?>
</p>

<p><a href="phpinfo.php">PHP info</a></p>

</body>
</html>
