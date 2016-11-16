--- COMMANDS DEFINITIONS ---

-- :name create-offer! :! :n
-- :doc Creates new offer for specified user.
INSERT INTO public."tradeOffer"
( name, "photoLink", amount, price, "date", "description", "userId" )
VALUES( :name, :photoLink, :amount, :price, current_date, :description, :userId)
RETURNING 0

-- :name change-offer-sale-data! :! :n
-- :doc Changes offer status(in sale or was saled) and its price.
UPDATE public."tradeOffer"
SET status = :status,
    price = :price
WHERE id = :id AND "userId" = :userId
RETURNING 0

-- :name remove-offer! :! :n
-- :doc Remove specified offer.
DELETE FROM public."tradeOffer"
WHERE id = :id AND "userId" = :userId
RETURNING 0

-- :name change-offer-photo! :! :n
-- :doc Change data of specified offer.
UPDATE public."tradeOffer"
SET photoLink = :photoLink
WHERE id = :id AND "userId" = :userId
RETURNING 0

-- :name inc-offer-viewed! :! :n
-- :doc Increment viewed of offer.
UPDATE public."tradeOffer"
SET viewed = viewed + 1
WHERE id = :id
RETURNING 0

-- :name create-subscription :! :n
-- :doc Creates subscription for specified user on specified offer.
INSERT INTO public."notificationSubscription"
("tradeOfferId", "userId")
VALUES(:tradeOfferId, :userId)
RETURNING 0

--- QUERIES DEFINITIONS ---

-- :name get-offer-detailed :? :1
-- :doc Get full offer data.
SELECT * FROM public."tradeOffer"
WHERE id = :id

-- :name get-user-offer-detailed :? :1
-- :doc Get specified offer of specified user.
SELECT * FROM public."tradeOffer"
WHERE id = :id AND "userId" = :userId

-- :name get-offer-price :? :1
-- :doc Get choosen offer prices.
SELECT price FROM public."tradeOffer"
WHERE id = :id

-- :name get-user-offers-in-range :? :*
-- :doc Get user offers list.
SELECT * FROM public."tradeOffer"
WHERE "userId" = :userId
ORDER BY id
LIMIT :curpos OFFSET :curoff

-- :name get-offers-prices-in-range :? :*
-- :doc Get prices of specified offers.
SELECT price FROM public."tradeOffer"
WHERE "userId" = :userId
ORDER BY id
LIMIT :curpos OFFSET :curoff

-- :name get-offers-with-filters :? :*
SELECT * FROM public."tradeOffer"
WHERE "userId" = :userId
AND (price >= :priceMin AND price <= priceMax)
AND status = :status
(AND "date" >= :vDate AND "date"<= :vDate)
ORDER BY id
LIMIT :curpos OFFSET :curoff
