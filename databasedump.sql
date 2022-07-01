--
-- TOC entry 217 (class 1255 OID 16386)
-- Name: AddPosition(bigint, bigint, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."AddPosition"(pid bigint, uid bigint, pcs integer) RETURNS void
    LANGUAGE plpgsql
    AS $$declare products_count bigint; -- products with the same id.
declare pcs_old integer; -- products old count;

BEGIN

select count(*) into products_count from "cart" where "userid" = uid and "productid" = pid;


if products_count = 0 then
    insert into "cart"("userid", "productid", "count", "total") 
    values (uid, pid, pcs, pcs*"GetProductCost"(pid));
else
    select "count" into pcs_old from "cart" where "userid" = uid and "productid" = pid;
    PERFORM "UpdatePosition"(pid, uid, pcs_old+pcs);
end if;

return;

END; 
$$;


--
-- TOC entry 218 (class 1255 OID 16387)
-- Name: AuthUser(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."AuthUser"(login character varying, pwd character varying, q character varying) RETURNS TABLE(email character varying)
    LANGUAGE plpgsql
    AS $$
begin
   UPDATE public.user AS u SET cookie = q WHERE u."email" = login AND u."passwordhash" = pwd;

   return query select u.email from public.user AS u WHERE u.email = login AND u.passwordhash = pwd AND u.cookie = q LIMIT 1;

end
$$;


--
-- TOC entry 226 (class 1255 OID 16444)
-- Name: AuthUser_Telegram(bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."AuthUser_Telegram"(tid bigint, pwd character varying, q character varying) RETURNS TABLE(tgid bigint)
    LANGUAGE plpgsql
    AS $$
declare users_count bigint;
begin


select count(*) into users_count 
from "user" as u where u.telegramid=tid and u.passwordhash=pwd;

if users_count = 0 then
-- 'регистрация' нового пользователя из телеграм
insert into "user"("passwordhash", "cookie", "telegramid") 
values (pwd, q, tid);

else
-- обновление куки
update "user" 
set cookie=q 
where telegramid=tid;

end if;

return query select u."telegramid" from "user" u where u."cookie"=q;

end
$$;


--
-- TOC entry 235 (class 1255 OID 16454)
-- Name: CreateUser(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."CreateUser"(login character varying, pwd character varying, q character varying) RETURNS TABLE(email character varying)
    LANGUAGE plpgsql
    AS $$
begin
   insert into "user"("email", "passwordhash", "cookie") values(login, pwd, q);

   return query select u.email from public.user AS u WHERE u.email = login AND u.passwordhash = pwd AND u.cookie = q LIMIT 1;

end
$$;


--
-- TOC entry 219 (class 1255 OID 16388)
-- Name: GetProductCost(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."GetProductCost"(pid bigint) RETURNS money
    LANGUAGE plpgsql
    AS $_$
DECLARE
i money;
BEGIN
select "cost" into i from "product" where "idproduct"=$1;
return i;
END;
$_$;


--
-- TOC entry 220 (class 1255 OID 16389)
-- Name: GetShortCart(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."GetShortCart"(uid bigint) RETURNS TABLE(label text, amount bigint)
    LANGUAGE plpgsql
    AS $$
begin
   return query 
   select concat("name", concat(' ×', "count")) as "label", 
   ((("total")::numeric)*100)::bigint as "amount" 
   from "cart_view"
   where "userid" = uid
   order by "label" asc;
end
$$;


--
-- TOC entry 221 (class 1255 OID 16390)
-- Name: GetUserID(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."GetUserID"(cookie character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$DECLARE
i bigint;
BEGIN
select public.user.userid from public.user into i where public.user.cookie=$1;
return i;
END;$_$;


--
-- TOC entry 222 (class 1255 OID 16391)
-- Name: UpdatePosition(bigint, bigint, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."UpdatePosition"(pid bigint, uid bigint, pcs integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

if pcs=0 then
    delete from "cart" where "userid"=uid and "productid"=pid;

else
    update "cart" 
    set "total"=pcs*"GetProductCost"(pid), 
    "count"=pcs 
    WHERE userid=uid AND productid=pid;
end if;

END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 16392)
-- Name: cart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart (
    userid bigint NOT NULL,
    productid bigint NOT NULL,
    count integer NOT NULL,
    total money
);


--
-- TOC entry 210 (class 1259 OID 16395)
-- Name: product_idproduct_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_idproduct_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 211 (class 1259 OID 16396)
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    idproduct integer DEFAULT nextval('public.product_idproduct_seq'::regclass) NOT NULL,
    name character varying(45) NOT NULL,
    cost money NOT NULL,
    categoryid integer,
    "imageURI" character varying(2048),
    description character varying(255),
    specifications character varying(512)
);


--
-- TOC entry 212 (class 1259 OID 16402)
-- Name: user_userid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 213 (class 1259 OID 16403)
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    userid integer DEFAULT nextval('public.user_userid_seq'::regclass) NOT NULL,
    email character varying(255),
    passwordhash character varying(64),
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    cookie character varying(1024),
    telegramid bigint
);


--
-- TOC entry 214 (class 1259 OID 16410)
-- Name: cart_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cart_view AS
 SELECT "user".userid,
    "user".email,
    cart.productid,
    cart.count,
    cart.total,
    ( SELECT sum(cart_1.total) AS "TOTALSUM"
           FROM public.cart cart_1
          WHERE (cart_1.userid = "user".userid)
          GROUP BY cart_1.userid) AS "TOTALSUM",
    product.name,
    product.cost,
    product."imageURI" AS imageuri
   FROM ((public.cart
     JOIN public.product ON ((product.idproduct = cart.productid)))
     JOIN public."user" USING (userid));


--
-- TOC entry 215 (class 1259 OID 16415)
-- Name: category_idcategory_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.category_idcategory_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 216 (class 1259 OID 16416)
-- Name: category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category (
    idcategory integer DEFAULT nextval('public.category_idcategory_seq'::regclass) NOT NULL,
    categoryname character varying(64)
);


--
-- TOC entry 3354 (class 0 OID 16392)
-- Dependencies: 209
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cart VALUES (61, 9, 1, '$55.80');
INSERT INTO public.cart VALUES (49, 9, 1, '$55.80');


--
-- TOC entry 3360 (class 0 OID 16416)
-- Dependencies: 216
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.category VALUES (1, 'Процессоры');
INSERT INTO public.category VALUES (2, 'Оперативная память');
INSERT INTO public.category VALUES (3, 'Дроны');
INSERT INTO public.category VALUES (4, 'Транспорт');
INSERT INTO public.category VALUES (5, 'Гардероб');


--
-- TOC entry 3356 (class 0 OID 16396)
-- Dependencies: 211
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.product VALUES (9, 'RAM', '$55.80', 2, 'https://static.vecteezy.com/system/resources/previews/000/455/612/original/vector-ram-memory-card-character.jpg', 'Not enough RAM to run 100+ tabs? We found a solution', NULL);
INSERT INTO public.product VALUES (1, 'Test Product', '$179.99', 3, 'https://avatars.mds.yandex.net/get-zen_doc/3512190/pub_5fb24c411064d30b6c5c7c56_5fb3921a7eb1fe4ba0977fca/scale_1200', 'Дрон — это беспилотное летательное устройство с четырьмя пропеллерами. Им можно дистанционно управлять при помощи специального пульта.', 'Вид: любительский\r\nРазмер: мини\r\nМаксимальное время полета, в мин: 31\r\nМаксимальный радиус полета, в м: 10000\r\nМаксимальная высота полета, в м: 4000\r\nМаксимальная горизонтальная скорость, в км/ч: 57\r\nУправление: с пульта ду\r\nРазмеры в разложенном состоянии (ВxШxГ), в мм: 159х203х56\r\nКод товара: 100027597426');
INSERT INTO public.product VALUES (2, 'Deepthought', '$1,422.56', 1, 'https://coaching-n-reviews.ru/wp-content/uploads/2019/09/2017-06-11-deep-thought-e1569009243103.jpg', 'Possibility to get answer to the ultimate question of life, the universe, and everything', NULL);
INSERT INTO public.product VALUES (8, 'Babel Fish', '$420.77', 1, 'https://wordlace.files.wordpress.com/2016/07/diagram_hitchhikers_guide_to_the_galaxy_babelfish_1920x1080_wallpaper_wallpaper_2560x1600_www-wall321-com.jpg', 'Need translator inside of your head?', NULL);
INSERT INTO public.product VALUES (11, 'Mysterious T-Shirt', '$42.00', 5, 'https://i.ebayimg.com/images/g/dt0AAOSwjC9Zgc4v/s-l400.jpg', 'Hmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm', NULL);
INSERT INTO public.product VALUES (77, 'Mega Brain', '$5,555.77', 1, 'https://astrovedom.com/wp-content/uploads/2021/10/mental_connection.jpg', NULL, NULL);
INSERT INTO public.product VALUES (10, '''Heart of Gold'' Escape Pod', '$4,242.56', 4, 'https://i.pinimg.com/originals/99/1a/75/991a75c1d55df3008b02cab163ab9a34.jpg', 'We don''t know, just escape', NULL);


--
-- TOC entry 3358 (class 0 OID 16403)
-- Dependencies: 213
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."user" VALUES (31, 'randomuser35236@croco.digital', '1a64b1d94a69bd35d5ecdd568ccefcdab186783375af0e67115b8f142897fb69', '2022-06-12 16:45:51', NULL, NULL);
INSERT INTO public."user" VALUES (1, 'admin@croco.digital', 'aaaaaaaaaaaaaaaaaaaaaaaa', '2022-06-09 08:23:46', NULL, NULL);
INSERT INTO public."user" VALUES (8, 'admin19203912039012390@croco.digital', 'aaaaaaa', '2022-06-09 07:06:20', NULL, NULL);
INSERT INTO public."user" VALUES (28, 'randomuser58702@croco.digital', '635cbe8da5843c81585b3aeb2ccd97543b82db5981870e31aca0182f63323525', '2022-06-12 16:45:50', NULL, NULL);
INSERT INTO public."user" VALUES (29, 'randomuser10889@croco.digital', '8e2147d3682b1051e491e2bbda9f4265d77fdbbbe4654811f4784f49740881a3', '2022-06-12 16:45:50', NULL, NULL);
INSERT INTO public."user" VALUES (30, 'randomuser14655@croco.digital', 'ee3056eb6d097d8085e4a73b86225d5d9b9993483e84c40746be4a8b2ad32dcc', '2022-06-12 16:45:51', NULL, NULL);
INSERT INTO public."user" VALUES (32, 'randomuser68220@croco.digital', '95f5a35362894f3a532b9ce6bfb77b84875217c8969957ad8b75dd91759bff5f', '2022-06-12 16:45:51', NULL, NULL);
INSERT INTO public."user" VALUES (33, 'randomuser35907@croco.digital', 'e37935aae1f80a8561ee12f54340191285b16c618b04d7739a5b96670e30fa10', '2022-06-12 16:45:51', NULL, NULL);
INSERT INTO public."user" VALUES (34, 'randomuser53325@croco.digital', 'ad5ae606dd6ebd288277734246117120828db0da3ac9246dfcc2afd3a4169a36', '2022-06-12 16:45:51', NULL, NULL);
INSERT INTO public."user" VALUES (35, 'randomuser12775@croco.digital', '5e1b3f4fac12d42d28e333d062059d227afce547b94f1c779d97710c683a5830', '2022-06-12 16:45:52', NULL, NULL);
INSERT INTO public."user" VALUES (36, 'randomuser44140@croco.digital', '2beb7c41c8de4fee63842bedae7815d98c74c24361e3ab76e8c934b212f60fdf', '2022-06-12 16:48:32', NULL, NULL);
INSERT INTO public."user" VALUES (37, 'randomuser2498@croco.digital', 'bc9bf1ee50f15ac8e62712bf76b765439dd9c15004924d6e8452383cb90d5e3d', '2022-06-12 16:52:41', NULL, NULL);
INSERT INTO public."user" VALUES (38, 'randomuser45325@croco.digital', '6b23ac83aff41f9312cd7e9ffd337af88fac5ec84fade7735a55c148e5e9e7ac', '2022-06-12 19:42:30', NULL, NULL);
INSERT INTO public."user" VALUES (39, 'randomuser40600@croco.digital', 'b397a431c910bf3ba8a080745e2516f266241fa2feb2c076e912503d4c8772ca', '2022-06-12 20:26:35', NULL, NULL);
INSERT INTO public."user" VALUES (40, 'randomuser49422@croco.digital', '586480f61f31e369e7b993f29ebda400737c60847e168a9fe42bb4ebbde23634', '2022-06-12 20:43:17', NULL, NULL);
INSERT INTO public."user" VALUES (41, 'randomuser46983@croco.digital', '177552d44448bb9eb78af4b3a24cb394037f9cf626ac8f8f0ea25cd10659416f', '2022-06-14 08:35:08', NULL, NULL);
INSERT INTO public."user" VALUES (16, 'azaza@croco.digital', 'aec1d3f1da857a4b76ac1bae0aabc5c96298112c9ed7e8ed7f5ea0a418fca501', '2022-06-12 12:28:07', NULL, NULL);
INSERT INTO public."user" VALUES (2, 'aasdasdsadkokij@askdlas.ru', 'c041e7bc7c3b52742ecb34b8192d7db4d0b94a849581cd0c87593a3984b86f28', '2022-06-16 19:45:40.050665', NULL, NULL);
INSERT INTO public."user" VALUES (4, 'randomuser68394@croco.digital', 'ce1d6dcca65157a37cb745f027b7a776ea2e5c66e77ef4250ed162562fd0a811', '2022-06-17 11:46:35.212688', NULL, NULL);
INSERT INTO public."user" VALUES (5, 'randomuser52574@croco.digital', '9e1029608e7bbb22b7a3db360fc310e5204276c9d8ae3ad0d2027f07bc08a69e', '2022-06-17 11:47:29.610276', NULL, NULL);
INSERT INTO public."user" VALUES (7, 'randomuser5243@croco.digital', '30da6a6eb162e3db9e6628c3a78da396c288c84808b54889a96d5c1f7ea56a51', '2022-06-17 11:48:58.945363', NULL, NULL);
INSERT INTO public."user" VALUES (10, 'randomuser71032@croco.digital', '7474c449a2bac80c1c143f5aa2f2722a637384bbdfd79e27803ad7c604ff9850', '2022-06-17 12:16:47.092923', NULL, NULL);
INSERT INTO public."user" VALUES (11, 'randomuser64073@croco.digital', 'd2a0322458583361d270b3020f6b6f2b67a060b9635342f97d5946bbcf6b62fb', '2022-06-17 12:22:19.19405', NULL, NULL);
INSERT INTO public."user" VALUES (48, 'aSFDZXCBVCBXCVBXCVB@gmail.com', 'a886483e0fdb26f45e4b6524406d9648a845db2f4ac8b9472568b02d9dae579c', '2022-06-20 21:08:30.494779', NULL, NULL);
INSERT INTO public."user" VALUES (13, 'admin1231111111123123123qwsad45@croco.digital', 'fdc17e4bb36f25b802ac10698e79638567e9339d012eb99f96d297d2acfbb3f7', '2022-06-09 08:22:24', NULL, NULL);
INSERT INTO public."user" VALUES (50, 'bchilala22@yahoo.com', '6a004d88066a16b7787e45e3adcee8e97d10bbdd7c06feded8205a757595104c', '2022-06-22 14:16:56.577672', NULL, NULL);
INSERT INTO public."user" VALUES (52, 'd@s.com', '9a69e300fd4719efac5e4946e3f59f509f6034ea548d4ba8ecf2e8cb6894c6e8', '2022-06-23 09:54:46.135773', NULL, NULL);
INSERT INTO public."user" VALUES (53, 'bayramovtheking@gmail.com', '0b14d73d0829e3507c7694e272d7360494d48ecd1168883f3316374294d5f57f', '2022-06-23 10:51:06.907363', NULL, NULL);
INSERT INTO public."user" VALUES (51, 'claudylus@hotmail.com', '7b339bc474607ec492dfb7b208524db073c434b0448e30a5f9d3210bcf7931b2', '2022-06-23 09:30:09.34112', NULL, NULL);
INSERT INTO public."user" VALUES (62, NULL, 'telegram+1575612317', '2022-06-24 10:02:52.332699', 'e588a48ea1923df2c345f816cfa3c5c1ae397822297cd5d819c703814c8c9c59', 1575612317);
INSERT INTO public."user" VALUES (63, 'mydelphi6@ya.ru', '3cb99f983680c38d92e2e34446645309cba1abd87c4ebaa69ada7f297d870cdd', '2022-06-24 10:53:10.069451', '485d666d9dbe55bc4070860c9debb795afccf629494ebc2f06ce80f7d258ee76', NULL);
INSERT INTO public."user" VALUES (73, NULL, 'telegram+1069487890', '2022-07-01 10:17:50.289856', '317564d85072d9aa435a62631c9ed5cb836ac67657fca7c72afe0d90b69713af', 1069487890);
INSERT INTO public."user" VALUES (69, 'ieowieori@croco.com', 'e45e40e74ca06d6931b98ddc5c24e09804acdb5b6726d80a0adc0af8bde88929', '2022-06-27 14:56:13.106239', NULL, NULL);
INSERT INTO public."user" VALUES (57, NULL, 'telegram+2087307323', '2022-06-23 18:53:09.858988', 'daa0e7e68afc6dae08b87d5746aba5b0cf7b01cf4211ccd72a51477c427601d1', 2087307323);
INSERT INTO public."user" VALUES (55, NULL, 'telegram+423215995', '2022-06-23 16:29:00.539028', 'f2adff1f759f3ffffdd05a0394ef8b3b8cebc4c2729ec2864d9b4183342133ef', 423215995);
INSERT INTO public."user" VALUES (56, NULL, 'telegram+1487068611', '2022-06-23 16:36:12.15661', NULL, 1487068611);
INSERT INTO public."user" VALUES (60, 'askdlaskldksa@croco.digital', 'efcb2ab1e81a02be2395915b8c622a09d19e30757dfa80197ef80177c024942c', '2022-06-24 08:55:48.780821', NULL, NULL);
INSERT INTO public."user" VALUES (58, 'ajajam@mail.ru', '921a8fc1d5098738c661af034d2efe2c5d51d1ad700db506fa480471469841ea', '2022-06-23 20:37:25.250109', NULL, NULL);
INSERT INTO public."user" VALUES (3, 'admin123@croco.digital', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '2022-06-09 06:40:23', NULL, NULL);
INSERT INTO public."user" VALUES (6, 'admin12345@croco.digital', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', '2022-06-09 06:43:26', NULL, NULL);
INSERT INTO public."user" VALUES (9, 'admin123111111145@croco.digital', 'f68772bcb110de1cb2407703e2e35ec259cb0eb5e604f6f23cf905d11c71a7a2', '2022-06-09 08:18:36', NULL, NULL);
INSERT INTO public."user" VALUES (54, NULL, 'aaaaaa', '2022-06-23 15:34:42.888518', NULL, 4242422);
INSERT INTO public."user" VALUES (49, 'mphanzio@gmail.com', '85d8301fc5b530704a5cce709053bc85a74ec711262f360077bddbf40c696e8e', '2022-06-21 11:15:33.313194', '5abb0a4639a380d58a1eaa1d5bea6d4007485c8529b3c4c8fe95c7ebf1079182', NULL);
INSERT INTO public."user" VALUES (70, 'askdlaskdlas@croco.digital', '123321', '2022-06-27 15:04:23.01477', '555777', NULL);
INSERT INTO public."user" VALUES (71, 'askdlaskdl1111111as@croco.digital', '123321', '2022-06-27 15:04:33.091421', '555777', NULL);
INSERT INTO public."user" VALUES (61, NULL, 'telegram+1502685054', '2022-06-24 08:56:52.704763', NULL, 1502685054);
INSERT INTO public."user" VALUES (72, 'cazmero@gmail.com', '67f020b52a1b0adbc9851974639b3514e49af6f3c2082b643bade81a8a12d811', '2022-06-27 18:42:14.295341', '4d8bc3e7cb00c852190dd72deca3d3ce8aef826d02c000b6de75fb90ff4a48bf', NULL);
INSERT INTO public."user" VALUES (68, 'crzbove@gmail.com', 'fe8d16a96a2542ccf844bccc39531ec72bcb384174d39443635086989f977123', '2022-06-27 09:04:20.148851', '5ff2d81685b270c9d911be2aa8aa581ece327a2ef73acfbb9d164a7d545efb5c', NULL);
INSERT INTO public."user" VALUES (12, 'admin123111111112312312345@croco.digital', 'c70c5b6cc0c3def63fb4f58efe428e599b2f0c35a20aa6e459afcee55a30c5dc', '2022-06-09 08:21:13', NULL, NULL);
INSERT INTO public."user" VALUES (14, 'randomuser4828@croco.digital', 'fffe816c5c684fd656aec6f7b4b5682de82ee9a58c58814737fa4c75d650ec43', '2022-06-11 23:57:13', NULL, NULL);
INSERT INTO public."user" VALUES (17, 'randomuser36295@croco.digital', 'f167b207e44dd68d5ab252fe8bef6ff3158ef21bae335a35c70da8e34f9822e1', '2022-06-12 13:00:47', NULL, NULL);
INSERT INTO public."user" VALUES (18, 'randomuser46293@croco.digital', '419741adbd927a5c754f860a1f6aaaa7ff8ca1adffe4df3e52ad256bc739ca07', '2022-06-12 13:04:08', NULL, NULL);
INSERT INTO public."user" VALUES (19, 'randomuser50983@croco.digital', 'a81bf300affa3af2295c847acd1d3900f8bfa9b4872303955bb796b9e530a1e5', '2022-06-12 13:28:02', NULL, NULL);
INSERT INTO public."user" VALUES (20, 'randomuser16353@croco.digital', '60483168d2a0e145e297e2519ad9dc7f0ba2f18a478360515d061b82dc1101b8', '2022-06-12 15:39:37', NULL, NULL);
INSERT INTO public."user" VALUES (21, 'randomuser20740@croco.digital', 'b17ce4880cbfa985836f8f07f65c9a7f187668dee3a26a6f961037ef1d37ac30', '2022-06-12 15:42:18', NULL, NULL);
INSERT INTO public."user" VALUES (22, 'randomuser51186@croco.digital', '34f1c01711e1337474a9f651ba211fd540656d7924dbe037dfe90af98e0611ed', '2022-06-12 15:42:39', NULL, NULL);
INSERT INTO public."user" VALUES (23, 'randomuser10515@croco.digital', 'a9f92b997db5686c2fd48b6b21d7460091f980e1fdc090eb2b1c72edd157e745', '2022-06-12 15:43:20', NULL, NULL);
INSERT INTO public."user" VALUES (24, 'randomuser57092@croco.digital', 'ec3bb0b6a8ba3c4382f0fd9da9f5c6d5bfa7dfa2591aef243283344e245251f7', '2022-06-12 16:31:44', NULL, NULL);
INSERT INTO public."user" VALUES (25, 'randomuser28602@croco.digital', 'ac56b6d5c610a62bf3983c407fbc6d33c832e7b957691f396125ade4c9573a83', '2022-06-12 16:40:58', NULL, NULL);
INSERT INTO public."user" VALUES (26, 'randomuser1953@croco.digital', '985045de33dce0cc329371fdfba863f900e86ae18b48e7f505f22b9c72597dc1', '2022-06-12 16:45:48', NULL, NULL);
INSERT INTO public."user" VALUES (27, 'randomuser54190@croco.digital', 'd585b2ce70ac399913e14569d8479b62b4a767c64c20f4c82d5f9c5a513f3511', '2022-06-12 16:45:50', NULL, NULL);


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 215
-- Name: category_idcategory_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.category_idcategory_seq', 6, true);


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 210
-- Name: product_idproduct_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_idproduct_seq', 80, true);


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 212
-- Name: user_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_userid_seq', 73, true);


--
-- TOC entry 3210 (class 2606 OID 16421)
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (idcategory);


--
-- TOC entry 3206 (class 2606 OID 16452)
-- Name: user email_unique_checl; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT email_unique_checl UNIQUE (email) INCLUDE (email);


--
-- TOC entry 3204 (class 2606 OID 16423)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (idproduct);


--
-- TOC entry 3208 (class 2606 OID 16425)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (userid);


--
-- TOC entry 3213 (class 2606 OID 16426)
-- Name: product cid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT cid FOREIGN KEY (categoryid) REFERENCES public.category(idcategory) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 3211 (class 2606 OID 16431)
-- Name: cart pid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT pid FOREIGN KEY (productid) REFERENCES public.product(idproduct);


--
-- TOC entry 3212 (class 2606 OID 16436)
-- Name: cart uid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT uid FOREIGN KEY (userid) REFERENCES public."user"(userid);


-- Completed on 2022-07-01 15:12:02

--
-- PostgreSQL database dump complete
--

