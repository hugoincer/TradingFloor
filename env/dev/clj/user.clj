(ns user
  (:require [mount.core :as mount]
            [tradingfloor.figwheel :refer [start-fw stop-fw cljs]]
            tradingfloor.core))

(defn start []
  (mount/start-without #'tradingfloor.core/repl-server))

(defn stop []
  (mount/stop-except #'tradingfloor.core/repl-server))

(defn restart []
  (stop)
  (start))


