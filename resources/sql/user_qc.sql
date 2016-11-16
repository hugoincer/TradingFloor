-- :name create-user! :! :1
-- :doc retrieve all users.
SELECT public.create_user(:email, :password, :firstName, :patronymic,
                          :lastName, :contactData);

-- :name- create-temp-auth! :! :1
-- :doc creates a new user record
SELECT public.create_temp_auth(:email, :oneTimePass, :expirationTime,
                               :firstName, :patronymic, :lastName, :contactData)

-- :name change-password! :! :n
-- :doc creates a new user record
UPDATE public.user
SET password = :password
WHERE id = :id
RETURNING 0;

-- :name add-like! :! :n
-- :doc creates a new user record
UPDATE public.user
SET "likesAmount" = "likesAmount" + 1;
WHERE id = :id
RETURNING 0;

-- :name add-dislike! :! :n
-- :doc creates a new user record
UPDATE public.user
SET "dislikesAmount" = "dislikesAmount" + 1;
WHERE id = :id
RETURNING 0;

-- :name change-password! :! :n
-- :doc creates a new user record
UPDATE public."userData"
SET "firstName" = :firstName,
     patronymic = :patronymic,
    "lastName" = :lastName,
    "contactData" = :contactData,
WHERE id = :id
RETURNING 0;

-- :name update-last-login! :! :n
-- :doc creates a new user record
UPDATE public."userData"
SET "lastLogin" = current_timestamp,
WHERE id = :id
RETURNING 0;

-- :name get-auth-data :? :1
-- :doc
SELECT (email, password, "expirationTime")
FROM public.user
WHERE id = :id;

-- :name get-auth-ones :? :1
-- :doc
SELECT (email, "oneTimePass", "expirationTime")
FROM public.user
WHERE id = :id;

-- :name get-data :? :1
-- :doc
SELECT ("firstName", patronymic, "lastName", "contactData",
        "lastLogin", "likesAmount", "dislikesAmount")
FROM public."userData"
WHERE userId = :id;
