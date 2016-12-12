--- COMMANDS DEFINITIONS ---

-- :name create-offer! :! :n
-- :doc Creates new offer for specified user.
INSERT INTO public."tradeOffer"
( name, price, "currencyId",  "userId", amount, description )
VALUES( :offerHeader.name,
        :offerHeader.price.value,
        public.get_price_id(:offerHeader.price.currency),
        :offerIdentifier.userId,
        :amount,
        :description )
RETURNING 0;

-- :name change-offer! :! :n
-- :doc Creates new offer for specified user.
UPDATE public."tradeOffer"
SET name = :offerHeader.name,
    price = :offerHeader.price.value,
    "currencyId" = public.get_price_id(:offerHeader.price.currency),
    moddate = current_timestamp,
    amount = :amount,
    description = :description
WHERE "id" = :offerIdentifier.offerId AND "userId" = :offerIdentifier.userId
RETURNING 0;

-- :name change-offer-status! :! :n
-- :doc Changes offer status(in sale or was saled)
UPDATE public."tradeOffer"
SET status = :status
WHERE id = :offerIdentifier.offerId AND "userId" = :offerIdentifier.userId
RETURNING 0;

-- :name change-offer-price! :! :n
-- :doc Changes offer price
UPDATE public."tradeOffer"
SET price = :price.value,
    "currencyId" = public.get_price_id(:price.currency)
WHERE id = :offerIdentifier.offerId AND "userId" = :offerIdentifier.userId
RETURNING 0;

-- :name change-offer-photo! :! :n
-- :doc Change data of specified offer.
UPDATE public."tradeOffer"
SET photo = :photo
WHERE id = :offerIdentifier.offerId AND "userId" = :offerIdentifier.userId
RETURNING 0;

-- :name inc-offer-viewed! :! :n
-- :doc Increment viewed of offer.
UPDATE public."tradeOffer"
SET viewed = viewed + 1
WHERE id = :offerId
RETURNING 0;

-- :name create-subscription! :! :n
-- :doc Creates subscription for specified user on specified offer.
INSERT INTO public."notificationSubscription"
("tradeOfferId", "userId")
VALUES(:subscribtion.offerId, :subscribtion.userId)
RETURNING 0

--- QUERIES DEFINITIONS ---

-- :name get-offer-detailed :? :1
-- :doc Get full offer data.
SELECT   "id" AS "offerId",
         "name",
         "amount",
         "price" AS "value",
         (SELECT "name" FROM public."currency"
          WHERE "id" ="currencyId") AS "currency",
         "moddate",
         "description",
         "viewed" ,
         "userId"
FROM public."tradeOffer"
WHERE id = :offerId

-- :name get-user-offer-detailed :? :1
-- :doc Get full offer data.
SELECT   "id" AS "offerId",
         "name",
         "amount",
         "price" AS "value",
         (SELECT "name" FROM public."currency"
          WHERE "id" ="currencyId") AS "currency",
         "moddate",
         "description",
         "viewed" ,
         "userId"
FROM public."tradeOffer"
WHERE id = :offerIdentifier.offerId AND "userId" = :offerIdentifier.userId

-- :name get-offer-price :? :1
-- :doc Get choosen offer price.
SELECT price as "value", "currency".name as currency  FROM public."tradeOffer"
JOIN public."currency" ON "currencyId" = public."currency".id
WHERE "tradeOffer".id = :offerId

-- :name subscription-exists :? :1
-- :doc Checks if subscribtion exists.
SELECT  EXISTS (SELECT * FROM public."notificationSubscription"
        WHERE "tradeOfferId" = :subscribtion.offerId
        AND "userId" = :subscribtion.userId) AS "subscribed";


-- :name get-offers-in-range :? :*
-- :doc Get user offers list.
SELECT * FROM public."tradeOffer"
ORDER BY moddate ASC
LIMIT :curpos OFFSET :curoff;

-- :name get-user-offers-in-range :? :*
-- :doc Get user offers list.
SELECT * FROM public."tradeOffer"
WHERE "userId" = :userId
ORDER BY moddate ASC
LIMIT :curpos OFFSET :curoff;

-- :name get-user-offers-with-filters :? :*
-- :doc Return offers selected by filters for specified user.
SELECT * FROM public."tradeOffer"
WHERE "userId" = :userId
AND (price >= :priceMin AND price <= :priceMax)
AND status = :status
AND (viewed >= :viewedMin AND viewed <= :viewedMax)
(AND moddate >= :moddateMin AND moddate <= :moddateMax)
ORDER BY moddate ASC
LIMIT :curpos OFFSET :curoff;

-- :name get-offers-with-filters :? :*
-- :doc Return offers selected by filters
SELECT * FROM public."tradeOffer"
AND (price >= :priceMin AND price <= :priceMax)
AND status = :status
AND (viewed >= :viewedMin AND viewed <= :viewedMax)
(AND moddate >= :moddateMin AND moddate <= :moddateMax)
ORDER BY moddate ASC
LIMIT :curpos OFFSET :curoff
