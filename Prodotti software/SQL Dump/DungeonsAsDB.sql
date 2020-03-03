--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.0
-- Dumped by pg_dump version 9.6.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: dungeonsasdb; Type: SCHEMA; Schema: -; Owner: andreiciulpan
--

CREATE SCHEMA dungeonsasdb;


ALTER SCHEMA dungeonsasdb OWNER TO andreiciulpan;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


SET search_path = dungeonsasdb, pg_catalog;

--
-- Name: datipersonaggio; Type: TYPE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TYPE datipersonaggio AS (
	arma_eq character varying(20),
	armatura_eq character varying(20),
	"FOR" integer,
	"int" integer,
	agi integer,
	cost double precision,
	att integer,
	dif integer,
	per integer,
	pf integer,
	pe integer,
	capienza integer
);


ALTER TYPE datipersonaggio OWNER TO andreiciulpan;

--
-- Name: lancidadi; Type: TYPE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TYPE lancidadi AS (
	tiro integer,
	valore integer
);


ALTER TYPE lancidadi OWNER TO andreiciulpan;

--
-- Name: tipi_di_visibilita; Type: DOMAIN; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE DOMAIN tipi_di_visibilita AS character varying(8)
	CONSTRAINT tipi_di_visibilita_check CHECK (((VALUE)::text = ANY ((ARRAY['visibile'::character varying, 'nascosto'::character varying])::text[])));


ALTER DOMAIN tipi_di_visibilita OWNER TO andreiciulpan;

--
-- Name: tipi_oggetti; Type: DOMAIN; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE DOMAIN tipi_oggetti AS character varying(8)
	CONSTRAINT tipi_oggetti_check CHECK (((VALUE)::text = ANY ((ARRAY['arma'::character varying, 'armatura'::character varying, 'gioiello'::character varying, 'pozione'::character varying, 'razione'::character varying])::text[])));


ALTER DOMAIN tipi_oggetti OWNER TO andreiciulpan;

--
-- Name: aggiornastanzanemici(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION aggiornastanzanemici() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

   IF (TG_OP = 'INSERT') THEN

    UPDATE DungeonsAsDB.Stanza SET NR_NEM = NR_NEM + 1 WHERE Stanza_ID = NEW.Stanza_N;
    RETURN NEW;

  ELSIF (TG_OP = 'DELETE') THEN

    UPDATE DungeonsAsDB.Stanza SET NR_NEM = NR_NEM - 1 WHERE Stanza_ID = OLD.Stanza_N;
    RETURN OLD;
  
  END IF;
  
END
$$;


ALTER FUNCTION dungeonsasdb.aggiornastanzanemici() OWNER TO andreiciulpan;

--
-- Name: aggiornastanzaoggetti(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION aggiornastanzaoggetti() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

   IF (TG_OP = 'INSERT') THEN

    UPDATE DungeonsAsDB.Stanza SET NR_OGG = NR_OGG + 1 WHERE Stanza_ID = NEW.Stanza_O;
    RETURN NEW;

  ELSIF (TG_OP = 'DELETE') THEN

    UPDATE DungeonsAsDB.Stanza SET NR_OGG = NR_OGG - 1 WHERE Stanza_ID = OLD.Stanza_O;
    RETURN OLD;

  END IF;

END
$$;


ALTER FUNCTION dungeonsasdb.aggiornastanzaoggetti() OWNER TO andreiciulpan;

--
-- Name: aggiornastanzapassaggi(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION aggiornastanzapassaggi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$


BEGIN

  IF (TG_OP = 'INSERT') THEN


    UPDATE DungeonsAsDB.Stanza SET NR_PASS = NR_PASS + 1 WHERE Stanza_ID = NEW.Stanza_DA;
    RETURN NEW;

  ELSIF (TG_OP = 'DELETE') THEN

    UPDATE DungeonsAsDB.Stanza SET NR_PASS = NR_PASS - 1 WHERE Stanza_ID = OLD.Stanza_DA;
    RETURN OLD;

  END IF;


END;
$$;


ALTER FUNCTION dungeonsasdb.aggiornastanzapassaggi() OWNER TO andreiciulpan;

--
-- Name: attacca(character varying, character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION attacca(character varying, character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pg ALIAS FOR $1;
  pgATT INTEGER;
  pgDIF INTEGER;
  armaPG DungeonsAsDB.Personaggio.arma_eq%TYPE;
  dannoPG INTEGER;

  nemNOME ALIAS FOR $2;
  nemATT INTEGER;
  nemDIF INTEGER;
  nemDANNO INTEGER;

  dado INTEGER;
  A INTEGER;
  riuscito INTEGER;
  riuscitoNEM INTEGER;
  riuscitoPG INTEGER;




BEGIN


  -- 1. dati che mi servono

  riuscito := 0;
  riuscitoNEM := 0;
  riuscitoPG := 0;
  SELECT att, dif, arma_eq  INTO pgATT, pgDIF, armaPG FROM DungeonsAsDB.Personaggio WHERE nome_pg = pg;
  SELECT Danno_inflitto INTO dannoPG FROM DungeonsAsDB.Oggetto WHERE Nome_ogg = armaPG;
  SELECT att_n, dif_n, danno_n INTO nemATT, nemDIF, nemDANNO FROM DungeonsAsDB.Nemico WHERE nome_n = nemNOME;

  -- 2. il nemico attacca il personaggio

  SELECT * INTO dado FROM diceRoll(1, 20);
  A := (nemATT - pgDIF) + dado;

  IF (A > 12) THEN

    UPDATE DungeonsAsDB.Personaggio SET PF = PF - nemDANNO WHERE Nome_pg = pg;
    riuscitoNEM := 2;
    RAISE NOTICE 'L''ATTACCO (% -> %) E'' RIUSCITO', nemNOME, pg;

  END IF;

  -- 3. il personaggio attacca il nemico

  SELECT * INTO dado FROM diceRoll(1, 20);
  A := (pgATT - nemDIF) + dado;

  IF (A > 12) THEN

    UPDATE DungeonsAsDB.RandomNemico SET PF_N = PF_N - dannoPG WHERE Nome_N = nemNOME;
    riuscitoPG := 1;
    RAISE NOTICE 'L''ATTACCO (% -> %) E'' RIUSCITO', pg, nemNOME;

  END IF;

  riuscito = riuscitoNEM + riuscitoPG;

  -- riuscito = 0: nessuno è riuscito ad attaccare
  -- riuscito = 1: solo il pg è riuscito ad attaccare
  -- riuscito = 2: solo il nemico è riuscito ad attaccare
  -- riuscito = 3: entrambi sono riusciti ad attaccare
  
  RETURN riuscito;

END;
$_$;


ALTER FUNCTION dungeonsasdb.attacca(character varying, character varying) OWNER TO andreiciulpan;

--
-- Name: balancenemici(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION balancenemici() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

 attPG INTEGER;
  difN INTEGER;
  A INTEGER;

BEGIN

    -- balance
    -- prendo l'ATT del personaggio

    SELECT ATT INTO attPG FROM DungeonsAsDB.Personaggio WHERE Nome_pg = NEW.Personaggio;

    -- prendo DIF del nemico

    SELECT DIF_N INTO difN FROM DungeonsAsDB.Nemico WHERE nome_n = NEW.nome_n;

    -- ATT - DIF

    A := (attPG - difN) + 16; -- 16 valore ragionevole del lancio di 1d20 (oltre il 16 diventa troppo difficile)

    -- SE A E' TROPPO BASSO, RIDUCO LA DIFESA DEL NEMICO A VALORI RAGIONABILI

    IF (A < 12) THEN

       UPDATE RandomNemico SET DIF_N = DIF_N - (12 - A) WHERE nome_n = NEW.Nome_n AND Personaggio = NEW.Personaggio;

    END IF;
  
    RETURN NEW;

END;
$$;


ALTER FUNCTION dungeonsasdb.balancenemici() OWNER TO andreiciulpan;

--
-- Name: calcolape(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION calcolape(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  stanzeVisitate INTEGER;
  dannoNemici INTEGER;
  esperienza INTEGER;


BEGIN

  SELECT visited INTO stanzeVisitate FROM informazioniGioco WHERE Personaggio = nomePG;
  SELECT danno_N_defeated INTO dannoNemici FROM informazioniGioco WHERE Personaggio = nomePG;

  esperienza = ((stanzeVisitate) * 10) + dannoNemici;

  UPDATE Personaggio SET PE = PE + esperienza WHERE Nome_pg = nomePG;

  RETURN esperienza;

END;
$_$;


ALTER FUNCTION dungeonsasdb.calcolape(character varying) OWNER TO andreiciulpan;

--
-- Name: cambiastanza(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION cambiastanza() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  nomeOGG DungeonsAsDB.Equipaggia.Oggetto%TYPE;


BEGIN

  FOR nomeOGG IN SELECT Oggetto  FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Oggetto.nome_ogg = equipaggia.Oggetto WHERE Personaggio = NEW.Nome_pg AND Tipo_ogg = 'pozione'

    LOOP

    DELETE FROM Equipaggia WHERE Oggetto = nomeOGG AND Personaggio = NEW.Nome_PG; -- cancella le pozioni dopo il cambiamento della stanza

  END LOOP;

  UPDATE Passaggio SET visitedStanza_DA = true WHERE Stanza_DA = NEW.Stanza_PG AND Personaggio = NEW.nome_pg; -- stanza visitata (serve per il calcolo di PE)


  RETURN NEW;

END;
$$;


ALTER FUNCTION dungeonsasdb.cambiastanza() OWNER TO andreiciulpan;

--
-- Name: cercanascosti(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION cercanascosti(character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  perPG INTEGER;
  pfPG INTEGER;
  stanzaPG INTEGER;

  dado INTEGER;
  successo INTEGER;
  trovato VARCHAR(20);


BEGIN


  -- DATI NECESSARI

   SELECT PER, Stanza_PG, PF INTO perPG, stanzaPG, pfPG FROM DungeonsAsDB.Personaggio WHERE nome_pg = nomePG;

  -- SE PF <= 1 allora non può piu' fare ricerche (altrimenti muore)

  IF (pfPG <= 1) THEN

    RAISE EXCEPTION 'Non hai abbastanza punti ferita per effettura la ricerca';

  END IF;


  -- -1 PF AL PG

  UPDATE DungeonsAsDB.Personaggio SET PF = PF - 1 WHERE nome_pg = nomePG;

  -- LANCIO DADO

  SELECT * INTO dado FROM diceRoll(1, 20);

  IF ( dado < perPG ) THEN

    successo := 1;

  ELSE

    successo := 0;

  END IF;


  IF ( successo = 1 ) THEN

    WITH tempOGG AS (

              SELECT nome_ogg FROM DungeonsAsDB.RandomOggetto WHERE Stanza_O = stanzaPG AND Visibilita_ogg = 'nascosto' AND RandomOggetto.Personaggio = nomePG
      ), tempPASS AS (

              SELECT cast(stanza_a as varchar(2)) FROM DungeonsAsDB.Passaggio WHERE stanza_da = stanzaPG AND Tipo_passaggio = 'nascosto' AND Passaggio.Personaggio = nomePG
      ), oggANDpass AS (

              SELECT * FROM tempOGG UNION ALL SELECT * FROM tempPASS -- tabella con tutti gli oggetti e passaggi nascosti in quella stanza
      )

    SELECT nome_ogg INTO trovato FROM oggANDpass ORDER BY RANDOM() LIMIT 1; -- seleziono un oggetto/passaggio nascosto a caso


    IF (SELECT (trovato ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$')) THEN -- se la stringa è un numero allora appartiene ad una stanza, altrimenti ad un oggetto

      UPDATE DungeonsAsDB.Passaggio SET Tipo_passaggio = 'visibile' WHERE stanza_a = cast(trovato as integer) AND stanza_da = stanzaPG AND Passaggio.Personaggio = nomePG;

    ELSE

      UPDATE DungeonsAsDB.RandomOggetto SET Visibilita_ogg = 'visibile' WHERE nome_ogg = trovato AND stanza_o = stanzaPG AND RandomOggetto.Personaggio = nomePG;

    END IF;


  END IF;

  RETURN trovato;

END;
$_$;


ALTER FUNCTION dungeonsasdb.cercanascosti(character varying) OWNER TO andreiciulpan;

--
-- Name: creapg(integer, character varying, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION creapg(integer, character varying, double precision, double precision, double precision, double precision) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  utenteID ALIAS FOR $1;
  nomepg ALIAS FOR $2;
  valFOR ALIAS FOR $3;
  valINT  ALIAS FOR $4;
  valAGI  ALIAS FOR $5;
  valCOST ALIAS FOR $6;
  valATT INTEGER;
  valDIF INTEGER;
  valPER INTEGER;
  valPF INTEGER;


BEGIN




  valATT = ceil((valFOR+valAGI)/2);
  valDIF = ceil((valCOST+valAGI)/2);
  valPER = valINT;
  valPF = valCOST;

  IF EXISTS(SELECT 1 FROM Personaggio WHERE Nome_pg = nomepg AND Utente_ID = utenteID) THEN -- se esiste già il nome del PG

     PERFORM * FROM fineGame(nomepg); -- azzerra i dati del pg tranne PE
     UPDATE informazioniGioco SET (visited, defeated, danno_N_defeated) = (default, default, default) WHERE Personaggio = nomepg;
     UPDATE Personaggio SET ("FOR", INT,  AGI,  COST, ATT,  DIF,  PER,  PF, Stanza_PG) = (valFOR, valINT, valAGI, valCOST, valATT, valDIF, valPER, valPF, DEFAULT) WHERE Nome_pg = nomepg AND Utente_ID = utenteID;


  ELSE -- se devo creare un nuovo pg

     INSERT INTO Personaggio(Nome_pg, "FOR", INT, AGI, COST, ATT, DIF, PER, PF, Utente_ID) VALUES(nomepg, valFOR, valINT, valAGI, valCOST, valATT, valDIF, valPER, valPF, utenteID);
     INSERT INTO informazioniGioco(Personaggio) VALUES (nomepg);

  END IF;

  PERFORM * FROM generanemici(nomepg);
  PERFORM * FROM generaOggetti(nomepg);
  PERFORM * FROM generaPassaggi(nomepg);
  INSERT INTO Possiede VALUES (nomepg, 'Spada Base');
  INSERT INTO Possiede VALUES (nomepg, 'Pane');

  RETURN;

END;

$_$;


ALTER FUNCTION dungeonsasdb.creapg(integer, character varying, double precision, double precision, double precision, double precision) OWNER TO andreiciulpan;

--
-- Name: datipg(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION datipg(character varying) RETURNS datipersonaggio
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nome ALIAS FOR $1;
  dati datiPersonaggio;
  
BEGIN


  SELECT arma_eq, armatura_eq, "FOR", int, agi, cast(cost as float), att, dif, per, pf, pe, ceil(cost/2) as Capienza
  INTO dati.arma_eq, dati.armatura_eq, dati."FOR", dati.int, dati.agi, dati.cost, dati.att, dati.dif, dati.per, dati.pf, dati.pe, dati.capienza
  FROM Personaggio WHERE nome_pg = nome;

  RETURN dati;

END;
$_$;


ALTER FUNCTION dungeonsasdb.datipg(character varying) OWNER TO andreiciulpan;

--
-- Name: delbonusoggetti(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION delbonusoggetti() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  attBONUS INTEGER;
  difBONUS INTEGER;
  perBONUS INTEGER;
  pfBONUS INTEGER;

  tipoOGG DungeonsAsDB.Oggetto.tipo_ogg%TYPE;
  nomeOGG DungeonsAsDB.Oggetto.nome_ogg%TYPE;


BEGIN

  SELECT  ATT_Bonus, DIF_Bonus, PER_Bonus, PF_Bonus, Tipo_ogg, Nome_ogg INTO attBONUS, difBONUS, perBONUS, pfBONUS, tipoOGG, nomeOGG
  FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Equipaggia.Oggetto = Oggetto.Nome_ogg
  WHERE Personaggio = OLD.Personaggio AND Oggetto = OLD.Oggetto;


  UPDATE DungeonsAsDB.Personaggio SET ATT = ATT - attBONUS WHERE Personaggio.Nome_pg = OLD.Personaggio;
  UPDATE DungeonsAsDB.Personaggio SET DIF = DIF - difBONUS WHERE Personaggio.Nome_pg = OLD.Personaggio;
  UPDATE DungeonsAsDB.Personaggio SET PER = PER - perBONUS WHERE Personaggio.Nome_pg = OLD.Personaggio;
  UPDATE DungeonsAsDB.Personaggio SET PF = PF - pfBONUS WHERE Personaggio.Nome_pg = OLD.Personaggio;

  IF (tipoOGG = 'arma') THEN

    UPDATE DungeonsAsDB.Personaggio SET arma_eq = NULL WHERE Personaggio.Nome_pg = OLD.Personaggio;
    RETURN OLD;

    ELSIF (tipoOGG = 'armatura') THEN

    UPDATE DungeonsAsDB.Personaggio SET Armatura_eq = NULL WHERE Personaggio.Nome_pg = OLD.Personaggio;
    RETURN OLD;

    ELSE

    RETURN OLD;

    END IF;

END;
$$;


ALTER FUNCTION dungeonsasdb.delbonusoggetti() OWNER TO andreiciulpan;

--
-- Name: diceroll(integer, integer); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION diceroll(integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nrLanci ALIAS FOR $1;
  dado ALIAS FOR $2;
  sum INTEGER;

BEGIN

  sum := 0;
  WHILE nrLanci > 0
  LOOP

    nrLanci := nrLanci - 1;
    sum := sum + (random() * (dado - 1) + 1);

  END LOOP;

  RETURN sum;


END;

$_$;


ALTER FUNCTION dungeonsasdb.diceroll(integer, integer) OWNER TO andreiciulpan;

--
-- Name: finegame(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION finegame(character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;

BEGIN

  ALTER TABLE Possiede DISABLE TRIGGER ultimaArma_trigger; -- per evitare il trigger sull'ultima arma (cosi' posso svuotare tutto)
  DELETE FROM Possiede WHERE Personaggio = nomePG;
  ALTER TABLE Possiede ENABLE TRIGGER ultimaArma_trigger;

  DELETE FROM Equipaggia WHERE Personaggio = nomePG;

  -- azzero il mondo

  DELETE FROM RandomNemico WHERE Personaggio = nomePG;
  DELETE FROM RandomOggetto WHERE Personaggio = nomePG;
  DELETE FROM Passaggio WHERE Personaggio = nomePG;

  UPDATE Personaggio SET ("FOR", int, agi, cost, att, dif, per, pf, numero_ogg) = (default, default, default, default, default, default, default, default, default) WHERE Nome_pg = nomePG;
  UPDATE Passaggio SET visitedStanza_DA = false WHERE Personaggio = nomePG;
  UPDATE informazioniGioco SET (defeated, danno_N_defeated) = (DEFAULT, DEFAULT) WHERE Personaggio = nomePG;

END;
$_$;


ALTER FUNCTION dungeonsasdb.finegame(character varying) OWNER TO andreiciulpan;

--
-- Name: generanemici(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION generanemici(character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  nem DungeonsasDB.Nemico%ROWTYPE;
  stanza INTEGER;



BEGIN

  DELETE FROM DungeonsAsDB.RandomNemico WHERE Personaggio = nomePG;

  FOR nem IN SELECT * FROM DungeonsAsDB.Nemico -- ogni tupla in nemico

  LOOP

    SELECT Stanza.Stanza_ID INTO stanza FROM DungeonsAsDB.Stanza WHERE Stanza.tipo IS NULL ORDER BY RANDOM() LIMIT 1; -- stanza random
    INSERT INTO DungeonsAsDB.RandomNemico VALUES (nem.Nome_N, nem.PF_N, stanza, nomePG, nem.DIF_N);

  END LOOP;

  RETURN;

END;
$_$;


ALTER FUNCTION dungeonsasdb.generanemici(character varying) OWNER TO andreiciulpan;

--
-- Name: generaoggetti(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION generaoggetti(character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  ogg DungeonsasDB.Oggetto%ROWTYPE;
  vis DungeonsAsDB.tipi_di_visibilita;
  stanza INTEGER;
  random INTEGER;



BEGIN

    DELETE FROM DungeonsAsDB.RandomOggetto WHERE Personaggio = nomePG;


  FOR ogg IN SELECT * FROM DungeonsAsDB.Oggetto WHERE nome_ogg != 'Pane' AND nome_ogg != 'Spada Base' -- ogni tupla in oggetto tranne quelle base

  LOOP

    SELECT round(random() * (0 + 1)) INTO random; -- valore random tra 0 e 1 -- SELECT round(random() * (0+1)) as i from generate_series(1,1000000); test

    IF (random = 0) THEN

      vis = 'nascosto';

    ELSE

      vis = 'visibile';

    END IF;
    SELECT Stanza.Stanza_ID INTO stanza FROM DungeonsAsDB.Stanza WHERE Stanza.tipo IS NULL OR Stanza.tipo = 'iniziale' ORDER BY RANDOM() LIMIT 1; -- stanza random
    INSERT INTO DungeonsAsDB.randomoggetto VALUES (ogg.nome_ogg, vis, stanza, nomePG);

  END LOOP;

  UPDATE RandomOggetto SET Visibilita_ogg = 'visibile' 
  WHERE nome_ogg IN (SELECT nome_ogg FROM Oggetto WHERE Tipo_ogg = 'razione') AND RandomOggetto.Personaggio = nomePG; -- voglio le razioni visibili per facilitare il gioco
  RETURN;

END;
$_$;


ALTER FUNCTION dungeonsasdb.generaoggetti(character varying) OWNER TO andreiciulpan;

--
-- Name: generapassaggi(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION generapassaggi(character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  stanzaDA INTEGER;
  stanzaA INTEGER;
  stanzaFINALE INTEGER;
  count INTEGER;

BEGIN

  DELETE FROM Passaggio WHERE Personaggio = nomePG;
  -- dati

  SELECT Stanza_ID INTO stanzaFINALE FROM DungeonsAsDB.Stanza WHERE tipo = 'finale';
  SELECT COUNT(*) INTO count FROM Stanza WHERE Tipo IS NULL;

  -- inizio con la stanza iniziale
  SELECT stanza_ID INTO stanzaDA FROM DungeonsAsDB.Stanza WHERE tipo = 'iniziale';

  WHILE count >= 0

    LOOP

    -- stanza random

    SELECT Stanza.Stanza_ID INTO stanzaA FROM DungeonsAsDB.Stanza WHERE Stanza.tipo IS NULL  ORDER BY RANDOM() LIMIT 1;


    IF (stanzaA IS NOT NULL) THEN

          -- inserisci la tupla

        INSERT INTO DungeonsAsDB.Passaggio VALUES (stanzaDA, stanzaA, 'visibile', default, nomePG);

          -- aggiorna stanzaDA e cambia il tipo della stanza cosi' non la prende piu'

        stanzaDA = stanzaA;
        UPDATE DungeonsAsDB.Stanza SET tipo = 'inserito' WHERE stanza_id = stanzaDA;

    END IF;


    count = count - 1;

  END LOOP;


  -- stanza finale

  INSERT INTO DungeonsAsDB.Passaggio VALUES (stanzaDA, stanzaFINALE, 'visibile', default, nomePG);

  -- azzero il tipo

  UPDATE Stanza SET tipo = NULL WHERE tipo = 'inserito';

  PERFORM * FROM generaPassaggiSegreti(nomePG);


  RETURN;

END;
$_$;


ALTER FUNCTION dungeonsasdb.generapassaggi(character varying) OWNER TO andreiciulpan;

--
-- Name: generapassaggisegreti(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION generapassaggisegreti(character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  stanzaDA INTEGER;
  stanzaA INTEGER;
  count INTEGER;
  penultima INTEGER; -- non voglio passaggi nascosti quando arrivo nella penultima stanza ma voglio andare nell'ultima stanza a finire il gioco
  ultima INTEGER;



BEGIN

  SELECT Stanza_ID INTO ultima FROM DungeonsAsDB.Stanza WHERE tipo = 'finale';
  SELECT stanza_DA INTO penultima FROM DungeonsAsDB.Passaggio WHERE stanza_A = ultima AND Personaggio = nomePG; --  voglio la penultima stanza

  count := 15; -- massimo 15 passaggi nascosti altrimenti diventa un casino

  WHILE count > 0

    LOOP

     -- select stanzaDA random

    SELECT stanza_DA INTO stanzaDA FROM DungeonsAsDB.Passaggio WHERE Personaggio = nomePG  ORDER BY RANDOM() LIMIT 1;

    -- select stanzaA random

    SELECT stanza_id INTO stanzaA FROM DungeonsAsDB.Stanza WHERE tipo IS NULL ORDER BY RANDOM() LIMIT 1;

    -- insert tupla se stanzaDA != stanzaA // se non esiste già quel passaggio // se non è la penultima stanza

    IF ((stanzaDA != stanzaA) AND (stanzaDA != penultima)
        AND NOT EXISTS(SELECT 1 FROM DungeonsAsDB.Passaggio WHERE stanza_DA = stanzaDA AND stanza_A = stanzaA AND Passaggio.Personaggio = nomePG)) THEN

      INSERT INTO DungeonsAsDB.Passaggio VALUES (stanzaDA, stanzaA, 'nascosto', default, nomePG);
      count = count - 1;

    END IF;


  END LOOP;

  RETURN;

END;
$_$;


ALTER FUNCTION dungeonsasdb.generapassaggisegreti(character varying) OWNER TO andreiciulpan;

--
-- Name: gestioneequipaggia(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION gestioneequipaggia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  countARMA INTEGER;
  countARMATURA INTEGER;
  countGIOIELLO INTEGER;

  tipoOGG DungeonsAsDB.Oggetto.tipo_ogg%TYPE;
  nomeOGG DungeonsAsDB.Oggetto.nome_ogg%TYPE;

  attBONUS INTEGER;
  difBONUS INTEGER;
  perBONUS INTEGER;
  pfBONUS INTEGER;


BEGIN


  SELECT COUNT(Tipo_ogg) INTO countARMA
  FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Equipaggia.Oggetto = Oggetto.Nome_ogg
  WHERE Personaggio = NEW.Personaggio AND Tipo_ogg = 'arma';

  SELECT COUNT(Tipo_ogg) INTO countARMATURA
  FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Equipaggia.Oggetto = Oggetto.Nome_ogg
  WHERE Personaggio = NEW.Personaggio AND Tipo_ogg = 'armatura';

  SELECT COUNT(Tipo_ogg) INTO countGIOIELLO
  FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Equipaggia.Oggetto = Oggetto.Nome_ogg
  WHERE Personaggio = NEW.Personaggio AND Tipo_ogg = 'gioiello';


  IF countARMA > 1 OR countARMATURA > 1 OR countGIOIELLO > 2 THEN

    RAISE EXCEPTION 'Massimo 1 arma, 1 armatura, 2 gioielli';

  ELSE

    SELECT  ATT_Bonus, DIF_Bonus, PER_Bonus, PF_Bonus, Tipo_ogg, nome_ogg INTO attBONUS, difBONUS, perBONUS, pfBONUS, tipoOGG, nomeOGG
    FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Equipaggia.Oggetto = Oggetto.Nome_ogg
    WHERE Personaggio = NEW.Personaggio AND Oggetto = NEW.Oggetto;

    UPDATE DungeonsAsDB.Personaggio SET ATT = ATT + attBONUS WHERE Personaggio.Nome_pg = NEW.Personaggio;
    UPDATE DungeonsAsDB.Personaggio SET DIF = DIF + difBONUS WHERE Personaggio.Nome_pg = NEW.Personaggio;
    UPDATE DungeonsAsDB.Personaggio SET PER = PER + perBONUS WHERE Personaggio.Nome_pg = NEW.Personaggio;
    UPDATE DungeonsAsDB.Personaggio SET PF = PF + pfBONUS WHERE Personaggio.Nome_pg = NEW.Personaggio;

    IF (tipoOGG = 'arma') THEN

      UPDATE DungeonsAsDB.Personaggio SET arma_eq = nomeOGG WHERE Personaggio.Nome_pg = NEW.Personaggio;
      RETURN NEW;

    ELSIF (tipoOGG = 'armatura') THEN

     UPDATE DungeonsAsDB.Personaggio SET Armatura_eq = nomeOGG WHERE Personaggio.Nome_pg = NEW.Personaggio;
     RETURN NEW;

   ELSIF (tipoOGG = 'pozione') OR (tipoOGG = 'razione') THEN

      DELETE FROM DungeonsAsDB.Possiede WHERE Personaggio = NEW.Personaggio AND Oggetto = NEW.Oggetto;
      RETURN NEW;

    ELSE RETURN NEW;

    END IF;

  END IF;

END;
$$;


ALTER FUNCTION dungeonsasdb.gestioneequipaggia() OWNER TO andreiciulpan;

--
-- Name: gestioneinventario(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION gestioneinventario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  count INTEGER;
  valCOST FLOAT;
  tipoOGG DungeonsAsDB.Oggetto.tipo_ogg%TYPE;


BEGIN

  IF (TG_OP = 'DELETE') THEN

    SELECT COUNT(*) INTO count FROM DungeonsAsDB.Possiede WHERE Personaggio = OLD.Personaggio;
    UPDATE DungeonsAsDB.Personaggio SET Numero_ogg = count WHERE Personaggio.Nome_pg = OLD.Personaggio; -- aggiorna numero di oggetti posseduti
    SELECT tipo_ogg INTO tipoOGG FROM DungeonsAsDB.Equipaggia INNER JOIN DungeonsAsDB.Oggetto ON Equipaggia.Oggetto = Oggetto.Nome_ogg WHERE Personaggio = OLD.Personaggio AND Oggetto = OLD.Oggetto;

    IF (tipoOGG != 'pozione') AND (tipoOGG != 'razione') THEN

      DELETE FROM DungeonsAsDB.Equipaggia WHERE Personaggio = OLD.Personaggio AND Oggetto = OLD.Oggetto; -- cancella da equipaggia se un oggetto (diverso da pozione o razione) viene cancellato dall'inventario

    END IF;

  RETURN OLD;

  ELSIF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN

    SELECT COUNT(*) INTO count FROM DungeonsAsDB.Possiede WHERE Personaggio = NEW.Personaggio;
    SELECT COST INTO valCOST FROM DungeonsAsDB.Personaggio WHERE Nome_pg = NEW.Personaggio;
    valCOST = ceil(valCOST/2);

    IF count = valCOST THEN

       RAISE WARNING 'Attenzione! Hai appena raggiunto il numero massimo (%) di oggetti che puoi possedere', valCOST;
       UPDATE DungeonsAsDB.Personaggio SET Numero_ogg = count WHERE Personaggio.Nome_pg = NEW.Personaggio; -- aggiorna numero di oggetti posseduti
       DELETE FROM DungeonsAsDB.RandomOggetto WHERE RandomOggetto.Nome_ogg = NEW.Oggetto AND Personaggio = NEW.Personaggio; -- cancella dal mondo
       RETURN NEW;

    ELSIF count > valCOST THEN

      RAISE EXCEPTION 'Non puoi possedere un numero di oggetti maggiore di %', valCOST;

    ELSE

      UPDATE DungeonsAsDB.Personaggio SET Numero_ogg = count WHERE Personaggio.Nome_pg = NEW.Personaggio; -- aggiorna numeri di oggetti posseduti
      DELETE FROM DungeonsAsDB.RandomOggetto WHERE RandomOggetto.Nome_ogg = NEW.Oggetto AND Personaggio = NEW.Personaggio; -- cancella dal mondo
      RETURN NEW;

    END IF;

  END IF;

END;
$$;


ALTER FUNCTION dungeonsasdb.gestioneinventario() OWNER TO andreiciulpan;

--
-- Name: getinventario(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION getinventario(character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;

BEGIN

  RETURN QUERY SELECT Oggetto, Tipo_ogg, ATT_Bonus, DIF_Bonus, PER_Bonus, PF_Bonus, Danno_inflitto FROM DungeonsAsDB.Oggetto 
    INNER JOIN DungeonsAsDB.Possiede ON Oggetto.Nome_ogg = Possiede.Oggetto WHERE Personaggio = nomePG;


END;
$_$;


ALTER FUNCTION dungeonsasdb.getinventario(character varying) OWNER TO andreiciulpan;

--
-- Name: getstanzapg(character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION getstanzapg(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

  stanza INTEGER;
  nomePG ALIAS FOR $1;

BEGIN

  SELECT Stanza_PG INTO stanza FROM Personaggio WHERE Nome_pg = nomePG;
  RETURN stanza;


END;
$_$;


ALTER FUNCTION dungeonsasdb.getstanzapg(character varying) OWNER TO andreiciulpan;

--
-- Name: massimo2nemici(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION massimo2nemici() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  count INTEGER;
  

BEGIN


  SELECT COUNT(*) INTO count FROM DungeonsAsDB.RandomNemico WHERE RandomNemico.Stanza_N = NEW.Stanza_N AND Personaggio = NEW.Personaggio;

  IF count >= 2

    THEN

      RETURN NULL; -- non inserisce la tupla

    ELSE

    RETURN NEW;

    END IF;

END;
$$;


ALTER FUNCTION dungeonsasdb.massimo2nemici() OWNER TO andreiciulpan;

--
-- Name: massimo2passaggisegreti(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION massimo2passaggisegreti() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  countDA INTEGER;
  countA INTEGER;

BEGIN

  SELECT COUNT(*) INTO countDA FROM DungeonsAsDB.Passaggio WHERE stanza_DA = NEW.stanza_DA AND Tipo_passaggio = 'nascosto' AND Personaggio = NEW.Personaggio;
  SELECT COUNT(*) INTO countA FROM DungeonsAsDB.Passaggio WHERE stanza_A = NEW.stanza_A AND Tipo_passaggio = 'nascosto' AND Passaggio.Personaggio = NEW.Personaggio;

  IF ((countDA >= 2) OR (countA >= 2)) THEN

    RETURN NULL; -- non inserisce la tupla

  ELSE

    RETURN NEW;

  END IF;

END;
$$;


ALTER FUNCTION dungeonsasdb.massimo2passaggisegreti() OWNER TO andreiciulpan;

--
-- Name: massimo3oggetti(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION massimo3oggetti() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  count INTEGER;

BEGIN

  SELECT COUNT(*) INTO count FROM DungeonsAsDB.randomoggetto WHERE RandomOggetto.Stanza_O = NEW.stanza_o AND Personaggio = NEW.Personaggio;

  IF count >= 3

    THEN

      RETURN NULL; -- non inserisce la tupla

    ELSE

      RETURN NEW;

    END IF;

END;
$$;


ALTER FUNCTION dungeonsasdb.massimo3oggetti() OWNER TO andreiciulpan;

--
-- Name: mortenemico(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION mortenemico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  pf DungeonsAsDb.Nemico.PF_N%TYPE;
  danno DungeonsAsDB.Nemico.danno_n%TYPE;


BEGIN

  SELECT RandomNemico.pf_n, Nemico.danno_n INTO pf, danno FROM DungeonsAsDB.RandomNemico LEFT OUTER JOIN DungeonsAsDB.Nemico ON RandomNemico.Nome_N = Nemico.Nome_N WHERE RandomNemico.nome_n = NEW.Nome_N AND Personaggio = NEW.Personaggio;

  IF (pf <= 0) THEN

    DELETE FROM DungeonsAsDB.RandomNemico WHERE nome_n = NEW.Nome_N AND Personaggio = NEW.Personaggio;
    UPDATE informazioniGioco SET defeated = defeated + 1 WHERE Personaggio = NEW.Personaggio;
    UPDATE informazioniGioco SET danno_N_defeated = danno_N_defeated + danno WHERE Personaggio = NEW.Personaggio;

  END IF;

  RETURN NEW;

END;
$$;


ALTER FUNCTION dungeonsasdb.mortenemico() OWNER TO andreiciulpan;

--
-- Name: prendioggetto(character varying, character varying); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION prendioggetto(character varying, character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  nomePG ALIAS FOR $1;
  nomeOGG ALIAS FOR $2;

BEGIN

  INSERT INTO Possiede VALUES (nomePG, nomeOGG);
  DELETE FROM RandomOggetto WHERE Nome_ogg = nomeOGG AND Personaggio = nomePG;


END;
$_$;


ALTER FUNCTION dungeonsasdb.prendioggetto(character varying, character varying) OWNER TO andreiciulpan;

--
-- Name: tredasei(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION tredasei() RETURNS SETOF lancidadi
    LANGUAGE plpgsql
    AS $$

DECLARE

  dado  INTEGER;
  count INTEGER;
  tupla lanciDadi;



BEGIN


  count := 1;
  WHILE count < 6
  LOOP

    SELECT *
    INTO dado
    FROM diceRoll(3, 6);
    tupla.tiro := count;
    tupla.valore := dado;
    count := count + 1;
    RETURN NEXT tupla;

  END LOOP;



END;

$$;


ALTER FUNCTION dungeonsasdb.tredasei() OWNER TO andreiciulpan;

--
-- Name: ultimaarma(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION ultimaarma() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  countARMI INTEGER;


BEGIN


  SELECT COUNT(*) INTO countARMI FROM DungeonsAsDB.Possiede INNER JOIN DungeonsAsDB.Oggetto ON Oggetto = Oggetto.Nome_ogg WHERE Personaggio = OLD.Personaggio AND Tipo_ogg = 'arma';

  IF (countARMI = 0) THEN -- se l'oggetto cancellato è l'ultima arma che il personaggio possiede

    RAISE EXCEPTION 'Non puoi cancellare l''ultima arma';

  END IF;
  
  RETURN OLD;


END;
$$;


ALTER FUNCTION dungeonsasdb.ultimaarma() OWNER TO andreiciulpan;

--
-- Name: updateinformazionigioco(); Type: FUNCTION; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE FUNCTION updateinformazionigioco() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  stanzeVisitate INTEGER;

BEGIN


  WITH stanzeUniche AS (
    SELECT DISTINCT stanza_da FROM DungeonsAsDB.Passaggio WHERE visitedStanza_DA = true AND Personaggio = NEW.Personaggio )
  SELECT COUNT(*) INTO stanzeVisitate FROM stanzeUniche;

  UPDATE informazioniGioco SET visited = stanzeVisitate WHERE Personaggio = NEW.Personaggio;
  RETURN NEW;

END;
$$;


ALTER FUNCTION dungeonsasdb.updateinformazionigioco() OWNER TO andreiciulpan;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: equipaggia; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE equipaggia (
    personaggio character varying(12) NOT NULL,
    oggetto character varying(20) NOT NULL
);


ALTER TABLE equipaggia OWNER TO andreiciulpan;

--
-- Name: informazionigioco; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE informazionigioco (
    personaggio character varying(12) NOT NULL,
    visited integer DEFAULT 0 NOT NULL,
    defeated integer DEFAULT 0 NOT NULL,
    danno_n_defeated integer DEFAULT 0 NOT NULL
);


ALTER TABLE informazionigioco OWNER TO andreiciulpan;

--
-- Name: nemico; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE nemico (
    nome_n character varying(12) NOT NULL,
    descrizione_n character varying(250),
    att_n integer NOT NULL,
    dif_n integer NOT NULL,
    pf_n integer NOT NULL,
    danno_n integer NOT NULL
);


ALTER TABLE nemico OWNER TO andreiciulpan;

--
-- Name: oggetto; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE oggetto (
    nome_ogg character varying(20) NOT NULL,
    tipo_ogg tipi_oggetti NOT NULL,
    att_bonus integer DEFAULT 0 NOT NULL,
    dif_bonus integer DEFAULT 0 NOT NULL,
    per_bonus integer DEFAULT 0 NOT NULL,
    pf_bonus integer DEFAULT 0 NOT NULL,
    danno_inflitto integer,
    CONSTRAINT oggetto_att_bonus_check CHECK (((att_bonus >= '-6'::integer) AND (att_bonus <= 6))),
    CONSTRAINT oggetto_dif_bonus_check CHECK (((dif_bonus >= '-6'::integer) AND (dif_bonus <= 6))),
    CONSTRAINT oggetto_per_bonus_check CHECK (((per_bonus >= '-6'::integer) AND (per_bonus <= 6))),
    CONSTRAINT oggetto_pf_bonus_check CHECK (((pf_bonus >= '-6'::integer) AND (pf_bonus <= 6)))
);


ALTER TABLE oggetto OWNER TO andreiciulpan;

--
-- Name: passaggio; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE passaggio (
    stanza_da integer NOT NULL,
    stanza_a integer NOT NULL,
    tipo_passaggio tipi_di_visibilita NOT NULL,
    visitedstanza_da boolean DEFAULT false NOT NULL,
    personaggio character varying(12) NOT NULL
);


ALTER TABLE passaggio OWNER TO andreiciulpan;

--
-- Name: personaggio; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE personaggio (
    nome_pg character varying(12) NOT NULL,
    descrizione_pg character varying(50),
    arma_eq character varying(20),
    armatura_eq character varying(20),
    "FOR" double precision DEFAULT 0 NOT NULL,
    "int" double precision DEFAULT 0 NOT NULL,
    agi double precision DEFAULT 0 NOT NULL,
    cost double precision DEFAULT 0 NOT NULL,
    att integer DEFAULT 0 NOT NULL,
    dif integer DEFAULT 0 NOT NULL,
    per integer DEFAULT 0 NOT NULL,
    pf integer DEFAULT 0 NOT NULL,
    pe integer DEFAULT 0 NOT NULL,
    numero_ogg integer DEFAULT 0,
    utente_id integer NOT NULL,
    stanza_pg integer DEFAULT 1 NOT NULL
);


ALTER TABLE personaggio OWNER TO andreiciulpan;

--
-- Name: possiede; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE possiede (
    personaggio character varying(12) NOT NULL,
    oggetto character varying(20) NOT NULL
);


ALTER TABLE possiede OWNER TO andreiciulpan;

--
-- Name: randomnemico; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE randomnemico (
    nome_n character varying(20) NOT NULL,
    pf_n integer NOT NULL,
    stanza_n integer NOT NULL,
    personaggio character varying(12) NOT NULL,
    dif_n integer NOT NULL
);


ALTER TABLE randomnemico OWNER TO andreiciulpan;

--
-- Name: randomoggetto; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE randomoggetto (
    nome_ogg character varying(20) NOT NULL,
    visibilita_ogg tipi_di_visibilita NOT NULL,
    stanza_o integer NOT NULL,
    personaggio character varying(12) NOT NULL
);


ALTER TABLE randomoggetto OWNER TO andreiciulpan;

--
-- Name: stanza; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE stanza (
    stanza_id integer NOT NULL,
    nr_ogg integer DEFAULT 0 NOT NULL,
    nr_nem integer DEFAULT 0 NOT NULL,
    nr_pass integer DEFAULT 0 NOT NULL,
    tipo character varying(8)
);


ALTER TABLE stanza OWNER TO andreiciulpan;

--
-- Name: stanza_stanza_id_seq; Type: SEQUENCE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE SEQUENCE stanza_stanza_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stanza_stanza_id_seq OWNER TO andreiciulpan;

--
-- Name: stanza_stanza_id_seq; Type: SEQUENCE OWNED BY; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER SEQUENCE stanza_stanza_id_seq OWNED BY stanza.stanza_id;


--
-- Name: utente; Type: TABLE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TABLE utente (
    utente_id integer NOT NULL,
    nome_utente character varying(20),
    password character varying(50) NOT NULL,
    e_mail character varying(40) NOT NULL,
    data_creazione date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE utente OWNER TO andreiciulpan;

--
-- Name: utente_id_seq; Type: SEQUENCE; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE SEQUENCE utente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE utente_id_seq OWNER TO andreiciulpan;

--
-- Name: utente_id_seq; Type: SEQUENCE OWNED BY; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER SEQUENCE utente_id_seq OWNED BY utente.utente_id;


--
-- Name: stanza stanza_id; Type: DEFAULT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY stanza ALTER COLUMN stanza_id SET DEFAULT nextval('stanza_stanza_id_seq'::regclass);


--
-- Name: utente utente_id; Type: DEFAULT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY utente ALTER COLUMN utente_id SET DEFAULT nextval('utente_id_seq'::regclass);


--
-- Data for Name: equipaggia; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--



--
-- Data for Name: informazionigioco; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO informazionigioco (personaggio, visited, defeated, danno_n_defeated) VALUES ('Jolsty', 0, 0, 0);
INSERT INTO informazionigioco (personaggio, visited, defeated, danno_n_defeated) VALUES ('2131', 0, 0, 0);
INSERT INTO informazionigioco (personaggio, visited, defeated, danno_n_defeated) VALUES ('123', 0, 0, 0);


--
-- Data for Name: nemico; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Cassiopeia', 'Cassiopeia è una creatura terrificante: è metà donna, metà serpente e il suo sguardo uccide. ', 21, 6, 6, 1);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Aurelion Sol', 'Un tempo Aurelion Sol omaggiò il grande vuoto del cosmo con meraviglie celestiali da lui stesso ideate.', 20, 5, 8, 1);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Karma', 'Karma è una donna dalla volontà di ferro, con un potere spirituale senza confini. ', 16, 9, 4, 2);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Aatrox', 'Aatrox è un guerriero leggendario, uno dei cinque sopravvissuti dell''antica razza dei Darkin.', 15, 7, 5, 2);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Syndra', 'Nata con immensi poteri magici, Syndra ama esercitare l''incredibile potere in suo possesso.', 11, 12, 2, 4);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Zed', 'Zed è il primo ninja in 200 anni a padroneggiare le antiche e proibite vie. Sfidando il suo stesso maestro e il suo stesso clan, gettò via la disciplina e l''equilibrio che lo avevano incatenato per tutta la vita.', 11, 12, 2, 4);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Elise', 'Anche la bellezza è potere. A volte può colpire più velocemente di una spada.', 15, 7, 5, 2);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Ashe', 'Ogni freccia scoccata dal suo antico arco incantato dai ghiacci dimostra che Ashe è maestra nell''arte dell''arco.', 17, 13, 2, 2);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Ekko', 'Ekko è un prodigio che viene dalle pericolose strade di Zaun, in grado di manipolare il tempo per portare qualsiasi situazione a suo vantaggio.', 16, 9, 4, 2);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Vayne', 'Il mondo è un luogo meno civile di quanto si possa pensare. C''è ancora chi decide di seguire i più oscuri sentieri della magia, lasciandosi corrompere dai malefici poteri di Runeterra. Shauna Vayne lo sa bene.', 15, 12, 2, 3);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Draven', 'A differenza di suo fratello Darius, Draven non si è mai accontentato della vittoria in battaglia. Desiderava fama, riconoscimenti, gloria.', 17, 12, 3, 2);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Ezreal', 'L''intrepido e giovane avventuriero Ezreal ha esplorato alcuni dei luoghi più remoti e abbandonati di Runeterra.', 14, 12, 3, 3);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Jhin', 'Jhin è un criminale psicopatico e meticoloso che vede la morte come un''opera d''arte.', 10, 11, 3, 4);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Ahri', 'A differenza delle altre volpi dei boschi di Ionia, Ahri, da tempi immemorabili, percepiva una strana connessione con il mondo magico che la circondava: una connessione incompleta.', 13, 8, 4, 3);
INSERT INTO nemico (nome_n, descrizione_n, att_n, dif_n, pf_n, danno_n) VALUES ('Azir', 'Azir cammina sulla Via dell''Imperatore, lastricata d''oro. Le immense statue degli antichi sovrani di Shurima, i suoi antenati, lo guardano mentre avanza', 22, 10, 4, 1);


--
-- Data for Name: oggetto; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pendente Affamato', 'gioiello', 3, -1, 3, 0, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada dei Fortunati', 'arma', -6, -2, 0, 0, 8);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada Maledetta', 'arma', 6, 0, 0, 0, 2);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada Base', 'arma', 2, 1, 0, 0, 2);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada di Guforeale', 'arma', 2, 0, 2, 0, 3);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Collana di Oro', 'gioiello', 2, 1, 0, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Anello Ripilante', 'gioiello', 4, 0, 0, 0, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Salsiccia Affumicata', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Focacciona', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Anello di Nida', 'gioiello', -2, 1, 2, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Burrito', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Amuleto Secolare', 'gioiello', -2, 1, 3, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pane', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Biscotto', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Noci', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pizza', 'razione', 0, 0, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Amuleto di Cicloide', 'gioiello', 3, -1, 3, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo di Argento', 'armatura', 1, 3, 0, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pozione Formaggiante', 'pozione', 5, 3, 0, 0, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pozione Stellata', 'pozione', 6, -1, -2, 0, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Bottiglia di Fanta', 'pozione', 1, 2, 6, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pozione Resistenza', 'pozione', -2, 6, 0, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pozione di Donzella', 'pozione', 1, 4, 2, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Pozione Geniale', 'pozione', 3, 2, 2, 0, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada Micotica', 'arma', -2, 4, 0, 0, 3);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada Lunga', 'arma', 4, 0, 0, 0, 3);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada Corta', 'arma', 4, 0, 2, 0, 2);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo di Spugna', 'armatura', -2, 4, 2, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo Maiale', 'armatura', 2, 3, 2, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo Ventaglio', 'armatura', 0, 3, -1, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo Solare', 'armatura', -3, 5, -2, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo di Legno', 'armatura', 2, 2, -2, 2, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Anello del Restler', 'gioiello', 2, 1, 0, 1, NULL);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Spada Paura', 'arma', 4, -4, 0, 0, 4);
INSERT INTO oggetto (nome_ogg, tipo_ogg, att_bonus, dif_bonus, per_bonus, pf_bonus, danno_inflitto) VALUES ('Scudo Lunare', 'armatura', -2, 4, -1, 2, NULL);


--
-- Data for Name: passaggio; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (1, 13, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (13, 8, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (8, 5, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (5, 4, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (4, 3, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (3, 14, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (14, 2, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (2, 11, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (11, 6, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (6, 9, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (9, 7, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (7, 10, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (10, 12, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (12, 15, 'visibile', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (1, 2, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (7, 5, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (13, 14, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (5, 14, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (2, 13, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (14, 9, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (7, 13, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (5, 11, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (13, 4, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (14, 5, 'nascosto', false, 'Jolsty');
INSERT INTO passaggio (stanza_da, stanza_a, tipo_passaggio, visitedstanza_da, personaggio) VALUES (1, 9, 'nascosto', false, 'Jolsty');


--
-- Data for Name: personaggio; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO personaggio (nome_pg, descrizione_pg, arma_eq, armatura_eq, "FOR", "int", agi, cost, att, dif, per, pf, pe, numero_ogg, utente_id, stanza_pg) VALUES ('Jolsty', NULL, NULL, NULL, 11, 8, 9, 10, 10, 10, 8, 10, 0, 2, 1, 1);
INSERT INTO personaggio (nome_pg, descrizione_pg, arma_eq, armatura_eq, "FOR", "int", agi, cost, att, dif, per, pf, pe, numero_ogg, utente_id, stanza_pg) VALUES ('2131', NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO personaggio (nome_pg, descrizione_pg, arma_eq, armatura_eq, "FOR", "int", agi, cost, att, dif, per, pf, pe, numero_ogg, utente_id, stanza_pg) VALUES ('123', NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1);


--
-- Data for Name: possiede; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO possiede (personaggio, oggetto) VALUES ('Jolsty', 'Spada Base');
INSERT INTO possiede (personaggio, oggetto) VALUES ('Jolsty', 'Pane');


--
-- Data for Name: randomnemico; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Cassiopeia', 6, 7, 'Jolsty', 6);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Aurelion Sol', 8, 14, 'Jolsty', 5);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Karma', 4, 12, 'Jolsty', 9);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Aatrox', 5, 2, 'Jolsty', 7);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Syndra', 2, 6, 'Jolsty', 12);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Zed', 2, 6, 'Jolsty', 12);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Elise', 5, 2, 'Jolsty', 7);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Ekko', 4, 12, 'Jolsty', 9);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Vayne', 2, 9, 'Jolsty', 12);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Draven', 3, 11, 'Jolsty', 12);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Ezreal', 3, 7, 'Jolsty', 12);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Jhin', 3, 10, 'Jolsty', 11);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Ahri', 4, 11, 'Jolsty', 8);
INSERT INTO randomnemico (nome_n, pf_n, stanza_n, personaggio, dif_n) VALUES ('Azir', 4, 10, 'Jolsty', 10);


--
-- Data for Name: randomoggetto; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Pendente Affamato', 'visibile', 3, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Spada dei Fortunati', 'nascosto', 8, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Spada Maledetta', 'nascosto', 13, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Spada di Guforeale', 'nascosto', 2, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Collana di Oro', 'nascosto', 14, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Anello Ripilante', 'visibile', 11, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Anello di Nida', 'visibile', 9, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Amuleto Secolare', 'visibile', 5, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Amuleto di Cicloide', 'nascosto', 13, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Scudo di Argento', 'nascosto', 7, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Pozione Formaggiante', 'nascosto', 9, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Bottiglia di Fanta', 'visibile', 5, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Pozione di Donzella', 'visibile', 8, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Pozione Geniale', 'visibile', 2, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Spada Lunga', 'visibile', 7, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Spada Corta', 'visibile', 2, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Scudo di Spugna', 'nascosto', 9, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Scudo Maiale', 'nascosto', 4, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Scudo di Legno', 'visibile', 3, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Spada Paura', 'nascosto', 6, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Scudo Lunare', 'visibile', 10, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Salsiccia Affumicata', 'visibile', 5, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Focacciona', 'visibile', 12, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Burrito', 'visibile', 13, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Biscotto', 'visibile', 11, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Noci', 'visibile', 12, 'Jolsty');
INSERT INTO randomoggetto (nome_ogg, visibilita_ogg, stanza_o, personaggio) VALUES ('Pizza', 'visibile', 4, 'Jolsty');


--
-- Data for Name: stanza; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (15, 0, 0, 0, 'finale');
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (8, 2, 0, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (4, 2, 0, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (3, 2, 0, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (11, 2, 2, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (6, 1, 2, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (9, 3, 1, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (10, 1, 2, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (12, 2, 2, 1, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (2, 3, 2, 2, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (7, 2, 2, 3, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (5, 3, 0, 3, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (13, 3, 0, 3, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (14, 1, 1, 3, NULL);
INSERT INTO stanza (stanza_id, nr_ogg, nr_nem, nr_pass, tipo) VALUES (1, 0, 0, 3, 'iniziale');


--
-- Name: stanza_stanza_id_seq; Type: SEQUENCE SET; Schema: dungeonsasdb; Owner: andreiciulpan
--

SELECT pg_catalog.setval('stanza_stanza_id_seq', 16, false);


--
-- Data for Name: utente; Type: TABLE DATA; Schema: dungeonsasdb; Owner: andreiciulpan
--

INSERT INTO utente (utente_id, nome_utente, password, e_mail, data_creazione) VALUES (1, 'jolsty', '1c9aabe56f2ee92a71ee09bf28b5d266', 'andi_ciulpan@yahoo.com', '2017-01-19');


--
-- Name: utente_id_seq; Type: SEQUENCE SET; Schema: dungeonsasdb; Owner: andreiciulpan
--

SELECT pg_catalog.setval('utente_id_seq', 1, true);


--
-- Name: equipaggia equipaggia_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY equipaggia
    ADD CONSTRAINT equipaggia_pkey PRIMARY KEY (personaggio, oggetto);


--
-- Name: informazionigioco informazionigioco_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY informazionigioco
    ADD CONSTRAINT informazionigioco_pkey PRIMARY KEY (personaggio);


--
-- Name: nemico nemico_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY nemico
    ADD CONSTRAINT nemico_pkey PRIMARY KEY (nome_n);


--
-- Name: oggetto oggetto_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY oggetto
    ADD CONSTRAINT oggetto_pkey PRIMARY KEY (nome_ogg);


--
-- Name: passaggio passaggio_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY passaggio
    ADD CONSTRAINT passaggio_pkey PRIMARY KEY (stanza_da, stanza_a, personaggio);


--
-- Name: personaggio personaggio_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY personaggio
    ADD CONSTRAINT personaggio_pkey PRIMARY KEY (nome_pg);


--
-- Name: possiede possiede_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY possiede
    ADD CONSTRAINT possiede_pkey PRIMARY KEY (personaggio, oggetto);


--
-- Name: randomnemico randomnemico_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomnemico
    ADD CONSTRAINT randomnemico_pkey PRIMARY KEY (nome_n, personaggio);


--
-- Name: randomoggetto randomoggetto_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomoggetto
    ADD CONSTRAINT randomoggetto_pkey PRIMARY KEY (nome_ogg, personaggio);


--
-- Name: stanza stanza_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY stanza
    ADD CONSTRAINT stanza_pkey PRIMARY KEY (stanza_id);


--
-- Name: utente utente_nome_utente_key; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY utente
    ADD CONSTRAINT utente_nome_utente_key UNIQUE (nome_utente);


--
-- Name: utente utente_pkey; Type: CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY utente
    ADD CONSTRAINT utente_pkey PRIMARY KEY (utente_id);


--
-- Name: randomnemico aggiornastanzanemici_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER aggiornastanzanemici_trigger AFTER INSERT OR DELETE ON randomnemico FOR EACH ROW EXECUTE PROCEDURE aggiornastanzanemici();


--
-- Name: randomoggetto aggiornastanzaoggetti_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER aggiornastanzaoggetti_trigger AFTER INSERT OR DELETE ON randomoggetto FOR EACH ROW EXECUTE PROCEDURE aggiornastanzaoggetti();


--
-- Name: passaggio aggiornastanzapassaggi_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER aggiornastanzapassaggi_trigger AFTER INSERT OR DELETE ON passaggio FOR EACH ROW EXECUTE PROCEDURE aggiornastanzapassaggi();


--
-- Name: randomnemico balancenemici_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER balancenemici_trigger AFTER INSERT ON randomnemico FOR EACH ROW EXECUTE PROCEDURE balancenemici();


--
-- Name: personaggio cambiastanza_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER cambiastanza_trigger AFTER UPDATE OF stanza_pg ON personaggio FOR EACH ROW EXECUTE PROCEDURE cambiastanza();


--
-- Name: equipaggia delbonusoggetti_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER delbonusoggetti_trigger BEFORE DELETE ON equipaggia FOR EACH ROW EXECUTE PROCEDURE delbonusoggetti();


--
-- Name: equipaggia gestioneequipaggia_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER gestioneequipaggia_trigger AFTER INSERT OR UPDATE ON equipaggia FOR EACH ROW EXECUTE PROCEDURE gestioneequipaggia();


--
-- Name: possiede gestioneinventario_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER gestioneinventario_trigger AFTER INSERT OR DELETE OR UPDATE ON possiede FOR EACH ROW EXECUTE PROCEDURE gestioneinventario();


--
-- Name: randomnemico massimo2nemici_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER massimo2nemici_trigger BEFORE INSERT ON randomnemico FOR EACH ROW EXECUTE PROCEDURE massimo2nemici();


--
-- Name: passaggio massimo2passaggisegreti_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER massimo2passaggisegreti_trigger BEFORE INSERT ON passaggio FOR EACH ROW EXECUTE PROCEDURE massimo2passaggisegreti();


--
-- Name: randomoggetto massimo3oggetti_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER massimo3oggetti_trigger BEFORE INSERT ON randomoggetto FOR EACH ROW EXECUTE PROCEDURE massimo3oggetti();


--
-- Name: randomnemico mortenemico_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER mortenemico_trigger AFTER UPDATE OF pf_n ON randomnemico FOR EACH ROW EXECUTE PROCEDURE mortenemico();


--
-- Name: possiede ultimaarma_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER ultimaarma_trigger AFTER DELETE ON possiede FOR EACH ROW EXECUTE PROCEDURE ultimaarma();


--
-- Name: passaggio updateinformazionigioco_trigger; Type: TRIGGER; Schema: dungeonsasdb; Owner: andreiciulpan
--

CREATE TRIGGER updateinformazionigioco_trigger AFTER UPDATE OF visitedstanza_da ON passaggio FOR EACH ROW EXECUTE PROCEDURE updateinformazionigioco();


--
-- Name: equipaggia equipaggia_oggetto_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY equipaggia
    ADD CONSTRAINT equipaggia_oggetto_fkey FOREIGN KEY (oggetto) REFERENCES oggetto(nome_ogg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipaggia equipaggia_personaggio_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY equipaggia
    ADD CONSTRAINT equipaggia_personaggio_fkey FOREIGN KEY (personaggio) REFERENCES personaggio(nome_pg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: informazionigioco informazionigioco_personaggio_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY informazionigioco
    ADD CONSTRAINT informazionigioco_personaggio_fkey FOREIGN KEY (personaggio) REFERENCES personaggio(nome_pg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: passaggio passaggio_personaggio_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY passaggio
    ADD CONSTRAINT passaggio_personaggio_fkey FOREIGN KEY (personaggio) REFERENCES personaggio(nome_pg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: passaggio passaggio_stanza_a_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY passaggio
    ADD CONSTRAINT passaggio_stanza_a_fkey FOREIGN KEY (stanza_a) REFERENCES stanza(stanza_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: passaggio passaggio_stanza_da_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY passaggio
    ADD CONSTRAINT passaggio_stanza_da_fkey FOREIGN KEY (stanza_da) REFERENCES stanza(stanza_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: personaggio personaggio_arma_eq_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY personaggio
    ADD CONSTRAINT personaggio_arma_eq_fkey FOREIGN KEY (arma_eq) REFERENCES oggetto(nome_ogg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: personaggio personaggio_armatura_eq_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY personaggio
    ADD CONSTRAINT personaggio_armatura_eq_fkey FOREIGN KEY (armatura_eq) REFERENCES oggetto(nome_ogg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: personaggio personaggio_stanza_pg_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY personaggio
    ADD CONSTRAINT personaggio_stanza_pg_fkey FOREIGN KEY (stanza_pg) REFERENCES stanza(stanza_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: personaggio personaggio_utente_id_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY personaggio
    ADD CONSTRAINT personaggio_utente_id_fkey FOREIGN KEY (utente_id) REFERENCES utente(utente_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: possiede possiede_oggetto_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY possiede
    ADD CONSTRAINT possiede_oggetto_fkey FOREIGN KEY (oggetto) REFERENCES oggetto(nome_ogg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: possiede possiede_personaggio_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY possiede
    ADD CONSTRAINT possiede_personaggio_fkey FOREIGN KEY (personaggio) REFERENCES personaggio(nome_pg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: randomnemico randomnemico_nemico_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomnemico
    ADD CONSTRAINT randomnemico_nemico_fkey FOREIGN KEY (nome_n) REFERENCES nemico(nome_n) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: randomnemico randomnemico_personaggio_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomnemico
    ADD CONSTRAINT randomnemico_personaggio_fkey FOREIGN KEY (personaggio) REFERENCES personaggio(nome_pg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: randomnemico randomnemico_stanza_n_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomnemico
    ADD CONSTRAINT randomnemico_stanza_n_fkey FOREIGN KEY (stanza_n) REFERENCES stanza(stanza_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: randomoggetto randomoggetto_nome_ogg_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomoggetto
    ADD CONSTRAINT randomoggetto_nome_ogg_fkey FOREIGN KEY (nome_ogg) REFERENCES oggetto(nome_ogg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: randomoggetto randomoggetto_personaggio_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomoggetto
    ADD CONSTRAINT randomoggetto_personaggio_fkey FOREIGN KEY (personaggio) REFERENCES personaggio(nome_pg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: randomoggetto randomoggetto_stanza_o_fkey; Type: FK CONSTRAINT; Schema: dungeonsasdb; Owner: andreiciulpan
--

ALTER TABLE ONLY randomoggetto
    ADD CONSTRAINT randomoggetto_stanza_o_fkey FOREIGN KEY (stanza_o) REFERENCES stanza(stanza_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

