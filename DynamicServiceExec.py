#!/usr/bin/python
from __future__ import print_function
import imp, sys, argparse, json

parser = argparse.ArgumentParser(description='Run import and run assigned python script')
parser.add_argument('-p', '--prepare', metavar='SCRIPT', help='Accepts a list of query commands from stdin, and return a list of displayable items')
parser.add_argument('-s', '--serve', metavar='SCRIPT', help='Serve the selected item, and do actions')
args = parser.parse_args()
if not (args.prepare or args.serve):
    print('{"Error": "Missing required arguments"}', end='')
    sys.exit(0)

class NoPrintsZone:
    def __enter__(self):
        self._origin_stdout = sys.stdout
        sys.stdout = None

    def __exit__(self, exc_type, exc_val, exc_tb):
        sys.stdout = self._origin_stdout

error = None
feedback = None
with NoPrintsZone():
    inputVal = json.loads(sys.stdin.read())
    try:
        if args.prepare:
            scriptLoaded = imp.load_source('Script', args.prepare)
            feedback = scriptLoaded.prepare(inputVal)
        elif args.serve:
            scriptLoaded = imp.load_source('Script', args.serve)
            scriptLoaded.serve(inputVal)
    except Exception as e:
        error = e

if error:
    print('{{"Error": "{}"}}'.format(error))
elif isinstance(feedback, list):
    print(json.dumps(feedback))
elif isinstance(feedback, dict):
    print(json.dumps([feedback]))
