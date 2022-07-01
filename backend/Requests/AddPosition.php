<?php

namespace Actions;
include_once "Request.php";

class AddPosition extends Request
{
    public $productid;
    public $count;

    public function __construct($productid, $count, $cookieval)
    {
        $this->productid = $productid;
        $this->count = $count;
        $this->cookie = new Cookie(NULL, NULL, $cookieval);
    }

//    public $queryTemplate = "SELECT user.userid INTO @uid FROM user WHERE user.cookie = ':cookie';".
//                            "SELECT product.cost INTO @c FROM product WHERE product.idproduct = :productid;".
//                            "INSERT INTO cart(userid, productid, count, total) VALUES (@uid, :productid, :count, @c*:count);";

    public $statement = "SELECT \"AddPosition\"(:productid, \"GetUserID\"(:cookie), :pcs)";

    public function GetQueryData(): array
    {
        return array(
            ":productid"=>$this->productid,
            ":pcs"=>$this->count,
            ":cookie"=>$this->cookie->hash
        );
    }
}