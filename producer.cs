// See http://www.rabbitmq.com/dotnet.html for driver lib
using RabbitMQ.Client;
using System;

class App
{
	static void Main()
	{
		var _connectionFactory = new ConnectionFactory();
		var _connection = _connectionFactory.CreateConnection();
		var _channel = _connection.CreateModel();

		Console.WriteLine("Hit enter to declare exchange");
		Console.ReadLine();
		_channel.ExchangeDeclare("demo_exchange", ExchangeType.Fanout); 
		
		Console.WriteLine("Hit enter to declare queue");
		Console.ReadLine();	
		_channel.QueueDeclare("demo_queue", false, false, false, null); 
		
		Console.WriteLine("Hit enter to bind queue");
		Console.ReadLine();
		_channel.QueueBind("demo_queue", "demo_exchange", string.Empty, null);

		Console.WriteLine("Hit enter to close channel");
		Console.ReadLine();
		_channel.Close();
		
		Console.WriteLine("Hit enter to close connection");
		Console.ReadLine();
		_connection.Close();
	}
}

