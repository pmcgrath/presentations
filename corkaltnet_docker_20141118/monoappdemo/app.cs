using System;
using System.Threading;


class App
{
        public static void Main(
                string[] args)
        {
                var _sequence = 1;
                while(true) {
                                Console.WriteLine("{0}: OS={1} User={2} Sequence is {3}", DateTime.Now, Environment.OSVersion, Environment.UserName, _sequence);
                                _sequence++;
                                Thread.Sleep(1000);
                }
        }
}

