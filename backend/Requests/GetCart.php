<?php

namespace Actions;

include_once "Request.php";

class GetCart extends Request
{
    public function __construct($cookieVal)
    {
        $this->cookie = new Cookie(NULL, NULL, $cookieVal);
    }

    public $statement = "select * from \"cart_view\" where userid=\"GetUserID\"(:cookie) ORDER by \"name\" ASC;";

    public function GetQueryData(): array
    {
        return array(
            ":cookie" => $this->cookie->hash
        );
    }
}