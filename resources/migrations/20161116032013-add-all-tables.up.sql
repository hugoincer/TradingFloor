--
--        TABLES DEFINITIONS
--

CREATE SEQUENCE "tradingfloor_dev"."public"."currency_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."currency" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."currency_id_seq"'),
                "name" CHAR(3) NOT NULL,
                CONSTRAINT "currencypk" PRIMARY KEY ("id")
);


ALTER SEQUENCE "tradingfloor_dev"."public"."currency_id_seq" OWNED BY "tradingfloor_dev"."public"."currency"."id";

CREATE TABLE "tradingfloor_dev"."public"."notificationSubscription" (
                "tradeOfferId" INTEGER NOT NULL,
                "userId" INTEGER NOT NULL,
                CONSTRAINT "notificationsubscriptionpk_fk" PRIMARY KEY ("tradeOfferId", "userId")
);


CREATE SEQUENCE "tradingfloor_dev"."public"."role_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."role" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."role_id_seq"'),
                "email" VARCHAR(50) NOT NULL,
                "password" VARCHAR(300),
                "oneTimePass" VARCHAR(300),
                "expirationTime" TIMESTAMP,
                CONSTRAINT "rolepk" PRIMARY KEY ("id")
);




ALTER SEQUENCE "tradingfloor_dev"."public"."role_id_seq" OWNED BY "tradingfloor_dev"."public"."role"."id";

CREATE SEQUENCE "tradingfloor_dev"."public"."tradeoffer_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."tradeOffer" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."tradeoffer_id_seq"'),
                "name" VARCHAR(50) NOT NULL,
                "price" NUMERIC(2),
                "currencyId" INTEGER DEFAULT 1 NOT NULL,
                "moddate" DATE NOT NULL,
                "viewed" INTEGER DEFAULT 0 NOT NULL,
                "status" BOOLEAN DEFAULT false NOT NULL,
                "userId" INTEGER NOT NULL,
                "amount" INTEGER DEFAULT 1 NOT NULL,
                "description" VARCHAR(1000) NOT NULL,
                "photo" BYTEA,
                CONSTRAINT "tradeofferpk" PRIMARY KEY ("id")
);


ALTER SEQUENCE "tradingfloor_dev"."public"."tradeoffer_id_seq" OWNED BY "tradingfloor_dev"."public"."tradeOffer"."id";

CREATE TABLE "tradingfloor_dev"."public"."userData" (
                "userId" INTEGER NOT NULL,
                "firstName" VARCHAR(50) NOT NULL,
                "patronymic" VARCHAR(50) NOT NULL,
                "lastName" VARCHAR(50),
                "likes" INTEGER DEFAULT 0 NOT NULL,
                "dislikes" INTEGER DEFAULT 0 NOT NULL,
                "lastLogin" TIMESTAMP,
                "contacts" VARCHAR(500) NOT NULL,
                "photo" BYTEA,
                CONSTRAINT "userdatapk_fk" PRIMARY KEY ("userId")
);

--
--      SEARCH INDEXES
--

CREATE INDEX tradeoffer_amount_moddate_idx
 ON "tradingfloor_dev"."public"."tradeOffer"
 ( "amount", "moddate" );

CREATE INDEX tradeoffer_nad_idx
 ON "tradingfloor_dev"."public"."tradeOffer"
 ( "name", "amount", "description" );

CREATE INDEX tradeoffer_name_amount_idx
 ON "tradingfloor_dev"."public"."tradeOffer"
 ( "name", "amount" );

CREATE INDEX tradeoffer_name_idx
 ON "tradingfloor_dev"."public"."tradeOffer"
 ( "name" );

--
--      UNIQUE INDEXES
--

CREATE UNIQUE INDEX user_email_idx
 ON "tradingfloor_dev"."public"."role"
 ( "email" );

 CREATE UNIQUE INDEX currency_name_idx
  ON "tradingfloor_dev"."public"."currency"
  ( "name" );

--
--    CASCADE OPERATION CONSTRAINTS
--

ALTER TABLE "tradingfloor_dev"."public"."tradeOffer" ADD CONSTRAINT "currencytype_tradeoffer_fk"
FOREIGN KEY ("currencyId")
REFERENCES "tradingfloor_dev"."public"."currency" ("id")
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."notificationSubscription" ADD CONSTRAINT "user_notificationsubscription_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."role" ("id")
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."tradeOffer" ADD CONSTRAINT "user_tradeoffer_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."role" ("id")
ON DELETE CASCADE
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."userData" ADD CONSTRAINT "user_userdata_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."role" ("id")
ON DELETE CASCADE
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."notificationSubscription" ADD CONSTRAINT "tradeoffer_notificationsubscription_fk"
FOREIGN KEY ("tradeOfferId")
REFERENCES "tradingfloor_dev"."public"."tradeOffer" ("id")
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--
--      STORED PROCEDURES AND FUNCTIONS
--

CREATE OR REPLACE FUNCTION public.create_user(email_in VARCHAR(50), password_in VARCHAR(300),
        "firstName_in" VARCHAR(50), "patronymic_in" VARCHAR(50), "lastName_in" VARCHAR(50), "contacts_in" VARCHAR(500))
  RETURNS BOOLEAN AS
$func$
BEGIN
    WITH new_id  AS (
        INSERT INTO public.role (email, password)
            VALUES (email_in, password_in) RETURNING id
    )

    INSERT INTO public."userData" ("userId", "firstName", patronymic, "lastName", contacts)
    VALUES ( (SELECT id FROM new_id ), "firstName_in", "patronymic_in", "lastName_in", "contacts_in");
    RETURN TRUE;
  EXCEPTION
    WHEN unique_violation THEN
            RETURN FALSE;
END;
$func$  LANGUAGE plpgsql STRICT;

CREATE OR REPLACE FUNCTION public.create_temp_auth(email_in VARCHAR(50), "oneTimePass_in" VARCHAR(300),
        "expirationTime_in" DATE, "firstName_in" VARCHAR(50), "patronymic_in" VARCHAR(50), "lastName_in" VARCHAR(50), "contacts_in" VARCHAR(500))
  RETURNS VOID AS
$func$
BEGIN
    IF ( select exists(SELECT email FROM public.role WHERE email = email_in))THEN
        UPDATE public.role SET "oneTimePass" = "oneTimePass_in", "expirationTime" = "expirationTime_in" ;
    ELSE
       WITH new_id  AS (
            INSERT INTO public.role (email, "oneTimePass", "expirationTime")
            VALUES (email_in, "oneTimePass_in", "expirationTime_in") RETURNING id
        )
        INSERT INTO public."userData" ("userId", "firstName", patronymic, "lastName", contacts)
        VALUES ( (SELECT id FROM new_id ), "firstName_in", "patronymic_in", "lastName_in", "contacts_in");
    END IF;
  EXCEPTION
    WHEN unique_violation THEN
            UPDATE public.role SET "oneTimePass" = "oneTimePass_in", "expirationTime" = "expirationTime_in" ;

END;
$func$  LANGUAGE plpgsql STRICT;

CREATE OR REPLACE FUNCTION public.get_price_id(name_in CHAR(3))
  RETURNS INTEGER AS
$func$
BEGIN
RETURN (SELECT id FROM public.currency WHERE name = name_in);
END;
$func$  LANGUAGE plpgsql STRICT;
