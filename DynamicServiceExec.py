from __future__ import print_function
import importlib, sys, argparse, json, os

parser = argparse.ArgumentParser(description='Run import and run assigned python script')
parser.add_argument('--supply', metavar='SCRIPT', help='Accepts a list of query commands from stdin, and return a list of displayable items')
parser.add_argument('--serve', metavar='SCRIPT', help='Serve the selected item, and do actions')
args = parser.parse_args()

if not (args.supply or args.serve):
    print('{"error": "Missing required arguments"}', end='', file=sys.stderr)
    sys.exit(0)

class NoPrintsZone:
    def __enter__(self):
        self._origin_stdout = sys.stdout
        sys.stdout = None

    def __exit__(self, exc_type, exc_val, exc_tb):
        sys.stdout = self._origin_stdout

def load_source(path):
    dirName, baseName = os.path.split(path)
    sys.path.append(dirName)
    scriptName = os.path.splitext(baseName)[0]
    return importlib.import_module(scriptName)

error = None
feedback = None
with NoPrintsZone():
    inputVal = json.loads(sys.stdin.read())
    try:
        if args.supply:
            scriptLoaded = load_source(args.supply)
            feedback = scriptLoaded.supply(inputVal)
        elif args.serve:
            scriptLoaded = load_source(args.serve)
            scriptLoaded.serve(inputVal)
    except Exception as e:
        error = e

if error:
    print('{{"error": "{}"}}'.format(error), file=sys.stderr)
elif isinstance(feedback, list):
    print(json.dumps(feedback))
elif isinstance(feedback, dict):
    print(json.dumps([feedback]))
