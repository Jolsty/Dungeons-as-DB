<?php
session_start();
require 'connessione.php';

if (!isset($_SESSION['nomepg'])) {

    header("Location: index.php");

}

$nomepg = $_SESSION['nomepg'];

if( $_SESSION['last_activity'] < time()-$_SESSION['expire_time'] ) { //have we expired?

    $query = "SELECT * FROM fineGame('$nomepg');";
    $result = pg_query($db, $query);
    header('Location: login.php'); //
} else{ //if we haven't expired:
    $_SESSION['last_activity'] = time();
}

// NR STANZA


$query = "SELECT getStanzaPG('$nomepg')";
$result = pg_query($db, $query);

if ($result) {

    $_SESSION['stanzaPG'] = pg_fetch_result($result, 0, 'getstanzapg');

}


// SE NON C'E' IL PG ALLORA NON SI PUO' PROSEGUIRE


// PUNTI FERITA

$query = "SELECT PF FROM Personaggio WHERE Nome_pg = '$nomepg';";
$result = pg_query($db, $query);

if ($result) {

    $_SESSION['PF'] = pg_fetch_result($result, 0, 'PF');
}


?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dungeons as DB</title>

    <style>


        table {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            text-align: center;
            padding: 8px;
            border: 1px solid #ddd;
            font-size: large;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2
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

        h2 {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            text-align: center;
            text-transform: uppercase;
            color: orangered;

        }

        div {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            border-radius: 5px;
            background-color: #f2f2f2;
            padding: 5px;
            width: 100%;
            text-align: center;
            height: 30px
        }

        body {
            color: #536482;
            background-color: white;
            zoom: 75%;

        }

        address {

            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            text-align: center;
            width: 100%;
            font-size: large
        }

        input[type=submit] {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            width: 50%;
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            margin: 2px 0;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: medium;
        }

        input[type=submit].submitOutOfTable {

            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            width: 10%;
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


    </style>

    <link rel="icon" type="img/ico" href="img/favicon.ico"/>

</head>
<body>

<?php


function generaStanza($stanzaPG, $nome, $dbconn)
{

    if ($stanzaPG == 1) {

        echo "<h2>Stanza iniziale</h2>";

    } else if ($stanzaPG == 15) {

        $_SESSION['vinto'] = true;
        echo '<script type="text/javascript">alert("Hai vinto!")</script>';
        header("refresh:0.1; end.php");

    } else {

        echo "<h2>Stanza $stanzaPG</h2>";

    }

    if (isset($_SESSION['datiPG'])) {

        $PF = $_SESSION['PF']; ?>

        <div><big><b><?php echo "$nome - $PF HP"; ?></b></big></div><br>
        <table>
            <tr>
                <th><b>Arma</b></th>
                <th><b>Armatura</b></th>
                <th><b>FOR</b></th>
                <th><b>INT</b></th>
                <th><b>AGI</b></th>
                <th><b>COST</b></th>
                <th><b>ATT</b></th>
                <th><b>DIF</b></th>
                <th><b>PER</b></th>
                <th><b>PE</b></th>
                <th><b>Capienza</b></th>
            </tr>

            <?php foreach ($_SESSION['datiPG'] as $row) : ?>
                <tr>
                    <td><?php echo $row['arma_eq']; ?></td>
                    <td><?php echo $row['armatura_eq']; ?></td>
                    <td><?php echo $row['FOR']; ?></td>
                    <td><?php echo $row['int']; ?></td>
                    <td><?php echo $row['agi']; ?></td>
                    <td><?php echo $row['cost']; ?></td>
                    <td><?php echo $row['att']; ?></td>
                    <td><?php echo $row['dif']; ?></td>
                    <td><?php echo $row['per']; ?></td>
                    <td><?php echo $row['pe']; ?></td>
                    <td><?php echo $row['capienza']; ?></td>
                </tr>   <?php
                $_SESSION['arma'] = $row['arma_eq']; // mi serve per la pagina gestioneNEM.php per prendere il danno dell'arma equipaggiata
            endforeach;
            unset($_SESSION['datiPG']); ?>
        </table>

    <?php } ?> <br>
    <hr><br> <?php

    if (isset($_SESSION['PF'])) {

        if ($_SESSION['PF'] <= 0) {

            echo '<script type="text/javascript">alert("Hai perso!")</script>';
            $_SESSION['perso'] = true;
            header("refresh:0.1; end.php");
        }
    }

    if (isset($_SESSION['nrOGG'])) {


        unset($_SESSION['nrOGG']);
        $posOggetti = 1;

        if (isset($_SESSION['elencoOggetti'])) { ?>

            <div align="center"><big><b>Elenco degli oggetti visibili</b></big></div><br>
            <table>
                <tr>
                    <th><b>Nome</b></th>
                    <th><b>Tipo</b></th>
                    <th><b>ATT Bonus</b></th>
                    <th><b>DIF Bonus</b></th>
                    <th><b>PER Bonus</b></th>
                    <th><b>PF Bonus</b></th>
                    <th><b>Danno</b></th>
                    <th></th>
                </tr>
                <form action="gestioneOGG.php" method="POST">
                    <?php foreach ($_SESSION['elencoOggetti'] as $row) : ?>
                        <tr>
                            <td><?php echo $row['nome_ogg']; ?></td>
                            <td><?php echo $row['tipo_ogg']; ?></td>
                            <td><?php echo $row['att_bonus']; ?></td>
                            <td><?php echo $row['dif_bonus']; ?></td>
                            <td><?php echo $row['per_bonus']; ?></td>
                            <td><?php echo $row['pf_bonus']; ?></td>
                            <td><?php echo $row['danno_inflitto']; ?></td>
                            <td><?php echo "<input type='submit' name='prendi' value='Prendi $posOggetti'>"; ?></td>
                        </tr>
                        <?php $posOggetti = $posOggetti + 1;
                    endforeach; ?>
                </form>
            </table>

        <?php } ?> <br>
        <hr><br> <?php
    }

    if (isset($_SESSION['nrNEM'])) {


        $nrNEM = $_SESSION['nrNEM'];
        unset($_SESSION['nrNEM']);

        if ($nrNEM == 0) {

            echo "<div align = 'center'><big><b>Non ci sono nemici in questa stanza</b></big></div>";

        }

        $posNemici = 1;

        if (isset($_SESSION['elencoNemici'])) { ?>

            <div align="center"><big><b>Elenco dei nemici</b></big></div><br>
            <table>
                <tr>
                    <th><b>Nome</b></th>
                    <th><b>Attacco</b></th>
                    <th><b>Difesa</b></th>
                    <th><b>Punti ferita</b></th>
                    <th><b>Danno</b></th>
                    <th></th>
                </tr>
                <form action="gestioneNEM.php" method="POST">
                    <?php foreach ($_SESSION['elencoNemici'] as $row) : ?>
                        <tr>
                            <td><?php echo $row['nome_n']; ?></td>
                            <td><?php echo $row['att_n']; ?></td>
                            <td><?php echo $row['dif_n']; ?></td>
                            <td><?php echo $row['pf_n']; ?></td>
                            <td><?php echo $row['danno_n']; ?></td>
                            <td><?php echo "<input type='submit' name='attacca' value='Attacca $posNemici'>"; ?></td>
                        </tr>
                        <?php $posNemici = $posNemici + 1;
                    endforeach; ?>
                </form>
            </table>

        <?php } ?> <br>
        <hr><br> <?php
    }


    if (isset($_SESSION['elencoInventario'])) {


        echo "<div align = 'center' ><big><b>Inventario</b></big></div>";
        echo "<br>";
        $posInventario = 1;


        $query = "SELECT * FROM DungeonsAsDB.Equipaggia WHERE Personaggio = '$nome';";
        $result = pg_query($dbconn, $query);

        if ($result) {

            $numRows = pg_num_rows($result);

            if ($numRows > 0) {

                $_SESSION['elencoEquipaggio'] = pg_fetch_all($result);
            } else {

                unset($_SESSION['elencoEquipaggio']);
            }
        } ?>

        <table>
            <tr>
                <th><b>Nome</b></th>
                <th><b>Tipo</b></th>
                <th><b>ATT Bonus</b></th>
                <th><b>DIF Bonus</b></th>
                <th><b>PER Bonus</b></th>
                <th><b>PF Bonus</b></th>
                <th><b>Danno</b></th>
                <th></th>
                <th></th>
                <th></th>
            </tr>
            <form action='gestioneOGG.php' method='POST'>
                <?php foreach ($_SESSION['elencoInventario'] as $row) : ?>
                    <tr>
                        <td><?php echo $row['oggetto']; ?></td>
                        <td><?php echo $row['tipo']; ?></td>
                        <td><?php echo $row['att_bonus']; ?></td>
                        <td><?php echo $row['dif_bonus']; ?></td>
                        <td><?php echo $row['per_bonus']; ?></td>
                        <td><?php echo $row['pf_bonus']; ?></td>
                        <td><?php echo $row['danno_inflitto']; ?></td>
                        <td><?php echo "<input type='submit' name='equip' value='Equipaggia $posInventario'>"; ?></td>
                        <td><?php if (isset($_SESSION['elencoEquipaggio'])) {
                                $posEquipaggio = 1;

                                foreach ($_SESSION['elencoEquipaggio'] as $equippedrow) :

                                    if ($row['oggetto'] == $equippedrow['oggetto']) {

                                        echo "<input type='submit' name='unequip' value='Disequipaggia $posEquipaggio'>";

                                    }
                                    $posEquipaggio = $posEquipaggio + 1;
                                endforeach;

                            } ?></td>
                        <td><?php echo "<input type='submit' name='cancel' value='Elimina $posInventario'>"; ?></td>
                    </tr>
                    <?php $posInventario = $posInventario + 1; endforeach; ?>
            </form>
        </table>
        <br>
        <hr><br>
    <?php }


    if (isset($_SESSION['stanzaA'])) {

        echo "<form align = 'center' action='gestioneGAME.php' method='POST'>";
        foreach ($_SESSION['stanzaA'] as $stanzaA) :

            $stanzaA = $stanzaA['stanza_a'];
            if ($stanzaA != 15) {
                echo "<input type='submit' class='submitOutOfTable' name='start' value='Vai verso la stanza $stanzaA'>";
            } else {

                echo "<input type='submit' class='submitOutOfTable' name='start' value='Stanza $stanzaA (finale)'>";
            }
            echo "<input type='hidden' name='stanzaNuova' value=$stanzaA>";
            echo " ";

        endforeach;
        echo "</form>";
        unset($_SESSION['stanzaA']);

    } else {

        echo "<div align = 'center' ><big><b>Devi eliminare tutti i nemici prima di poter avanzare</b></big></div>";

    }

    if (isset($_SESSION['nascosti'])) {

        unset($_SESSION['nascosti']);


        echo "<form align = 'center' action='gestioneNASCOSTI.php' method='POST'>";
        echo "<input type='submit' class='submitOutOfTable' name='nascosto' value='Cerca'>";
        echo "</form>";

    }

    if (isset($_SESSION['stanzaDA'])) {


        echo "<form align = 'center' action='gestioneGAME.php' method='POST'>";
        foreach ($_SESSION['stanzaDA'] as $stanzaDA) :

            $stanzaDA = $stanzaDA['stanza_da'];
            if ($stanzaDA != 1) {

                echo "<input type='submit' class='submitOutOfTable' name='start' value='Torna alla stanza $stanzaDA'>";

            } else {

                echo "<input type='submit' class='submitOutOfTable' name='start' value='Stanza $stanzaDA (iniziale)'>";
            }

            echo "<input type='hidden' name='stanzaNuova' value=$stanzaDA>";
            echo " ";

        endforeach;
        echo "</form>";
        unset($_SESSION['stanzaDA']);

    }
}

if (isset($_POST['start'])) {

    if (isset($_POST['stanzaNuova'])) { // il pulsante "vai alla stanza xx è stato premuto"

        unset($_POST['stanzaNuova']);
        $pos = $_POST['start'];
        $stanzaNuova = intval(preg_replace('/[^0-9]+/', '', $pos), 10); // prendo solo il numero della stanza dalla stringa
        $query = "UPDATE Personaggio SET stanza_pg = $stanzaNuova WHERE nome_pg = '$nomepg'";
        $result = pg_query($db, $query);
        if ($result) {

            unset($_POST['start']);
            header("Location: gestioneGAME.php");

        }
    }
}


if (isset($_SESSION['stanzaPG'])) {

    $nrstanza = $_SESSION['stanzaPG'];

    // NUMERO NEMICI + ELENCO NEMICI


    unset($_SESSION['elencoNemici']);
    $query = "SELECT COUNT(*) FROM RandomNemico WHERE stanza_n = $nrstanza AND Personaggio = '$nomepg';";
    $result = pg_query($db, $query);
    if ($result) {

        $_SESSION['nrNEM'] = pg_fetch_result($result, 0, 'count');

        if ($_SESSION['nrNEM'] > 0) { // se ci sono nemici

            $_SESSION['nemiciSconfitti'] = false;
            $query = "SELECT RandomNemico.nome_n, Nemico.att_n, RandomNemico.dif_n, RandomNemico.pf_n, Nemico.danno_n 
                      FROM RandomNemico LEFT OUTER JOIN Nemico ON RandomNemico.Nome_n = Nemico.Nome_n WHERE Stanza_N = $nrstanza AND Personaggio = '$nomepg';";
            $result = pg_query($db, $query);

            if ($result) {

                $rows = pg_num_rows($result);

                if ($rows > 0) {

                    $_SESSION['elencoNemici'] = pg_fetch_all($result);

                }
            }
        } else { // non ci sono nemici

            $_SESSION['nemiciSconfitti'] = true;

        }
    }


    // STANZA PRECEDENTE


    $query = "SELECT stanza_da FROM Passaggio INNER JOIN Stanza ON Stanza_ID = Passaggio.Stanza_A WHERE Stanza_a = $nrstanza 
              AND tipo_passaggio = 'visibile' AND Stanza.tipo IS NULL AND Passaggio.Personaggio = '$nomepg';";
    $result = pg_query($db, $query);

    if ($result) {

        $rows = pg_num_rows($result);

        if ($rows < 1) {

            unset($_SESSION['stanzaDA']);

        } else {

            $_SESSION['stanzaDA'] = pg_fetch_all($result);

        }
    }

// INVENTARIO + OGGETTI EQUIPAGGIATI

    $query = "SELECT * FROM getInventario('$nomepg') AS f(Oggetto varchar(20), Tipo tipi_oggetti, ATT_Bonus INTEGER, DIF_Bonus INTEGER, PER_Bonus INTEGER, PF_Bonus INTEGER, Danno_inflitto INTEGER);";
    $result = pg_query($db, $query);
    if ($result) {

        $rows = pg_num_rows($result);

        if ($rows > 0) {

            $_SESSION["elencoInventario"] = pg_fetch_all($result);
        }
    }

    // DATI PERSONAGGIO (statistiche)

    $query = "SELECT * FROM datiPG('$nomepg');";
    $result = pg_query($db, $query);
    if ($result) {

        $rows = pg_num_rows($result);

        if ($rows > 0) {

            $_SESSION["datiPG"] = pg_fetch_all($result);
        }
    }


    // SE TUTTI I NEMICI SONO STATI SCONFITTI

    if ($_SESSION['nemiciSconfitti'] == true) {

        // NUMERO OGGETTI + ELENCO OGGETTI

        unset($_SESSION['elencoOggetti']);
        $query = "SELECT COUNT(*) FROM RandomOggetto WHERE stanza_o = $nrstanza AND Personaggio = '$nomepg';";
        $result = pg_query($db, $query);
        if ($result) {

            $_SESSION['nrOGG'] = pg_fetch_result($result, 0, 'count'); // nr ogg


            if ($_SESSION['nrOGG'] > 0) { // se ci sono oggetti

                $query = "SELECT RandomOggetto.Nome_ogg, tipo_ogg, ATT_Bonus, DIF_Bonus, PER_Bonus, PF_Bonus, Danno_inflitto FROM RandomOggetto LEFT OUTER JOIN
                          Oggetto ON RandomOggetto.Nome_ogg = Oggetto.Nome_ogg WHERE Stanza_O = $nrstanza AND RandomOggetto.Visibilita_ogg = 'visibile' AND Personaggio = '$nomepg';";
                $result = pg_query($db, $query);

                if ($result) {
                    $rows = pg_num_rows($result);

                    if ($rows > 0) {

                        $_SESSION['elencoOggetti'] = pg_fetch_all($result);

                    }
                }
            }
        }


        //  STANZA SUCCESSIVA


        $query = "SELECT stanza_a FROM Passaggio WHERE Stanza_da = $nrstanza AND tipo_passaggio = 'visibile' AND Passaggio.Personaggio = '$nomepg';";
        $result = pg_query($db, $query);

        if ($result) {

            $_SESSION['stanzaA'] = pg_fetch_all($result);

        }


        // PER IL PULSANTE "CERCA OGGETTI/PASSAGGI NASCOSTI"

        $_SESSION['nascosti'] = true;


    }


    generaStanza($nrstanza, $nomepg, $db);
}


?>

<form action='end.php' method='POST'>
    <input type="submit" class="submitOutOfTable" name="rinuncia" value="Rinuncia">
</form>
<br>
<hr>
<br>
<address align="center">
    Andrei Ciulpan<br>
    Progetto di Basi di Dati<br>
    2016-2017<br>
</address>
</body>
</html>