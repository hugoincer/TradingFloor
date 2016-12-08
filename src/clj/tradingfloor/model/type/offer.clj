(ns tradingfloor.model.type.offer)


(defrecord Price [value, currency])

(defrecord OfferHeader [^String name price moddate ^long viewed status] )

(defrecord OfferIdentifier [^long userId ^long id])

(defrecord OfferData [offerHeader ^long amount description offerIdentifier] )
