<?php
session_start();
require 'connessione.php';
?>

<!DOCTYPE HTML>


<html>

<head>
    <title>Dungeons as DB</title>
    <link rel="icon" type="img/ico" href="img/favicon.ico"/>
</head>

<body bgcolor="white">

<?php
if (isset($_SESSION['nomeUtente'])) {

    $nomeUtente = strtolower($_SESSION['nomeUtente']);
    $query = "SELECT Utente_ID FROM Utente WHERE Nome_utente='$nomeUtente';";
    $result = pg_query($db, $query);
    if ($result) {

        $_SESSION['IDUtente'] = pg_fetch_row($result); // PER Utente_ID DI PERSONAGGIO
    }
}

if (isset($_POST['dado']) && isset($_POST['nomepg'])) {

    if (!empty($_POST['nomepg'])) {

        unset($_POST['dado']);
        $nomepg = $_POST['nomepg'];
        unset($_POST['nomepg']);
        $_SESSION['nomepg'] = $nomepg; // NOME PG
        $_SESSION['comment'] = $_POST['comment']; // DESCRIZIONE(OPZIONALE)

        $query = "SELECT * FROM tredasei()";
        $result = pg_query($db, $query);

        if ($result) {

            $arrayDadi = pg_fetch_all($result);
            $_SESSION["arrayDadi"] = $arrayDadi; // RISULTATI DEI LANCI
            header("Location: creazione.php");
        }

    } else {

        echo '<script type="text/javascript">alert("Devi inserire il nome del personaggio");</script>';
        header('refresh:0.1; url=creazione.php');
    }
}

if (isset($_SESSION['arrayDadi']) && isset($_POST['scartare'])) {

    $arrayDadi = $_SESSION["arrayDadi"];
    $daScartare = $_POST["dascartare"];
    unset($_POST['scartare']);
    unset($_SESSION["arrayDadi"]);
    unset($arrayDadi[$daScartare]);
    $arrayDadi = array_values($arrayDadi); // reindex

    $tiro1 = $arrayDadi[0]['valore'];
    $tiro2 = $arrayDadi[1]['valore'];
    $tiro3 = $arrayDadi[2]['valore'];
    $tiro4 = $arrayDadi[3]['valore'];

    if (isset($_SESSION['nomepg']) && isset($_SESSION['IDUtente'])) {


        $nomepg = $_SESSION['nomepg'];
        unset($_SESSION['nomepg']);
        $IDUtente = $_SESSION['IDUtente'][0];

        $query = "SELECT nome_pg FROM Personaggio WHERE nome_pg = '$nomepg' and utente_id = '$IDUtente';";
        $resultPerDopo = pg_query($db, $query); // per vedere se era già stato creato (prima di usare la funzione creapg - che può fare o insert personaggio o update)

        $query = "SELECT * FROM creaPG('$IDUtente', '$nomepg', $tiro1, $tiro2, $tiro3, $tiro4);";
        $result = pg_query($db, $query);

        if ($result) {

            if (isset($_SESSION['comment'])) {

                $comment = $_SESSION['comment'];
                unset($_SESSION['comment']);

                if ($comment != "") {

                    $query = "UPDATE Personaggio SET descrizione_pg = '$comment' WHERE nome_pg='$nomepg';";
                    $result = pg_query($db, $query);

                }
            }

            if ($resultPerDopo) {

                $rows = pg_num_rows($resultPerDopo);

                if ($rows > 0) {

                    echo '<script type="text/javascript">alert("Il personaggio '.$nomepg.' è già stato creato precedentemente. Rinfresco le statistiche con i nuovi lanci dei dadi. Buona fortuna! ");</script>';
                    header("refresh:0.1; url=game.php?nomepg=" . $nomepg);

                } else {

                    echo '<script type="text/javascript">alert("Il personaggio '.$nomepg.' è stato creato correttamente.");</script>';
                    header("refresh:0.1; url=game.php?nomepg=" . $nomepg);
                }
            }

        } else {

            echo '<script type="text/javascript">alert("Errore nella creazione del personaggio. Riprova.");</script>';
            header("refresh:0.1; url=creazione.php");
        }
    }
} else {

    echo '<script type="text/javascript">alert("Devi scegliere un valore da scartare.");</script>';
    header("refresh:0.1; url=creazione.php");
}

?>

</body>
</html>




