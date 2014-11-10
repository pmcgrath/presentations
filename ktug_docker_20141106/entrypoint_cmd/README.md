# Build image
docker build -t test_ep_cmd .  
This will copy the ep.sh script as ep.sh and cmd.sh into the container, but since the ENTRYPOINT instruction is used the cmd.sh script will never be used

# Run image with no cmd args, not the args to ep.sh (They are the CMD instruction contents)
docker run --rm -ti --name test_ep_cmd_default test_ep_cmd
Use ctl-c to stop the container

# Run image with cmd args, not the args to ep.sh (The CMD instruction contents have been replaced by what we passed in the docker run command)
docker run --rm -ti --name test_ep_cmd_default test_ep_cmd ARG1
Use ctl-c to stop the container

