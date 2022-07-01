<?php

namespace Actions;

use PHPMailer\PHPMailer\Exception;

include_once "Database/DatabaseWorker.php";
include_once "Requests/Request.php";

class Sender
{
    protected $answer;
    private $status = false;

    public function __construct(Request $r)
    {
        try {
            $this->answer = \DatabaseWorker::DatabaseQueryHandle($r->statement, $r->GetQueryData());
            $this->status = true;
        } catch (Exception $e) {
            $this->answer = $e->getCode();
            $this->status = false;
        }

        if ($r->createCookie && $this->ValidSize()) {
            $r->cookie->SetCookie();
        }

        if ($r->specificJob) {
            $r->DoSpecificJob($this->answer);
        }
    }

    public function ToJson()
    {
        $result = [
            "queryresult" => $this->answer,
            "status" => $this->status,
            "handler" => '🛸'
        ];

        return json_encode($result);
    }

    public function GetArray()
    {
        return $this->answer;
    }

    public function ValidSize()
    {
        return sizeof($this->answer) > 0;
    }
}
