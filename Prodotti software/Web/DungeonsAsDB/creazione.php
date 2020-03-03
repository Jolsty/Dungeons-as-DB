<?php
session_start();
require 'connessione.php';


$_SESSION['logged_in'] = true; //set you've logged in
$_SESSION['last_activity'] = time(); //your last activity was now, having logged in.
$_SESSION['expire_time'] = 60*60; //expire time in seconds: 1 hour


if (isset($_SESSION['nomeUtente'])) {

    $nomeUtente = $_SESSION['nomeUtente'];

} else {

    header("Location: login.php");
}

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

        tr:nth-child(even) {
            background-color: #dddddd;
        }

        tr:hover {
            background-color: #ddd;
        }

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

<h1>Creazione del personaggio</h1>

<?php

if (isset($_SESSION['nomeUtente'])) {

    $nomeUtente = $_SESSION['nomeUtente'];
    echo "<div><b><big>Buongiorno, $nomeUtente </big></b></div>";

} else {

    header("Location: login.php");
}


if (isset($_POST['torna'])) {

    if (isset($_SESSION['nomepg'])) {

        $nomepg = $_SESSION['nomepg'];
        $query = "SELECT * FROM fineGame('$nomepg');";
        $result = pg_query($db, $query);

    }

    unset($_SESSION['nomepg']);
    unset($_POST['torna']);
}

if (isset($_SESSION['nomepg'])) {

    $nomepg = $_SESSION['nomepg'];

    echo "<div><b><big>Personaggio: $nomepg </big></b></div>";
}


if (isset($_SESSION["arrayDadi"])) {

    $arrayDadi = $_SESSION["arrayDadi"];

    ?>
    <table>
        <tr>
            <th><b>Tiro</b></th>
            <th><b>Valore</b></th>
            <th><b></b></th>
        </tr>

        <form action="gestionePG.php" method='POST' id="scarta">
            <?php $value = 0;
            foreach ($arrayDadi as $row) : ?>
                <tr>
                    <td><?php echo $row['tiro']; ?></td>
                    <td><?php echo $row['valore']; ?></td>
                    <td><?php echo "<input type='radio' name='dascartare' value=$value checked>"; ?> </td>

                </tr>
                <?php $value++; endforeach; ?>

            <input type="submit" name="scartare" value="Scarta il valore">
        </form>
    </table>


<?php } else {

    if (isset($_SESSION['nomepg'])) {

        unset($_SESSION['nomepg']);
        header("Location: creazione.php");
    }
    ?><br>
    <form action='gestionePG.php' method='POST' id="userform">
        <div><b><big>Inserisci i dati</big><br>
        (anche se hai già creato il PG in precedenza)</b></div>


        <input type="text" name="nomepg" placeholder="Nome del personaggio">
    </form>

    <textarea rows="5" cols="50" name="comment" form="userform" placeholder="Descrizione...(opzionale)"></textarea>
    <br>
    <input type="submit" name="dado" value="Roll the dices" form="userform">

<?php } ?>


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
