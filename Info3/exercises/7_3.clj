(ns user
  (:use [clojure.string :only [join]]))

(defn next [pattern]
  (loop [next [-1] i 0 j -1]
    (if (< i (- (count pattern) 1))
      (if (or (= j -1) (= (nth pattern i) (nth pattern j)))
        (recur (conj next (inc j)) (inc i) (inc j))
        (recur next i (nth next j)))
      next)))

(defn next2 [] 123)

(defn kmp [text pattern]
  (let [next (next pattern)
        plength (count pattern)
        tlength (count text)]
    (loop [steps [] i 0 j 0]
      (cond
       (= j plength) [steps (- i plength)]
       (= i tlength) tlength
       (or (= j -1) (= (nth text i) (nth pattern j))) (recur (conj steps [i j]) (inc i) (inc j))
       'else (recur (conj steps [i j]) i (nth next j))))))

(def pattern "abrakadabra")
(def res (kmp "und abraham sprach abrakadabra, aber ..." pattern))

(def res (first res))

(def lines (for [[i j] res]
             (str
              (join (repeat (- i j) " "))
              pattern
              "\n"
              (join (repeat i " "))
              "^")))

(join "\n" lines)
