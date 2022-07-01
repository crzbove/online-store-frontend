<?php


namespace Actions;

include_once "Request.php";
class GetShortCart extends Request
{
    public function __construct($cookieVal)
    {
        $this->cookie = new Cookie(NULL, NULL, $cookieVal);
    }

    public $statement = "select * from \"GetShortCart\"(\"GetUserID\"(:cookie));";

    public function GetQueryData(): array
    {
        return array(
            ":cookie" => $this->cookie->hash
        );
    }
}