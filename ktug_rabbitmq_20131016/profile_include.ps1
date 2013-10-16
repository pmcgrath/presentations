# 'c:\temp\demo\profile_include.ps1' > $profile.allusersallhosts
# To reload with changes . $profile.allusersallhosts

# Variables
$erlangHomeValue = 'c:\utilities\erl5.10.3';
$rabbitMQServerValue = 'c:\utilities\rabbitmq';

# Environment variables
$env:ERLANG_HOME = $erlangHomeValue;	
$env:RABBITMQ_SERVER = $rabbitMQServerValue;

# Paths
@(
	'c:\utilities\git\bin',
	'c:\utilities\rubies\ruby-2.0.0-p247\bin',
	'c:\windows\microsoft.net\framework\v4.0.30319',
	"$erlangHomeValue\bin",
	"$rabbitMQServerValue\sbin"
) | % { if (! ($env:Path.Contains($_))) { $env:Path += ";$_"; } }

# Aliases
set-alias np 'c:\utilities\notepad++\notepad++.exe';
