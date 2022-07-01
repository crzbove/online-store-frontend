<?php

namespace Actions;

include_once "Request.php";

class SendInvoice extends Request
{
    public bool $specificJob = true;

    public function __construct($cookieVal)
    {
        $this->cookie = new Cookie(NULL, NULL, $cookieVal);
    }

    public $statement = "SELECT * FROM public.cart_view WHERE \"userid\" = \"GetUserID\"(:cookie)";

    public function GetQueryData(): array
    {
        return array(
            ":cookie" => $this->cookie->hash
        );
    }

    public function DoSpecificJob($params)
    {
        \Mail::Send($params);
    }
}