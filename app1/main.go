package main

import (
	"fmt"
	"html"
	"log"
	"net/http"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello app1, %q", html.EscapeString(r.URL.Path))
	})

	http.HandleFunc("/api/app1", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "This is the app1")
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}

aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 940432861086.dkr.ecr.eu-west-2.amazonaws.com