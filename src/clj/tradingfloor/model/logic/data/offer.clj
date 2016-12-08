(ns tradingfloor.model.logic.data.offer
          (:require
                   [tradingfloor.model.validation.offer :as vo]
                   [tradingfloor.db.offer :as dao])
          (:import [ tradingfloor.model.type.offer
                     Price
                     OfferHeader
                     OfferData
                     OfferIdentifier ]))

(defprotocol OfferProtocol

   (create! [this offer])
   (remove! [this offerIdentifier])
   (change-status! [this offerIdentifier status])
   (subscribe [this offerIdentifier])
   (change-price! [this offerIdentifier price] )

   (inc-viewed! [this ^long offerId])
   (take-price [this ^long offerId])
   (take-detailed [this ^long offerId])
   (find-offers-for-user [this ^long userId ^long from ^long to])
   (take-offers-list [this ^long from ^long to])

 #_(change-photo! [this offerIdentifier photo])
 #_(get-user-offers-with-filters)
 #_(get-user-offers-with-filters)
)

(deftype Offer [])

(extend-type Offer
          OfferProtocol

     ;--
     (create! [this offer] (
         (dao/create-offer! offer))

     ;--
     (remove! [this offerIdentifier]
         ((dao/remove-offer! offerIdentifier))

     ;--
     (change-status! [this offerIdentifier status](
         (dao/change-offer-status! {:offerIndetifier offerIdentifier
                                    :status status})))

     ;--
     (change-price! [this offerIdentifier price]
         (dao/change-offer-price! {:offerIdentifier offerIdentifier
                                   :price price}))
     ;--
     (subscribe [this offerIdentifier]()
        (dao/create-subscription! offerIdentifier))

     ;--
     (inc-viewed! [this ^long offerId]
         (dao/inc-offer-viewed! {:id offerId} ))

     ;--
     (take-price [this ^long offerId]
           (dao/get-offer-price {:id offerId}))

     ;--
     (take-detailed [this ^long offerId]
           (dao/get-offer-detailed {:id offerId}) )

     ;--
     (find-offers-for-user [this ^long userId ^long from ^long to]
         (dao/get-user-offers-in-range {:userId userId
                                    :curpos from
                                    :curoff to}))

     ;--
     (take-offers-list [this ^long from ^long to]
       (dao/get-offers-in-range {:curpos  from
                             :curoff to}))

)
