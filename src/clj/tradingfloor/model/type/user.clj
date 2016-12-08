(ns tradingfloor.model.type.user)

(defrecord UserHeader [firstName patronymic lastName
                      ^long likes ^long dislikes ^long userId]

(defrecord UserData [UserHeader lastLogin contacts)
