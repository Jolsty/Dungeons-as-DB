<?php
session_start();
require 'connessione.php';
unset($_SESSION['nomepg']);

?>

<!DOCTYPE HTML>


<html>

<head>
    <title>Dungeons as DB</title>
    <link rel="icon" type="img/ico" href="img/favicon.ico"/>

    <style>
        input[type=text], input[type=password], textarea, select {
            width: 17%;
            padding: 12px 20px;
            margin: 8px 0;
            display: inline-block;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        input[type=submit] {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            width: 17%;
            background-color: #4CAF50;
            color: white;
            padding: 14px 20px;
            margin: 8px 0;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: large;
        }

        input[type=submit]:hover {
            background-color: #45a049;
        }

        div {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            border-radius: 5px;
            background-color: #f2f2f2;
            padding: 15px;
            width: 15.5%;
            text-align: center;
        }

        table {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            border-collapse: collapse;
            width: 17%;

        }

        td, th {
            border: 1px solid #ddd;
            text-align: center;
            padding: 8px;
            font-size: large;
        }

        tr:nth-child(even) {  background-color: #dddddd;  }

        tr:hover {background-color: #ddd;}

        th {

            background-color: #4CAF50;
            color: white;
            font-size: larger;
            padding-top: 12px;
            padding-bottom: 12px;
            font-weight: bold;

        }

        h1 {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            text-align: center;
            text-transform: uppercase;
            color: orangered;
            width: 17%;
        }
        address {

            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            text-align: center;
            width: 17%;
            font-size: large

        }

    </style>
</head>

<body bgcolor="white">

<h1>Login</h1>

<form action='login.php' method='POST'>
    <div><b><big>Inserisci i credenziali</big></b></div>
    <br>
    <input type="text" name="nome" placeholder="Nome utente"><br>
    <input type="password" name="password" placeholder="Password"><br>
    <input type="submit" name="submit" value="Login"><br>
</form>

<form action='index.php' method='POST'>
    <input type="submit" name="torna" value="Crea un account">
</form>


<?php

if ((array_key_exists('password', $_POST)) && (array_key_exists('nome', $_POST))) {

    $password = md5(($_POST['password']));
    $name = strtolower($_POST['nome']);


    $query = "SELECT * FROM Utente WHERE nome_utente='$name' AND password='$password'";
    $result = pg_query($db, $query);
    $rows = pg_num_rows($result);

    if (!$result) {

        echo '<script type="text/javascript">alert("Query non riuscita. Riprova.");</script>';


    } else {

        if ($rows > 0) {

            echo "Credenziali giusti. Carico la pagina per la creazione.";
            $_SESSION['nomeUtente'] = $_POST['nome'];
            header("Location:creazione.php");

        } else {

            echo '<script type="text/javascript">alert("Credenziali sbagliati. Riprova.");</script>';

        }

    }

}

?>

<br>
<hr>
<br>

<address>
    Andrei Ciulpan<br>
    Progetto di Basi di Dati<br>
    2016-2017<br>
</address>
</body>

</html>


