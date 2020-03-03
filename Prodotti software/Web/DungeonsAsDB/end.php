<?php
session_start();
require 'connessione.php';

if (isset($_POST['rinuncia'])) {

    $_SESSION['perso'] = true;

}


if (isset($_SESSION['nomepg'])) {

    $nomepg = $_SESSION['nomepg'];

    if( $_SESSION['last_activity'] < time()-$_SESSION['expire_time'] ) { //have we expired?

        $query = "SELECT * FROM fineGame('$nomepg');";
        $result = pg_query($db, $result);
        header('Location: login.php');
    } else{ //if we haven't expired:
        $_SESSION['last_activity'] = time();
    }

    if (isset($_SESSION['vinto'])) {

        $vinto = $_SESSION['vinto'];
        if ($vinto == true) {

            // esperienza totale

            $query = "SELECT * FROM calcolaPE('$nomepg');";
            $result = pg_query($db, $query);

            $_SESSION['esperienza'] = pg_fetch_result($result, 0, 'calcolape');

            // dati relativi all'esperienza ricevuta

            $query = "SELECT * FROM informazioniGioco WHERE Personaggio = '$nomepg';";
            $result = pg_query($db, $query);
            $_SESSION['visited'] = pg_fetch_result($result, 0, 'visited');
            $_SESSION['defeated'] = pg_fetch_result($result, 0, 'defeated');
            $_SESSION['esperienzaDefeated'] = pg_fetch_result($result, 0, 'danno_n_defeated');

            // fa questa cosa soltanto una volta (se il personaggio vince)

            $vinto = false;
        }
    }


    $query = "SELECT * FROM fineGame('$nomepg');";
    $result = pg_query($db, $query);
    unset($_SESSION['nomepg']);

}


// CLEANUP DELLA SESSIONE

function logout()
{

    if (isset($_SESSION)) {

        unset($_SESSION);
        session_destroy();
    }

    header("Location: login.php");
}

// LOGOUT

if (isset($_POST['logout'])) {

    unset($_POST['logout']);
    logout();

}

// PLAY AGAIN

if (isset($_POST['riprova'])) {

    unset($_POST['riprova']);
    unset($_SESSION['nomepg']);
    unset($_SESSION['perso']);
    unset($_SESSION['vinto']);
    unset($_SESSION['esperienza']);
    unset($_SESSION['visited']);
    unset($_SESSION['defeated']);
    unset($_SESSION['esperienzaDefeated']);
    header("Location: creazione.php");
}

?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dungeons as DB</title>

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
            width: 32.5%;
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
            width: 34%;
        }

        address {

            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            text-align: center;
            width: 34%;
            font-size: large

        }

    </style>


    <link rel="icon" type="img/ico" href="img/favicon.ico"/>

</head>
<body>

<?php

if (isset($_SESSION['nomeUtente'])) { ?>

    <?php $nomeUtente = $_SESSION['nomeUtente']; ?>

    <h1>Fine del gioco</h1><br>

    <?php if (isset($_SESSION['perso'])) {

        echo "<div><big><b>Sfortunatamente hai perso, $nomeUtente</b></big></div>";
    }

    if (isset($_SESSION['vinto'])) {

        echo "<div><big><b>Congratulazioni, $nomeUtente. Hai vinto!</b></big></div>";

        if (isset($_SESSION['esperienza']) && isset($_SESSION['visited']) && isset($_SESSION['defeated']) && isset($_SESSION['esperienzaDefeated'])) {

            $esperienzaTotale = $_SESSION['esperienza'];
            $visited = $_SESSION['visited'];
            $esperienzaVisited = $visited * 10;
            $defeated = $_SESSION['defeated'];
            $esperienzaDefeated = $_SESSION['esperienzaDefeated'];

            echo "<div><big><b>Hai visitato $visited stanze &#10154; $esperienzaVisited punti di esperienza!</b></big></div>";
            echo "<div><big><b>Hai sconfitto $defeated nemici &#10154; $esperienzaDefeated punti di esperienza!</b></big></div>";
            echo "<div><big><b>Il tuo personaggio ha complessivamente guadagnato $esperienzaTotale punti di esperienza!</b></big></div>";

        }

    } ?>

    <form action='end.php' method='POST'>
        <input type="submit" name="riprova" value="Play again">
        <input type="submit" name="logout" value="Logout">
    </form>


<?php } else {

    header("Location: index.php");


} ?>


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
