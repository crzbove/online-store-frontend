<?php

include_once "dbconfig.php";

class DatabaseWorker
{
    private static function Connect()
    {
        $host = host;
        $username = username;
        $password = password;
        $database = database;

        $dsn = "pgsql:host=$host;port=5432;dbname=$database;user=$username;password=$password";

        try {
            //$c = new PDO("mysql:host=$host;dbname=$database", $username, $password);
            $c = new PDO($dsn);
        } catch (PDOException $pe) {
            echo $pe->getMessage();
            $c = null;
        }

        return $c;
    }

    static function DatabaseQueryHandle($statement, $data)
    {
        try {
            $d = self::Connect();
            $st = $d->prepare($statement);
            $st->execute($data);

            return $st->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return $e->getMessage();
        }
    }
}