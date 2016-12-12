(ns tradingfloor.model.logic.data.offer
          (:require
                   [tradingfloor.model.logic.validation.offer :as vo]
                   [tradingfloor.model.logic.validation.general :as vg]
                   [tradingfloor.db.core]
                   [tradingfloor.model.type.offer])
          (:alias db tradingfloor.db.offer)
          (:refer tradingfloor.model.type.offer)
          (:import [tradingfloor.model.type.offer
                     Price
                     OfferHeader
                     UserOfferRelation
                     OfferData]))

(defprotocol OfferProtocol

   (create! [this offer])
   (change! [this offerIdentifier])
   (change-status! [this offerIdentifier status])
   (subscribe [this offerIdentifier])
   (change-price! [this offerIdentifier price] )

   (inc-viewed! [this offerId])
   (take-price [this offerId])
   (take-detailed [this offerId])
   (find-offers-for-user [this userId amount from])
   (take-offers-list [this amount from])

 #_(change-photo! [this offerIdentifier photo])
 #_(get-user-offers-with-filters)
 #_(get-user-offers-with-filters)
)

(deftype Offer [])
(extend-type Offer
          OfferProtocol

     ;--
     (create! [this offer]
        (db/create-offer! offer))

     ;--
     (change! [this offer]

        (if (not= (without-stat->OfferData
                      (db/get-user-offer-detailed (:offerIdentifier offer)))
                  offer)
            ;--then
            (db/change-offer! offer)
        ))

     ;--
     (change-status! [this offerIdentifier status]
         (db/change-offer-status! {:status status
                                   :offerIdentifier offerIdentifier}))

     ;--
     (subscribe [this subscribtion]
         (if (:subscribed (db/subscription-exists  {:subscribtion subscribtion}))
             "You're already subscribed!"
             (db/create-subscription! {:subscribtion subscribtion}))
     )

     ;--
     (change-price! [this offerIdentifier price]
         (db/change-offer-price! {:price price
                                  :offerIdentifier offerIdentifier}))

     ;--
     (take-price [this offerId]
         (map->Price (db/get-offer-price {:offerId  offerId}))
     )

     ;--
     (take-detailed [this offerId]
         (full->OfferData (db/get-offer-detailed  {:offerId  offerId}))
         (db/inc-offer-viewed! {:offerId  offerId})
     )

     ;--
     (find-offers-for-user [this userId amount from]
         (conv-to-list (db/get-user-offers-in-range {:userId userId
                                                     :curpos amount
                                                     :curoff from}))
     )
     ;--
     (take-offers-list [this amount from]
        (conv-to-list (db/get-offers-in-range {:curpos amount :curoff from}))
     )

   #_(change-photo! [this offerIdentifier photo])
   #_(get-user-offers-with-filters)
   #_(get-user-offers-with-filters)
)
