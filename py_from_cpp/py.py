import sys
import json

def main():
	argv = json.loads(sys.argv[1])
	print(argv["device_id"])


if __name__ == '__main__':
    main()