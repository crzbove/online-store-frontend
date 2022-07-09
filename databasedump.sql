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

