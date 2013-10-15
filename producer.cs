// See http://www.rabbitmq.com/dotnet.html for driver lib
using RabbitMQ.Client;
using System;
using System.Text;


class App
{
	static void Main()
	{
		var _exchangeName = "demo_exchange";
		var _queueName = "demo_queue";
	
		var _connectionFactory = new ConnectionFactory();
		var _connection = _connectionFactory.CreateConnection();
		
		Console.WriteLine("Hit enter to create the channel");
		Console.ReadLine();
		var _channel = _connection.CreateModel();

		Console.WriteLine("Hit enter to declare exchange");
		Console.ReadLine();
		_channel.ExchangeDeclare(_exchangeName, ExchangeType.Fanout); 
		
		Console.WriteLine("Hit enter to declare queue");
		Console.ReadLine();	
		_channel.QueueDeclare(_queueName, false, false, false, null); 
		
		Console.WriteLine("Hit enter to bind queue");
		Console.ReadLine();
		_channel.QueueBind(_queueName, _exchangeName, string.Empty, null);
		
		do
		{
			var _messageProperties = _channel.CreateBasicProperties();
			_messageProperties.ContentType = "text/plain";
			_messageProperties.Type = "amessage";
			var _messageBodyContent = string.Format("Message created @ {0}", DateTime.Now);
			var _messageBodyData = Encoding.UTF8.GetBytes(_messageBodyContent);
			_channel.BasicPublish(_exchangeName, string.Empty, _messageProperties, _messageBodyData);
			
			Console.WriteLine("Just published message with content [{0}]", _messageBodyContent);
			Console.WriteLine("Hit enter to publish another message, use x to stop publishing");
		}
		while (Console.ReadLine() != "x");

		Console.WriteLine("Hit enter to close channel");
		Console.ReadLine();
		_channel.Close();
		
		Console.WriteLine("Hit enter to close connection");
		Console.ReadLine();
		_connection.Close();
	}
}

