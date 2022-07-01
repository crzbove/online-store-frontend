<?php

namespace Actions;
include_once "Request.php";

//CREATE OR REPLACE FUNCTION public."AuthUser_Telegram"(
//    tid bigint,
//	pwd character varying,
//	q character varying)

class GetAuth_Telegram extends Request
{
    private $telegramid;
    public $createCookie = true;

    public function __construct($telegramid)
    {
        $this->cookie = new Cookie($telegramid, "telegram+" . $telegramid);
        $this->telegramid = $telegramid;
    }

    public $statement = "select \"AuthUser_Telegram\"(:tid, :pwd, :q)";

    public function GetQueryData(): array
    {
        return array(
            ":tid" => $this->telegramid,
            ":pwd" => "telegram+" . $this->telegramid,
            ":q" => $this->cookie->hash
        );
    }
}