using System;
using System.Threading;


class App 
{
    private static readonly string Version = "1.0";


    public static void Main(string[] args)
    {
        var _sequence = 1;
        while(true) 
	{
            Console.WriteLine("{0}: v{1} OS={2} User={3} Sequence is {4}", 
                DateTime.Now, 
		App.Version,
                Environment.OSVersion, 
                Environment.UserName, 
                _sequence);

	    _sequence++;
            Thread.Sleep(1000);
        }
    }
}

