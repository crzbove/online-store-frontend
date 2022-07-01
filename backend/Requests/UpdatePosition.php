<?php

namespace Actions;
include_once "Request.php";

class UpdatePosition extends Request
{
    public $productid;
    public $count;

    public function __construct($productid, $count, $cookieval)
    {
        $this->productid = $productid;
        $this->count = $count;
        $this->cookie = new Cookie(NULL, NULL, $cookieval);
    }

    // //{"text":"public.\"UpdatePosition\"(pid, uid, pcs)"
    public $statement = "SELECT \"UpdatePosition\"(:productid, \"GetUserID\"(:cookie), :pcs)";

    public function GetQueryData(): array
    {
        return array(
            ":productid"=>$this->productid,
            ":pcs"=>$this->count,
            ":cookie"=>$this->cookie->hash
        );
    }
}