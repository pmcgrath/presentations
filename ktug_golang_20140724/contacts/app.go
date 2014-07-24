/*
 See
	http://www.restapitutorial.com/lessons/httpmethods.html
	https://github.com/StefanSchroeder/Golang-Regex-Tutorial
	https://github.com/rcrowley/go-tigertonic
	http://www.gorillatoolkit.org/
	https://groups.google.com/forum/#!topic/golang-nuts/fxUz5WK6Hek
*/
package main

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	mathRand "math/rand" // Need alias due to clash with crypto/rand
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"
)

var pwd, _ = os.Getwd()
var templates = template.Must(template.ParseGlob(pwd + "/*.html"))

type Contact struct {
	Id       string `json:"id,omitempty"`
	Forename string `json:"forename,omitempty"`
	Surname  string `json:"surname,omitempty"`
}

func (self Contact) IsValidExcludingId() bool {
	return strings.TrimRight(self.Forename, "") != "" && strings.TrimRight(self.Surname, "") != ""
}

func (self Contact) IsValid() bool {
	return self.IsValidExcludingId() && strings.TrimRight(self.Id, "") != ""
}

type InMemorycontactStore struct {
	mutex sync.RWMutex
	Data  map[string]Contact
}

func (self *InMemorycontactStore) Get(id string) Contact {
	self.mutex.RLock()
	defer self.mutex.RUnlock()

	return self.Data[id]
}

func (self *InMemorycontactStore) GetAll() []Contact {
	self.mutex.RLock()
	defer self.mutex.RUnlock()

	contacts := make([]Contact, len(self.Data), len(self.Data))
	index := 0
	for _, contact := range self.Data {
		contacts[index] = contact
		index += 1
	}
	return contacts
}

func (self *InMemorycontactStore) Save(contact *Contact) {
	isAdding, candidateId := false, ""
	if contact.Id == "" {
		isAdding = true
		candidateId = strings.ToLower(fmt.Sprintf("%s %s", contact.Forename, contact.Surname))
	}

	self.mutex.Lock()
	defer self.mutex.Unlock()

	if isAdding {
		originalCandidateId := candidateId
		for {
			_, found := self.Data[candidateId]
			if !found {
				break
			}
			candidateId = fmt.Sprintf("%s%d", originalCandidateId, mathRand.Intn(10000))
		}

		contact.Id = candidateId
	}

	self.Data[contact.Id] = *contact
}

func (self *InMemorycontactStore) Delete(id string) string {
	self.mutex.Lock()
	defer self.mutex.Unlock()

	match, ok := self.Data[id]
	if ok {
		delete(self.Data, id)
	}
	return match.Id
}

var contactStore = &InMemorycontactStore{Data: make(map[string]Contact)}

type Encoding int

const (
	Unknown Encoding = iota
	Json
	Xml
)

func uuid() string {
	// See 	http://stackoverflow.com/questions/15130321/is-there-a-method-to-generate-a-uuid-with-go-language
	//	https://groups.google.com/forum/#!topic/golang-nuts/Rn13T6BZpgE
	//	https://groups.google.com/forum/#!msg/golang-nuts/d0nF_k4dSx4/rPGgfXv6QCoJ
	buf := make([]byte, 16)
	_, err := rand.Read(buf)
	if err != nil {
		return ""
	}
	buf[6] = (buf[6] & 0x0f) | 0x40
	buf[8] = (buf[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", buf[0:4], buf[4:6], buf[6:8], buf[8:10], buf[10:])
}

func determineIdFromUrlPath(path string) string {
	index := strings.LastIndex(path, "/")
	return path[index+1:]
}

func determineEncoding(v string, def Encoding) Encoding {
	if len(v) == 0 {
		return def
	}

	entries := strings.Split(v, ",")
	for _, entry := range entries {
		entryParts := strings.Split(entry, ";")
		if entryParts[0] == "application/json" {
			return Json
		}
		if entryParts[0] == "application/xml" {
			return Xml
		}
	}

	return def
}

func notFoundHandler(w http.ResponseWriter, r *http.Request) {
	http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
}

func methodNotAllowedHandler(w http.ResponseWriter, r *http.Request) {
	http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
}

func badRequestHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusBadRequest)
	fmt.Fprintln(w, http.StatusText(http.StatusBadRequest))
}

func internalServerErrorHandler(w http.ResponseWriter, r *http.Request) {
	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	contacts := contactStore.GetAll()

	w.Header().Set("Content-Type", "text/html")
	templates.ExecuteTemplate(w, "root.html", contacts)
}

func resourcesHandler(w http.ResponseWriter, r *http.Request) {
	// See http://jessekallhoff.com/2013/04/14/serving-static-content-from-go/
	http.ServeFile(w, r, r.URL.Path[1:])
}

func contactsGetHandler(w http.ResponseWriter, r *http.Request) {
	contacts := contactStore.GetAll()
	w.Header().Set("Content-Type", "application/json")
	encoder := json.NewEncoder(w)
	if err := encoder.Encode(contacts); err != nil {
		internalServerErrorHandler(w, r)
		return
	}
}

func contactsPostHandler(w http.ResponseWriter, r *http.Request) {
	var contact Contact
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&contact)
	if err != nil {
		badRequestHandler(w, r)
		return
	}

	if contact.Id != "" {
		badRequestHandler(w, r)
		return
	}

	if !contact.IsValidExcludingId() {
		badRequestHandler(w, r)
		return
	}

	contactStore.Save(&contact)

	locationUrl, _ := url.Parse(r.URL.Path)
	if !strings.HasSuffix(locationUrl.Path, "/") {
		locationUrl.Path += "/"
	}
	locationUrl.Path += contact.Id

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Location", locationUrl.String())
	w.WriteHeader(http.StatusCreated)
}

func contactGetHandler(w http.ResponseWriter, r *http.Request) {
	id := determineIdFromUrlPath(r.URL.Path)
	contact := contactStore.Get(id)
	if contact.Id == "" {
		notFoundHandler(w, r)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	encoder := json.NewEncoder(w)
	if err := encoder.Encode(contact); err != nil {
		internalServerErrorHandler(w, r)
		return
	}
}

func contactPutHandler(w http.ResponseWriter, r *http.Request) {
	var contact Contact
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&contact)
	if err != nil {
		badRequestHandler(w, r)
		return
	}

	id := determineIdFromUrlPath(r.URL.Path)
	if contact.Id != id {
		badRequestHandler(w, r)
		return
	}

	if !contact.IsValid() {
		badRequestHandler(w, r)
		return
	}

	contactStore.Save(&contact)
}

func contactDeleteHandler(w http.ResponseWriter, r *http.Request) {
	id := determineIdFromUrlPath(r.URL.Path)
	if deletedId := contactStore.Delete(id); deletedId == "" {
		notFoundHandler(w, r)
		return
	}
}

type statusCaptureResponseWriter struct {
	// See https://groups.google.com/forum/#!topic/golang-nuts/fxUz5WK6Hek
	http.ResponseWriter
	status int
}

func (self *statusCaptureResponseWriter) WriteHeader(code int) {
	// Will only get called if a non standard status code explicitly set
	self.status = code
	self.ResponseWriter.WriteHeader(code)
}

func (self *statusCaptureResponseWriter) statusCode() int {
	// See WriteHeader method comment
	if self.status == -1 {
		return 200
	}
	return self.status
}

type myHandler struct{}

func (self *myHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	startTime := time.Now()
	uuid := uuid()
	log.Printf("%s ServeHTTP Starting for %s %s\n", uuid, r.Method, r.URL.Path)

	statusCaptureWriter := &statusCaptureResponseWriter{ResponseWriter: w, status: -1}

	rootRegex := regexp.MustCompile(`^/?$`)
	resourcesRegex := regexp.MustCompile(`^/resources/.*`)
	contactsRegex := regexp.MustCompile(`^/contacts/?$`)
	contactRegex := regexp.MustCompile(`^/contacts/\w+(\s\w+)+$`) // Only caters for simple names with multiple spaces

	path := strings.ToLower(r.URL.Path)

	switch {
	case rootRegex.MatchString(path):
		log.Printf("%s ServeHTTP Using rootHandler for %s %s\n", uuid, r.Method, r.URL.Path)
		rootHandler(statusCaptureWriter, r)
	case resourcesRegex.MatchString(path):
		log.Printf("%s ServeHTTP Using resourcesHandler for %s %s\n", uuid, r.Method, r.URL.Path)
		resourcesHandler(statusCaptureWriter, r)
	case contactsRegex.MatchString(path):
		switch r.Method {
		case "GET":
			log.Printf("%s ServeHTTP Using contactsGetHandler for %s %s\n", uuid, r.Method, r.URL.Path)
			contactsGetHandler(statusCaptureWriter, r)
		case "POST":
			log.Printf("%s ServeHTTP Using contactsPostHandler for %s %s\n", uuid, r.Method, r.URL.Path)
			contactsPostHandler(statusCaptureWriter, r)
		default:
			methodNotAllowedHandler(statusCaptureWriter, r)
		}
	case contactRegex.MatchString(path):
		switch r.Method {
		case "GET":
			log.Printf("%s ServeHTTP Using contactGetHandler for %s %s\n", uuid, r.Method, r.URL.Path)
			contactGetHandler(statusCaptureWriter, r)
		case "PUT":
			log.Printf("%s ServeHTTP Using contactPutHandler for %s %s\n", uuid, r.Method, r.URL.Path)
			contactPutHandler(statusCaptureWriter, r)
		case "DELETE":
			log.Printf("%s ServeHTTP Using contactDeleteHandler for %s %s\n", uuid, r.Method, r.URL.Path)
			contactDeleteHandler(statusCaptureWriter, r)
		default:
			methodNotAllowedHandler(statusCaptureWriter, r)
		}
	default:
		notFoundHandler(statusCaptureWriter, r)
	}

	log.Printf("%s ServeHTTP Completed for %s %s in %d μs status code is %d\n", uuid, r.Method, r.URL.Path, (time.Since(startTime) / time.Microsecond), statusCaptureWriter.statusCode())
}

func init() {
	mathRand.Seed(time.Now().UnixNano())
}

func main() {
	address := ":8080"
	if envAddress := strings.TrimSpace(os.Getenv("WEBAPP_ADDR")); envAddress != "" {
		address = envAddress
	}

	pid := os.Getpid()
	log.SetPrefix(fmt.Sprintf("%d ", pid))

	log.Printf("Started, listening on %s\n", address)
	myHandler := &myHandler{}
	http.ListenAndServe(address, myHandler)
}
