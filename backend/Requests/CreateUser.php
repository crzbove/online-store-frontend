<?php

namespace Actions;

use Exception;

include_once "Request.php";

class CreateUser extends Request
{
    public function __construct($email, $password)
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception("invalid email");
        }

        $this->email = $email;
        $this->password = new Password($email, $password);
        $this->cookie = new Cookie($email, $this->password->hash);
    }

    public $email = "";
    public $createCookie = true;

    public function GetQueryData(): array
    {
        return array(
            ":email" => $this->email,
            ":passwordHash" => $this->password->hash,
            ":cookie" => $this->cookie->hash
        );
    }

    //public $statement = "INSERT INTO \"user\"(email, passwordhash, cookie) VALUES (:email, :passwordHash, :cookie)";
    public $statement = "select * from \"CreateUser\"(:email, :passwordHash, :cookie)";
}
