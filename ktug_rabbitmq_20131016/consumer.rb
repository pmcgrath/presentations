require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
queue  = channel.queue('demo_queue')
queue.subscribe do |delivery_info, properties, payload|
  puts "Received message with content [#{payload}]"
end

gets
connection.close