<?php

namespace Actions;
include_once "Request.php";

class CompleteCheckout extends Request
{
    public function __construct($cookieVal)
    {
        $this->cookie = new Cookie(NULL, NULL, $cookieVal);
    }

    public $statement = "delete from \"cart\" where userid=\"GetUserID\"(:cookie)";

    public function GetQueryData(): array
    {
        return array(
            ":cookie" => $this->cookie->hash
        );
    }
}