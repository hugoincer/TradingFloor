(ns tradingfloor.model.validation.offer)

;--
(v/defvalidator valid-password
       {:default-message-format
              (str "Password must be at least 6 characters
              ;and contain at least one number, lowercase and
               uppercase letter; and one of this symbols
               !@#$&^*-+=<>?/:;{}[]"
             )
       }
       [p]
   (clojure.core/re-matches  #"(?=.*[\!\@\#\&\*\-\+\=\<\>\?\/\:\;\{\}\[\]])(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,}" p))
