<?php

namespace Actions;

include_once "Request.php";


class GetAuth extends Request
{
    public $email = "";

    public $createCookie = true;

    private $data;
    public $statement; 

    public function __construct($email = NULL, $password = NULL, $cookieVal = NULL)
    {
        if ($email != NULL && $password != NULL) {
            $this->password = new Password($email, $password);
            $this->cookie = new Cookie($email, $password);
            $this->email = $email;

            //$this->statement = "UPDATE \"user\" SET cookie = :cookie WHERE email = :email AND passwordhash = :passwordhash;";
            $this->statement = "select * from \"AuthUser\"(:email, :passwordhash, :cookie)";
            $this->data = array(
                ":email" => $this->email,
                ":passwordhash" => $this->password->hash,
                ":cookie" => $this->cookie->hash
            );
        }
        elseif ($email == NULL && $password == NULL && $cookieVal != NULL) {
            $this->cookie = new Cookie(NULL, NULL, $cookieVal);

            $this->statement = "SELECT \"email\" FROM \"user\" WHERE \"cookie\"=:cookie LIMIT 1";
            $this->data = array(
                ":cookie" => $this->cookie->hash
            );
        }
        else {
            $this->statement = "";
        }
    }

    public function GetQueryData(): array
    {
        return $this->data;
    }

    
}
