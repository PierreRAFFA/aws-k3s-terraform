package main

import (
	"fmt"
	"html"
	"log"
	"net/http"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello app2, %q", html.EscapeString(r.URL.Path))
	})

	http.HandleFunc("/api/app2", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "This is the app2")
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
