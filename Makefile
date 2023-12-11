init:
	./scripts/synck8s.sh
	./scripts/generatecerts.sh
	go mod tidy

apiserver:
	./scripts/startapiserver.sh

local:
	./scripts/start.sh