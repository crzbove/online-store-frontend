function MakeRequest(data) {
    $.post("handler.php", JSON.stringify(data),
        function (data, textStatus, jqXHR) {
            $("#results").html(JSON.stringify(data));
        },
        "json"
    );
}

$("#createuser").click(function (e) {
    e.preventDefault();

    var arr = {};

    arr["action"] = "createuser";
    arr["email"] = `randomuser${Math.floor(Math.random() * 77777)}@croco.digital`;
    arr["password"] = "12345";

    MakeRequest(arr);
});


$("#createandaddposition").click(function (e) {
    e.preventDefault();

    var arr = {};

    arr["action"] = "createandaddposition";
    arr["productid"] = "1";
    arr["count"] = "7";
    arr["userid"] = "";

    MakeRequest(arr);
});
$("#deleteposition").click(function (e) {
    e.preventDefault();

    var arr = {};
    arr["action"] = "deleteposition";
    arr["positionid"] = 123;

    MakeRequest(arr);
});
$("#getcategories").click(function (e) {
    e.preventDefault();

    var arr = { "action": "getcategories" };
    MakeRequest(arr);
});
$("#getproducts").click(function (e) {
    e.preventDefault();

    // categoryid can be -1 if you wanna see everything.
    var arr = { "action": "getproducts", "limit": 15, "offset": 0, "categoryid": 1, "orderby": 2 };
    MakeRequest(arr);
});

$("#sendinvoice").click(function (e) {
    e.preventDefault();

    var arr = {};
    arr["action"] = "sendinvoice";

    MakeRequest(arr);
});

$("#getauth").click(function (e) {
    e.preventDefault();

    var arr = { "action": "getauth", "email": "admin1231111111123123123qwsad45@croco.digital", "password": "12345" }
    MakeRequest(arr);
});
$("#getauthcookie").click(function (e) { 
    e.preventDefault();
    
    var arr = {
        "action": "getauth"
    }
    MakeRequest(arr);
});

$("#getauthfail").click(function (e) {
    e.preventDefault();

    var arr = { "action": "getauth", "email": "fail@croco.digital", "password": "11111" }
    MakeRequest(arr);
});

$("#getcart").click(function (e) { 
    e.preventDefault();
    
    var arr = {
        "action": "getcart"
    }
    MakeRequest(arr);
});