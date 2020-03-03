<?php
session_start();
require 'connessione.php';
$nomepg = $_SESSION['nomepg'];


if (isset($_POST['prendi'])) { // PULSANTE PRENDI

    $pos = $_POST['prendi'];
    $posInt = intval(preg_replace('/[^0-9]+/', '', $pos), 10) - 1; // prendo solo i numeri dalla stringa
    unset($_POST['prendi']);
    unset($pos);

    if (isset($_SESSION['elencoOggetti'])) {

        $elencoOggetti = $_SESSION['elencoOggetti'];
        unset($_SESSION['elencoOggetti']);

        $oggetto = $elencoOggetti[$posInt];
        $nomeogg = $oggetto['nome_ogg'];
        $query = "SELECT prendiOggetto('$nomepg', '$nomeogg')";
        $result = pg_query($db, $query);
        unset($oggetto);
        unset($nomeogg);

        if ($result) {

            $_SESSION['preso'] = true;
            header("Location: gestioneGAME.php");

        } else {

            echo '<script type="text/javascript">alert("Non puoi possedere più oggetti.")</script>';
            header("refresh:0.1; url=gestioneGAME.php");
        }

    }
}

if (isset($_POST['equip'])) { // PULSANTE EQUIPAGGIA

    $pos = $_POST['equip'];
    $posInt = intval(preg_replace('/[^0-9]+/', '', $pos), 10) - 1; // prendo solo i numeri dalla stringa
    unset($_POST['equip']);
    unset($pos);


    if (isset($_SESSION['elencoInventario'])) {

        $elencoInventario = $_SESSION['elencoInventario'];
        unset($_SESSION['elencoInventario']);
        $oggetto = $elencoInventario[$posInt];
        $nomeogg = $oggetto['oggetto'];
        $query = "INSERT INTO Equipaggia VALUES ('$nomepg', '$nomeogg');";
        $result = pg_query($db, $query);
        unset($oggetto);
        unset($nomeogg);

        if ($result) {

            header("Location: gestioneGAME.php");

        } else {

            echo '<script type="text/javascript">alert("Massimo 1 arma, 1 armatura, 2 gioielli. Devi prima togliere altri oggetti dal equipaggiamento.")</script>';
            header("refresh:0.1; url=gestioneGAME.php");

        }
    }
}


if (isset($_POST['cancel'])) { // PULSANTE ELIMINA

    $pos = $_POST['cancel'];
    $posInt = intval(preg_replace('/[^0-9]+/', '', $pos), 10) - 1; // prendo solo i numeri dalla stringa
    unset($_POST['cancel']);
    unset($pos);

    if (isset($_SESSION['elencoInventario'])) {

        $elencoInventario = $_SESSION['elencoInventario'];
        unset($_SESSION['elencoInventario']);

        $oggetto = $elencoInventario[$posInt];
        $nomeogg = $oggetto['oggetto'];

        $query = "DELETE FROM Possiede WHERE personaggio = '$nomepg' AND oggetto = '$nomeogg';";
        $result = pg_query($db, $query);
        unset($oggetto);
        unset($nomeogg);

        if ($result) {

            header("Location: gestioneGAME.php");

        } else {

            echo '<script type="text/javascript">alert("Non puoi eliminare l\'ultima arma che possiedi!")</script>';
            header("refresh:0.1; url=gestioneGAME.php");

        }
    }
}


if (isset($_POST['unequip'])) { // PULSANTE DISEQUIPAGGIA

    $pos = $_POST['unequip'];
    $posInt = intval(preg_replace('/[^0-9]+/', '', $pos), 10) - 1; // prendo solo i numeri dalla stringa
    unset($_POST['unequip']);
    unset($pos);

    if (isset($_SESSION['elencoEquipaggio'])) {

        $elencoEquipaggio = $_SESSION['elencoEquipaggio'];
        unset($_SESSION['elencoEquipaggio']);

        $oggetto = $elencoEquipaggio[$posInt];
        $nomeogg = $oggetto['oggetto'];

        $query = "DELETE FROM Equipaggia WHERE personaggio = '$nomepg' AND oggetto = '$nomeogg';";
        $result = pg_query($db, $query);
        unset($oggetto);
        unset($nomeogg);

        if ($result) {

            header("Location: gestioneGAME.php");

        } else {

            echo '<script type="text/javascript">alert("Errore nel disequipaggiamento.")</script>';
            header("refresh:0.1; url=gestioneGAME.php");

        }
    }
}
?>
