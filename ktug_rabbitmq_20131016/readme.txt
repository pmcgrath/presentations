History
	AMQP - JP Morgan
		Brokerless v broker based messaging
		v0.9.1
		v1.0
			ZeroMQ criticism
	Book						http://www.manning.com/videla/
	Alternatives
		MQSeries
		Qpid
		Mule
		ZeroMQ
		Redis queues
		etc.


RabbitMQ
	Supports AMQP v0.9.1
	MQTT
	Plugins
	RabbitMQ specific extensions


Software
	erlang						http://www.erlang.org/download.html
	git							http://git-scm.com/download/win
	ruby						http://rubyinstaller.org/downloads/
		bundler gem
		bunny gem				http://rubygems.org/gems/bunny
	notepad++					http://notepad-plus-plus.org/download/v6.5.html
	rabbitmq					http://www.rabbitmq.com/install-windows-manual.html
	.NET
		RabbitMQ c# driver


Environment variables - run as an damin with an elevated shell, only needs to happen once
	[Environment]::SetEnvironmentVariable('ERLANG_HOME', 'c:\utilities\erl5.10.3', 'Machine');
	[Environment]::SetEnvironmentVariable('RABBITMQ_SERVER', 'c:\utilities\rabbitmq', 'Machine');


Windows path
	$env:path.split(';') | sort


Powershell profile
	set-executionpolicy remotesigned
	See profile_include.ps1


Ruby
	gem install bundler
	bundle


RabbitMQ
	Install management plugin
		rabbitmq-plugins enable rabbitmq_management
	Start server
		rabbitmq-server.bat -detached
	Server status
		rabbitmqctl.bat status

	View management plugin
		http://localhost:15672/
			guest
			guest

	Ports
		5672
		15672
		Clusters


AMQP concepts
	Virtual hosts - RabbitMQ specific
	Exchanges
		Types
			Direct
			Fanout
			Topic
			Headers
	Queues
	Bindings
	Connection and channel lifetimes


Patterns
	No silver bullet !
	Tutorials 		http://www.rabbitmq.com/getstarted.html
		Large number of language bindings - can be low level
	ZeroMQ guide	http://zguide.zeromq.org/
	Workers
	Pub\Sub


Libraries
	Ruby 	- bunny gem
	C\		- low level driver, easynetq, nservicebus, masstransit
	Java	- low level driver


Usage
	git log

	./compile.ps1
	./producer.exe


Usage
	Declartions need to always match as exchnages and queues are immutable
	Bindings are dynamic
	Durability - Exchanges and queues
	Persistence
	TTLs
	Acks
	Async ack pattern
	Confirm select
	Clusters
	Mirrored queues

	
Curl publication in powershell - escaping is terrible
	curl -i -u guest:guest -H "content-type:application/json" -d '{ \"properties\": { }, \"routing_key\": \"\", \"payload\": \"From curl\", \"payload_encoding\": \"string\" }' -X POST http://localhost:15672/api/exchanges/%2f/demo_exchange/publish


	
Place on github
	Billy ktug single repository
	
