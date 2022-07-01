<?php
namespace Actions;
include_once "Request.php";

class Logout extends Request
{
    public function __construct($cookieVal)
    {
        $this->cookie = new Cookie(NULL, NULL, $cookieVal);
        $this->cookie->DeleteCookie();
    }

    public $statement = "update \"user\" set \"cookie\"=null where userid=\"GetUserID\"(:cookie)";

    public function GetQueryData(): array
    {
        return array(
            ":cookie" => $this->cookie->hash
        );
    }
}