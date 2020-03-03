<?php
session_start();
require 'connessione.php';
$nomepg = $_SESSION['nomepg'];
$arma = $_SESSION['arma'];
unset($_SESSION['arma']);

// PRENDO IL DANNO DELL'ARMA DEL PERSONAGGIO

$query = "SELECT danno_inflitto FROM Oggetto WHERE nome_ogg = '$arma';";
$result = pg_query($db, $query);
$dannoPG = pg_fetch_result($result, 0, 'danno_inflitto');


if (isset($_POST['attacca'])) { // PULSANTE ATTACCA


    $pos = $_POST['attacca'];
    $posInt = intval(preg_replace('/[^0-9]+/', '', $pos), 10) - 1; // prendo solo i numeri dalla stringa
    unset($_POST['attacca']);
    unset($pos);

    if (isset($_SESSION['elencoNemici'])) {

        $elencoNemici = $_SESSION['elencoNemici'];
        unset($_SESSION['elencoNemici']);

        $nemico = $elencoNemici[$posInt];
        $nomenem = $nemico['nome_n'];
        $dannonem = $nemico['danno_n'];

        // il personaggio sta equipaggiando un'arma? se la risposta è no allora manda un alert dicendogli di equipaggiare un arma

        $query = "SELECT Arma_eq FROM Personaggio WHERE Nome_pg = '$nomepg'";
        $result = pg_query($db, $query);

        if ($result) {

            $arma = pg_fetch_result($result, 0, 'arma_eq');

            if (!$arma) {

                echo '<script type="text/javascript">alert("Devi equipaggiare un\'arma per poter attaccare.")</script>';
                header("refresh:0.1; url=gestioneGAME.php");

            } else {


                $query = "SELECT * FROM attacca('$nomepg', '$nomenem')";
                $result = pg_query($db, $query);


                if ($result) {

                    $riuscito = pg_fetch_result($result, 0, 'attacca');


                    switch ($riuscito) {

                        case 1:
                            echo '<script type="text/javascript">alert("Solo il tuo attacco è riuscito. Hai tolto ' . $dannoPG . ' punti ferita da ' . $nomenem . '." )</script>';
                            header("refresh:0.1; url=gestioneGAME.php");
                            break;
                        case 2:
                            echo '<script type="text/javascript">alert("Il tuo attacco non è riuscito. Inoltre sei stato attaccato da ' . $nomenem . ' e hai perso ' . $dannonem . ' punti ferita.")</script>';
                            header("refresh:0.1; url=gestioneGAME.php");
                            break;
                        case 3:
                            echo '<script type="text/javascript">alert("Hai tolto ' . $dannoPG . ' punti ferita da ' . $nomenem . '. Inoltre sei stato attaccato da ' . $nomenem . ' e hai perso ' . $dannonem . ' punti ferita.")</script>';
                            header("refresh:0.1; url=gestioneGAME.php");
                            break;
                        default:
                            echo '<script type="text/javascript">alert("Nessun attacco è riuscito.")</script>';
                            header("refresh:0.1; url=gestioneGAME.php");

                    }
                }
            }
        }
    }
}

?>



