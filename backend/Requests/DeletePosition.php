<?php
namespace Actions;

include_once "Request.php";
class DeletePosition extends Request
{
    public $productid = "";

    public function __construct($productid, $cookieVal)
    {
        $this->productid = $productid;
        $this->cookie = new Cookie(NULL, NULL, $cookieVal);
    }

    public $statement = "DELETE FROM \"cart\" WHERE  userid=\"GetUserID\"(:cookie) AND productid=:productid";
    public function GetQueryData(): array
    {
        return array(
            ":cookie"=>$this->cookie->hash,
            ":productid"=>$this->productid
        );
    }
}