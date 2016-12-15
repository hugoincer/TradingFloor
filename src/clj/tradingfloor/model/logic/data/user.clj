(ns tradingfloor.model.logic.data.user
         (require: [tradingfloor.model.validation.user :as vu]
                   [tradingfloor.db.user :as dao]))
         (:import [ tradingfloor.model.type.user
                    UserHeader
                    UserData ]))

(defprotocol UserDataProtocol
    (change-data! [this userId userData])
    (like! [this ^long userId])
    (dislike! [this ^long userId])
    (change-photo! [this ^long userId photo])
    (take-data  [this ^long userId])
    #_(take-photo [this ^long userId])
    #_(change-photo! [this ^long userId photo])
)

(deftype UserManager [])
(extend-type UserManager
        UserDataProtocol

     ;--
    (change-data! [this ^long userId userData]
     (dao/change-user-data! (conj userData {:userId userId})))

     ;--
    (like! [this ^long userId]
      (dao/add-like! {:userId userId}))

     ;--
    (dislike! [this ^long userId]
      (dao/add-dislike! {:userId userId}))

     ;--
    (take-data  [this ^long  userId]
        (dao/get-user-data {:userId userId}))


  #_(take-photo [this ^long userId] ())
  #_(change-photo! [this userId photo] ())
)
