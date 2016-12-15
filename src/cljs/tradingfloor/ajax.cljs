(ns tradingfloor.ajax
  (:require [ajax.core :as ajax :refer [ POST]]
            [clojure.walk :as clwk]))

(defn local-uri? [{:keys [uri]}]
  (not (re-find #"^\w+?://" uri)))

(defn default-headers [request]
  (if (local-uri? request)
    (-> request
        (update :uri #(str js/context %))
        (update :headers #(merge {"x-csrf-token" js/csrfToken} %)))
    request))

(defn load-interceptors! []
  (swap! ajax/default-interceptors
         conj
         (ajax/to-interceptor {:name "default headers"
                               :request default-headers})))

(defn error-handler [{:keys [status status-text]}]
 (.log js/console
  (str "something bad happened: " status " " status-text)))

(defn command-ajax [controller command data f args]
   (POST (str "/" controller)
        {
         :params {:command command :data data}
         :handler (fn [response]
                     (let [k-response (clwk/keywordize-keys response)]
                       (f k-response args) ))
         :format :json
         :response-format :json
         :error-handler error-handler }))
