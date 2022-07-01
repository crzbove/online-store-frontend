<?php

include_once "ActionTypes.php";
include_once "Requests/Request.php";
include_once "Requests/CreateUser.php";
include_once "Requests/GetAuth.php";
include_once "Requests/AddPosition.php";
include_once "Requests/UpdatePosition.php";
include_once "Requests/DeletePosition.php";
include_once "Requests/GetCategories.php";
include_once "Requests/GetProducts.php";
include_once "Requests/GetCart.php";
include_once "Requests/SendInvoice.php";
include_once "Requests/GetShortCart.php";
include_once "Requests/CompleteCheckout.php";
include_once "Requests/Logout.php";

include_once "Sender.php";

include_once "ActionTypes.php";
include_once "Mail/Mail.php";

class RequestData
{
    public static $directionKey = 'action';
    public static $email;
    public static $passwordRaw;
    public static $productid;
    public static $count;
    public static $cookieVal;
    public static $categoryid;
    public static $offset;
    public static $limit;
    public static $orderby;


    public static function Init($post, $cookies)
    {
        self::$email = self::CheckKey('email', $post);
        self::$passwordRaw = self::CheckKey('password', $post);
        self::$productid = self::CheckKey('productid', $post);
        self::$count = self::CheckKey('count', $post);
        self::$cookieVal = self::CheckKey('crocoshop', $cookies); // TODO вывести в const
        self::$categoryid = self::CheckKey('categoryid', $post);
        self::$offset = self::CheckKey('offset', $post);
        self::$limit = self::CheckKey('limit', $post);
        self::$orderby = self::CheckKey('orderby', $post);
    }

    private static function CheckKey($key, $arr)
    {
        return isset($arr[$key]) ? $arr[$key] : NULL;
    }
}

class Router
{
    private static $direction;

    public function __construct($post, $cookies)
    {
        RequestData::Init($post, $cookies);
        self::$direction = $post[RequestData::$directionKey];
    }

    private static function GetInstance()
    {
        switch (self::$direction) {
            case CREATEUSER:
                return new \Actions\CreateUser(RequestData::$email, RequestData::$passwordRaw);
            case GETAUTH:
                return new \Actions\GetAuth(RequestData::$email, RequestData::$passwordRaw, RequestData::$cookieVal);
            case "createandaddposition":
            case ADDPOSITION:
                return new \Actions\AddPosition(RequestData::$productid, RequestData::$count, RequestData::$cookieVal);
            case UPDATEPOSITION:
                return new \Actions\UpdatePosition(RequestData::$productid, RequestData::$count, RequestData::$cookieVal);
            case DELETEPOSITION:
                return new \Actions\DeletePosition(RequestData::$productid, RequestData::$cookieVal);
            case GETCATEGORIES:
                return new \Actions\GetCategories();
            case GETPRODUCTS:
                return new \Actions\GetProducts(RequestData::$offset, RequestData::$limit, RequestData::$orderby, RequestData::$categoryid);
            case GETCART:
                return new \Actions\GetCart(RequestData::$cookieVal);
            case GETCARTSHORT:
                return new \Actions\GetShortCart(RequestData::$cookieVal);
            case SENDINVOICE:
                $a = new \Actions\SendInvoice(RequestData::$cookieVal);
                return $a;
            case COMPLETECHECKOUT:
                return new \Actions\CompleteCheckout(RequestData::$cookieVal);
            case LOGOUT:
                return new \Actions\Logout(RequestData::$cookieVal);
            default:
                return new \Actions\Request();
        }
    }

    public function Handle()
    {
        return (new \Actions\Sender(self::GetInstance()))->ToJson();
    }
}
