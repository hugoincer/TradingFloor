(ns tradingfloor.model.type.offer)


(defrecord Price [value currency])

(defrecord OfferHeader [name price amount moddate viewed] )

(defrecord UserOfferRelation [userId offerId])

(defrecord OfferData [offerHeader description offerIdentifier] )

;--additional constructors
(defn full->OfferData
  "Creates a new trade offer data object."
  [{:keys [name value currency moddate viewed amount description userid offerid]}]
  (->OfferData (OfferHeader. name (Price. value currency) amount moddate viewed)
               description
               (UserOfferRelation. userid offerid)))


(defn without-stat->OfferData
  "Creates a new trade offer data object withous statistics."
  [{:keys [name value currency moddate viewed amount description userid offerid]}]
  (->OfferData (OfferHeader. name (Price. value currency) amount nil nil)
               description
               (UserOfferRelation. userid offerid)))

(defn conv-to-list [off-seq]
  (doall (map #(full->OfferData %)  off-seq)))
