<?php

namespace Actions;

include_once "Request.php";
include_once "Consts.php";

class GetProducts extends Request
{
    private $categoryid;
    private $offset;
    private $limit;
    private $orderby;

    private $data;

    public function __construct($offset = 0, $limit = 25, $orderby = 2, $categoryid = AllCategories)
    {
        $this->categoryid = $categoryid;
        $this->offset = $offset;
        $this->limit = $limit;
        $this->orderby = $orderby;

        $this->data;

        if ($this->categoryid == AllCategories) {
            $this->statement = "SELECT * FROM \"product\" ORDER BY :orderby ASC LIMIT :limit OFFSET :offset";

            $this->data = array(
                ":orderby" => $this->orderby,
                ":limit" => $this->limit,
                ":offset" => $this->offset
            );
        } else {
            $this->statement = "SELECT * FROM product where categoryid=:category ORDER BY :orderby ASC LIMIT :limit OFFSET :offset";

            $this->data = array(
                ":orderby" => $this->orderby,
                ":limit" => $this->limit,
                ":offset" => $this->offset,
                ":category" => $this->categoryid
            );
        }
    }

    public function GetQueryData(): array
    {
        return $this->data;
    }
}