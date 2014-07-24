#!/usr/bin/env bash
echo *** Root
curl http://localhost:8080/ -v 

echo *** Contacts
curl http://localhost:8080/contacts -v 
echo *** Add
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Tom Joe", "surname": "a" }'
curl http://localhost:8080/contacts/tom%20joe%20a -v
echo *** Update 
curl http://localhost:8080/contacts/tom%20joe%20a -v -XPUT -d '{ "id": "tom joe a", "forename": "Tom Joe", "surname": "ALTERED SURNAME" }'
curl http://localhost:8080/contacts/tom%20joe%20a -v
echo *** Delete
curl http://localhost:8080/contacts/tom%20joe%20a -v -XDELETE
curl http://localhost:8080/contacts/tom%20joe%20a -v

echo *** Adding a bunch of contacts qith same name - all willbe given different ids - see location header value
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v -XPOST -d '{ "forename": "Ted", "surname": "Toe" }'
curl http://localhost:8080/contacts/ -v

echo *** Adding a bunch of contacts
for number in `seq 100`
do
	curl http://localhost:8080/contacts/ -v -XPOST -d "{ \"forename\": \"Ted\", \"surname\": \"Surname_$number\" }"
done  
curl http://localhost:8080/contacts/ -v

