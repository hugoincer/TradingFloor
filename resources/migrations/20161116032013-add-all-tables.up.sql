
CREATE SEQUENCE "tradingfloor_dev"."public"."user_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."user" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."user_id_seq"'),
                "email" VARCHAR(50) NOT NULL,
                "password" VARCHAR(300),
                "oneTimePass" VARCHAR(300),
                "expirationTime" DATE,
                "vkUser" BOOLEAN DEFAULT FALSE NOT NULL,
                CONSTRAINT "userpkey" PRIMARY KEY ("id")
);

ALTER SEQUENCE "tradingfloor_dev"."public"."user_id_seq" OWNED BY "tradingfloor_dev"."public"."user"."id";

CREATE TABLE "tradingfloor_dev"."public"."userData" (
                "userId" INTEGER NOT NULL,
                "firstName" VARCHAR(50) NOT NULL,
                "patronymic" VARCHAR(50) NOT NULL,
                "lastName" VARCHAR(50),
                "contactData" TEXT NOT NULL,
                "lastLogin" TIMESTAMP,
                "likesAmount" INTEGER DEFAULT 0 NOT NULL,
                "dislikesAmount" INTEGER DEFAULT 0 NOT NULL,
                CONSTRAINT "userdatapk_fk" PRIMARY KEY ("userId")
);

CREATE SEQUENCE "tradingfloor_dev"."public"."tradeoffer_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."tradeOffer" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."tradeoffer_id_seq"'),
                "name" VARCHAR(20) NOT NULL,
                "photoLink" VARCHAR(100) NOT NULL,
                "amount" INTEGER DEFAULT 1 NOT NULL,
                "price" NUMERIC(2),
                "date" DATE NOT NULL,
                "description" TEXT NOT NULL,
                "viewed" INTEGER DEFAULT 0 NOT NULL,
                "status" BOOLEAN DEFAULT FALSE NOT NULL,
                "userId" INTEGER NOT NULL,
                CONSTRAINT "tradeofferpkey" PRIMARY KEY ("id")
);


ALTER SEQUENCE "tradingfloor_dev"."public"."tradeoffer_id_seq" OWNED BY "tradingfloor_dev"."public"."tradeOffer"."id";


CREATE TABLE "tradingfloor_dev"."public"."notificationSubscription" (
                "tradeOfferId" INTEGER NOT NULL,
                "userId" INTEGER NOT NULL,
                CONSTRAINT "notificationsubscriptionpk_fk" PRIMARY KEY ("tradeOfferId", "userId")
);

CREATE INDEX tradeoffer_amount_date_idx
 ON "tradingfloor_dev"."public"."tradeOffer"
 ( "amount", "date" );

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
 ON "tradingfloor_dev"."public"."user"
 ( "email" );

--CLUSTER tradeofferpkey ON TradeOffer;

ALTER TABLE "tradingfloor_dev"."public"."notificationSubscription" ADD CONSTRAINT "tradeoffer_notificationsubscription_fk"
FOREIGN KEY ("tradeOfferId")
REFERENCES "tradingfloor_dev"."public"."tradeOffer" ("id")
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."notificationSubscription" ADD CONSTRAINT "user_notificationsubscription_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."user" ("id")
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."tradeOffer" ADD CONSTRAINT "user_tradeoffer_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."user" ("id")
ON DELETE CASCADE
ON UPDATE RESTRICT
NOT DEFERRABLE;

ALTER TABLE "tradingfloor_dev"."public"."userData" ADD CONSTRAINT "user_userdata_fk"
FOREIGN KEY ("userId")
REFERENCES "tradingfloor_dev"."public"."user" ("id")
ON DELETE CASCADE
ON UPDATE RESTRICT
NOT DEFERRABLE;

CREATE OR REPLACE FUNCTION public.create_user(email_in VARCHAR(50), password_in VARCHAR(300),
        "firstName_in" VARCHAR(50), "patronymic_in" VARCHAR(50), "lastName_in" VARCHAR(50), "contactData_in" VARCHAR(500))
  RETURNS BOOLEAN AS
$func$
BEGIN
    WITH new_id  AS (
        INSERT INTO public.user (email, password)
            VALUES (email_in, password_in) RETURNING id
    )

    INSERT INTO public."userData" ("userId", "firstName", patronymic, "lastName", "contactData")
    VALUES ( (SELECT id FROM new_id ), "firstName_in", "patronymic_in", "lastName_in", "contactData_in");
    RETURN TRUE;
  EXCEPTION
    WHEN unique_violation THEN
            RETURN FALSE;
END;
$func$  LANGUAGE plpgsql STRICT;

CREATE OR REPLACE FUNCTION public.create_temp_auth(email_in VARCHAR(50), "oneTimePass_in" VARCHAR(300),
        "expirationTime_in" DATE, "firstName_in" VARCHAR(50), "patronymic_in" VARCHAR(50), "lastName_in" VARCHAR(50), "contactData_in" VARCHAR(500))
  RETURNS VOID AS
$func$
BEGIN
    IF ( select exists(SELECT email FROM public.user WHERE email = email_in))THEN
        UPDATE public.user SET "oneTimePass" = "oneTimePass_in", "expirationTime" = "expirationTime_in" ;
    ELSE
       WITH new_id  AS (
            INSERT INTO public.user (email, "oneTimePass", "expirationTime")
            VALUES (email_in, "oneTimePass_in", "expirationTime_in") RETURNING id
        )
        INSERT INTO public."userData" ("userId", "firstName", patronymic, "lastName", "contactData")
        VALUES ( (SELECT id FROM new_id ), "firstName_in", "patronymic_in", "lastName_in", "contactData_in");
    END IF;
  EXCEPTION
    WHEN unique_violation THEN
            UPDATE public.user SET "oneTimePass" = "oneTimePass_in", "expirationTime" = "expirationTime_in" ;

END;
$func$  LANGUAGE plpgsql STRICT;
