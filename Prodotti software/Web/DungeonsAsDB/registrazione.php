<?php
session_start();
require 'connessione.php';

// Recupero i valori "email" "password" "nome" e li assegno alle relative variabili 

$email = strtolower($_POST['email']);
$password = md5($_POST['password']);
$name = strtolower($_POST['nome']);

if (empty($email) || empty($password) || empty($name)) {

    echo '<script type="text/javascript">alert("Devi prima inserire i dati per poter registrarti.")</script>';
    header('refresh:0.1; url=index.php');

    }

    else {

      $query = "INSERT INTO Utente(nome_utente, password, e_mail) VALUES ('$name','$password', '$email')";
      $result = pg_query($db, $query);

      if ($result) {
          echo '<script type="text/javascript">alert("Dati inseriti correttamente. Ora puoi fare il login.")</script>';
          header('refresh:0.1; url=login.php');
      }

      else {

          echo '<script type="text/javascript">alert("Dati inseriti sbagliati. Ritorno alla pagina iniziale.")</script>';
          header('refresh:0.1; url=index.php');
      }
      pg_close($db);
  }
?>

