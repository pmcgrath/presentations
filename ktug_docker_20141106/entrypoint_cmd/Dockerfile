FROM ubuntu:14.04

COPY ep.sh ep.sh

# Can use same script, this time we make a copy named cmd.sh
COPY ep.sh cmd.sh

# This is what will get called when we do a "docker run"
ENTRYPOINT ["/ep.sh"]

# Since there is an ENTRYPOINT instruction this content will only ever be passed to ep.sh as arguments, if you pass args in the docker run command they will replace this these args
CMD ["/cmd.sh", "a1"]

