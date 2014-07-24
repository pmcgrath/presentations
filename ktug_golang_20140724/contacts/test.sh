curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Tom Joe", "surname": "a" }'

curl http://localhost:8080/contacts/tom%20joe%20a -v
