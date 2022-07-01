<?php
namespace Actions;

include_once "Request.php";

class GetCategories extends Request
{
    public $statement = "SELECT * FROM \"category\"";
    public function GetQueryData(): array
    {
        return array();
    }
}