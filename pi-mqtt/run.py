import json
import sys

import ibmiotf.device
from uti import *
from time import sleep

def connect(config):
    options = ibmiotf.device.ParseConfigFile(config)
    client = ibmiotf.device.Client(options)
    client.connect()
    client.commandCallback = on_message
    return client


def on_message(cmd):
    inpstr = cmd.command;
    print('\ngot command:' + cmd.command)
    # print('\n\ttimestamp:' + cmd.timestamp)
    # print('\ngot data\n' + cmd.format)
    # parsed_string = json.loads(cmd.data)
    print('\n\tdata: ' + cmd.data['message'])


def send_data():
    for sensorVal in range(1, 30):
        sleep(2)
        data = '{"message" : "hello client #' +str(sensorVal) +'"}'
        client.publishEvent('bar', 'json', data)
        print('\ndata sent')


client = connect('device.cfg')


def main():
	# argv = sys.argv
	while 1:
		send_data()


if __name__ == '__main__':
    main()