// Test with curl http://localhost:8080/ -v
package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Root handled")
}

func main() {
	http.HandleFunc("/", handler)     // Uses default mux, so all content for /* will get handled by the handler function
	http.ListenAndServe(":8080", nil) // Listen on all interfaces on port 8080, creates one listener and a go routine for each accepted connection
}
