(ns tradingfloor.controller.auth
  (:require [tradingfloor.db.core :as trdb]
            [ring.util.response :refer [resource-response response]]
            [buddy.hashers])
  (:alias  udb tradingfloor.db.user))

(defmulti auth-execute
    (fn [session request]
      (:command request)))

(defmethod auth-execute "login" [session request]
      (let [ data (:data request)
            ad (udb/get-auth-data {:email (:email data)})
            password (:password data)]
          (if (nil? ad)
              (response {:error "User not found!"})
              (let [loggedin (buddy.hashers/check password  (:password ad))
                    resp  (response {:loggedin loggedin})]
                  (if loggedin
                       (-> resp
                           (assoc :session (assoc session :userId (:id ad))))
                       resp)
              )
          )
      )
)

(defmethod auth-execute "register" [session data]
          ( response {:error "Not implemented yet!"}))

(defmethod auth-execute "logout" [session data]
      (-> (response {:message "You logged out!"})
      (dissoc :session)))
