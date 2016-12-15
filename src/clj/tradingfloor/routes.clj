(ns tradingfloor.routes
  (:require [tradingfloor.layout :as layout]
            [compojure.core :refer [defroutes GET POST]]
            [ring.util.http-response :as resp]
            [clojure.java.io :as io]
            [ring.util.response :refer [resource-response response]]
            [buddy.hashers]
            [tradingfloor.controller.auth :as td-auth]))

(defn home-page []
  (layout/render "home.html"))


(defn magic [my-msg]
   {:message  (str  (:message my-msg)  (:message my-msg)  )
   :val (inc  (:val my-msg)  )

 })

(defroutes home-routes
  (GET "/" []
       (home-page))
  (GET "/docs" []
       (-> (resp/ok (-> "docs/docs.md" io/resource slurp))
       (resp/header "Content-Type" "text/plain; charset=utf-8")))

)

(defn c-controller [{body :body session :session}]
  (-> (response "Assoced to session")
         (assoc :session (assoc session :data body )))
)

;(def l-hash "bcrypt+sha512$e56dfab02e95c89b0f5364b6183d2429$12$fb66d763ce3665aefdc4bd687273c9a80503487a3235517d")

(defroutes command-routes
  (POST "/command" req (c-controller req))
  (POST "/authroute" req (td-auth/auth-execute (:session req) (:body req))))
