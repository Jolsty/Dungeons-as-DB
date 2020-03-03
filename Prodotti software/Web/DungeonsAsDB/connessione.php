<?php

	$db = pg_connect("host=localhost port=5432 dbname=postgres user=YOURUSER password=YOURPASSWORD")
		or die('Connessione al database non riuscita.' . pg_last_error());


	$schema = "SET search_path TO DungeonsAsDB, postgres";
	$schemaconn = pg_query($db, $schema);

	if (!$schemaconn) {

	    echo "SCHEMA NON TROVATO!";
    }


?>