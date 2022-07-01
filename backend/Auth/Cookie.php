<?php

namespace Actions;
include_once "AuthSecrets.php";

class Cookie
{
    public $hash = "";

    public function __construct($email = NULL, $passwordHashed= NULL, $cookieVal = NULL)
    {
        if($email != NULL && $passwordHashed != NULL && $cookieVal == NULL){
            $this->hash = self::CalculateCookie($email, $passwordHashed);
        }
        elseif ($email == NULL && $passwordHashed == NULL && $cookieVal != NULL){
            $this->hash = $cookieVal;
        }
    }

    private function SetCookieVal($val){
        setcookie(CookieName, $val, [
            'expires' => time() + 3600 * 24 * 7,
            'path' => '/',
            'domain' => CookieDomain,
            'secure' => true,
            'httponly' => false,
            'samesite' => 'None'
        ]);
    }

    public function SetCookie(){
        $this->SetCookieVal($this->hash);
    }

    public function DeleteCookie(){
        $this->SetCookieVal("");
    }

    private function CalculateCookie($email, $passwordHashed) {
        return bin2hex(openssl_random_pseudo_bytes(64)); //hash('sha256', "$email $this->salt $passwordHashed");
    }
}