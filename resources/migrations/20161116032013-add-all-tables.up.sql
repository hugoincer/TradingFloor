--
--        TABLES DEFINITIONS
--

--Creating currency table
CREATE SEQUENCE "tradingfloor_dev"."public"."currency_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."currency" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."currency_id_seq"'),
                "name" CHAR(3) NOT NULL,
                CONSTRAINT "currencypk" PRIMARY KEY ("id")
);


ALTER SEQUENCE "tradingfloor_dev"."public"."currency_id_seq" OWNED BY "tradingfloor_dev"."public"."currency"."id";

INSERT INTO "tradingfloor_dev"."public"."currency" ("name")
VALUES ('BYR'),
       ('RUB'),
       ('USD'),
       ('EUR');

--Simple protection from modification
CREATE OR REPLACE FUNCTION public.protect_currency()
  RETURNS trigger AS
$func$
BEGIN
   RAISE EXCEPTION 'Fuck of from currency!';
END;
$func$  LANGUAGE plpgsql STRICT;

CREATE TRIGGER prevent__currency_action
       BEFORE INSERT OR UPDATE OR DELETE ON "tradingfloor_dev"."public"."currency"
       FOR EACH STATEMENT EXECUTE PROCEDURE public.protect_currency();


CREATE TYPE LIKE_ACTION AS ENUM ('l', 'd', 'n');

CREATE TABLE "tradingfloor_dev"."public"."likes" (
                "likerId" INTEGER NOT NULL,
                "likedUserId" INTEGER NOT NULL,
                "like_action" LIKE_ACTION NOT NULL DEFAULT 'n',
                CONSTRAINT "likesidpk" PRIMARY KEY ("likerId", "likedUserId")
);

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

CREATE TYPE OFFER_STATUS AS ENUM ('a', 's', 'd');

CREATE SEQUENCE "tradingfloor_dev"."public"."tradeoffer_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."tradeOffer" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."tradeoffer_id_seq"'),
                "name" VARCHAR(50) NOT NULL,
                "amount" INTEGER DEFAULT 1 NOT NULL,
                "price" NUMERIC(12,2),
                "currencyId" INTEGER NOT NULL DEFAULT 1,
                "moddate" TIMESTAMP NOT NULL DEFAULT current_timestamp,
                "description" TEXT NOT NULL,
                "viewed" INTEGER NOT NULL DEFAULT 0,
                "status" OFFER_STATUS NOT NULL DEFAULT 'a',
                "userId" INTEGER NOT NULL,
                "photo" BYTEA,
                CONSTRAINT "tradeofferpk" PRIMARY KEY ("id")
);


ALTER SEQUENCE "tradingfloor_dev"."public"."tradeoffer_id_seq" OWNED BY "tradingfloor_dev"."public"."tradeOffer"."id";

CREATE TABLE "tradingfloor_dev"."public"."userData" (
                "userId" INTEGER NOT NULL,
                "firstName" VARCHAR(50) NOT NULL,
                "patronymic" VARCHAR(50) NOT NULL,
                "lastName" VARCHAR(50),
                "lastLogin" TIMESTAMP NOT NULL DEFAULT current_timestamp,
                "likes" INTEGER DEFAULT 0 NOT NULL,
                "dislikes" INTEGER DEFAULT 0 NOT NULL,
                "contacts" TEXT NOT NULL,
                "photo" BYTEA,
                CONSTRAINT "userdatapk_fk" PRIMARY KEY ("userId")
);


CREATE INDEX tradeoffer_amount_date_idx
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

CREATE UNIQUE INDEX user_email_idx
 ON "tradingfloor_dev"."public"."role"
 ( "email" );

CREATE UNIQUE INDEX currency_name_idx
 ON "tradingfloor_dev"."public"."currency"
 ( "name" );


ALTER TABLE "tradingfloor_dev"."public"."tradeOffer" ADD CONSTRAINT "currencytype_tradeoffer_fk"
FOREIGN KEY ("currencyId")
REFERENCES "tradingfloor_dev"."public"."currency" ("id")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."notificationSubscription" ADD CONSTRAINT "user_notificationsubscription_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."role" ("id")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."tradeOffer" ADD CONSTRAINT "user_tradeoffer_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."role" ("id")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."userData" ADD CONSTRAINT "user_userdata_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."role" ("id")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."notificationSubscription" ADD CONSTRAINT "tradeoffer_notificationsubscription_fk"
FOREIGN KEY ("tradeOfferId")
REFERENCES "tradingfloor_dev"."public"."tradeOffer" ("id")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."likes" ADD CONSTRAINT "userdata_likes_fk1"
FOREIGN KEY ("likedUserId")
REFERENCES "tradingfloor_dev"."public"."userData" ("userId")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."likes" ADD CONSTRAINT "userdata_likes_fk"
FOREIGN KEY ("likerId")
REFERENCES "tradingfloor_dev"."public"."userData" ("userId")
ON DELETE RESTRICT
ON UPDATE RESTRICT
NOT DEFERRABLE;




--
--      STORED PROCEDURES AND FUNCTIONS
--

CREATE OR REPLACE FUNCTION public.create_user(email_in VARCHAR(50), password_in VARCHAR(300),
        "firstName_in" VARCHAR(50), "patronymic_in" VARCHAR(50), "lastName_in" VARCHAR(50), "contacts_in" VARCHAR(500))
  RETURNS BOOLEAN AS
$func$
BEGIN
   IF ((SELECT email FROM  public.role WHERE email = email_in) IS NULL) THEN

      WITH new_id  AS (
          INSERT INTO public.role (email, password)
              VALUES (email_in, password_in) RETURNING id
      )

      INSERT INTO public."userData" ("userId", "firstName", patronymic, "lastName", contacts)
      VALUES ( (SELECT id FROM new_id ), "firstName_in", "patronymic_in", "lastName_in", "contacts_in");
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
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
