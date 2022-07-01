<?php

namespace Actions;
include_once "AuthSecrets.php";

class Password
{
    public $hash = "";

    public function __construct($email, $passwordRaw)
    {
        $this->hash = hash('sha256', "$email+$passwordRaw".PasswordsSalt);
    }
}