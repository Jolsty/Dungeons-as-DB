<?php
session_start();
require 'connessione.php';
$nomepg = $_SESSION['nomepg'];


if (isset($_POST['nascosto'])) { // PULSANTE TROVA OGGETTI/PASSAGGI NASCOSTI

    unset($_POST['nascosto']);

    $query = "SELECT * FROM cercaNascosti('$nomepg');";
    $result = pg_query($db, $query);

    if ($result) {


        $nascosto = pg_fetch_result($result, 0, 'cercanascosti');


        if ($nascosto) { // se ha trovato qualcosa

            if (is_numeric($nascosto)) {

                echo '<script type="text/javascript">alert("Hai trovato un passaggio segreto verso la stanza '.$nascosto.'.")</script>';
                header("refresh:0.1; url=gestioneGAME.php");

            } else {

                echo '<script type="text/javascript">alert("Hai trovato l\'oggetto nascosto '.$nascosto.'.")</script>';
                header("refresh:0.1; url=gestioneGAME.php");
            }
        } else {

            header("Location: gestioneGAME.php");

        }
    } else {

        echo '<script type="text/javascript">alert("Non hai abbastanza punti ferita per effettuare la ricerca (minimo 2).")</script>';
        header("refresh:0.1; url=gestioneGAME.php");

    }
}



?>