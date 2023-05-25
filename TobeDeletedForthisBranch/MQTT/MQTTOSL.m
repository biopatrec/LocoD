myMQTT= mqtt('tcp://brokerurl');
Topic= "OSL/command";
publish(myMQTT, Topic, message);