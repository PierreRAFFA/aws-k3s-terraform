package main

import (
	"fmt"
	"html"
	"log"
	"net/http"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Root of users microservice, %q", html.EscapeString(r.URL.Path))
	})

	http.HandleFunc("/api/users/1", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "{\"name\":\"croissant\"}")
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
