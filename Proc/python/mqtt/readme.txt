python Proc\python\mqtt\pubsub.py --endpoint localhost --topic topic --message hello ^
--key broker.key --port 8883 --cert broker.crt --ca_file ca.crt

Connecting to localhost with client ID 'test-37affc24-3514-4bb2-9237-947d57493354'...
Connected!
Subscribing to topic 'topic'...
Subscribed with QoS.AT_LEAST_ONCE
Sending 10 message(s)
Publishing message to topic 'topic': hello [1]
Received message from topic 'topic': b'"hello [1]"'
Publishing message to topic 'topic': hello [2]
Received message from topic 'topic': b'"hello [2]"'
Publishing message to topic 'topic': hello [3]
Received message from topic 'topic': b'"hello [3]"'
Publishing message to topic 'topic': hello [4]
Received message from topic 'topic': b'"hello [4]"'
Publishing message to topic 'topic': hello [5]
Received message from topic 'topic': b'"hello [5]"'
Publishing message to topic 'topic': hello [6]
Received message from topic 'topic': b'"hello [6]"'
Publishing message to topic 'topic': hello [7]
Received message from topic 'topic': b'"hello [7]"'
Publishing message to topic 'topic': hello [8]
Received message from topic 'topic': b'"hello [8]"'
Publishing message to topic 'topic': hello [9]
Received message from topic 'topic': b'"hello [9]"'
Publishing message to topic 'topic': hello [10]
Received message from topic 'topic': b'"hello [10]"'
10 message(s) received.
Disconnecting...
Disconnected!
