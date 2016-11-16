
CREATE SEQUENCE "tradingfloor_dev"."public"."user_id_seq";

CREATE TABLE "tradingfloor_dev"."public"."user" (
                "id" INTEGER NOT NULL DEFAULT nextval('"tradingfloor_dev"."public"."user_id_seq"'),
                "email" VARCHAR(50) NOT NULL,
                "password" VARCHAR(300),
                "oneTimePass" VARCHAR(300),
                "lastLogin" TIME NOT NULL,
                "expirationTime" TIMESTAMP NOT NULL,
                "vkUser" BOOLEAN DEFAULT false NOT NULL,
                CONSTRAINT "userpkey" PRIMARY KEY ("id")
);


ALTER SEQUENCE "tradingfloor_dev"."public"."user_id_seq" OWNED BY "tradingfloor_dev"."public"."user"."id";

CREATE TABLE "tradingfloor_dev"."public"."userData" (
                "userId" INTEGER NOT NULL,
                "photoLink" VARCHAR(100),
                "firstName" VARCHAR(50) NOT NULL,
                "patronymic" VARCHAR(50) NOT NULL,
                "lastName" VARCHAR(50),
                "contactData" VARCHAR(500) NOT NULL,
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
                "date" TIMESTAMP NOT NULL,
                "description" VARCHAR(1000) NOT NULL,
                "viewed" INTEGER DEFAULT 0 NOT NULL,
                "status" BOOLEAN DEFAULT false NOT NULL,
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
