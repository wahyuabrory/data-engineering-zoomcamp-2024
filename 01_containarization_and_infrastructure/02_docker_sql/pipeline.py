import sys

import pandas as pd 

print(sys.argv) # list of arguments passed to the script

day = sys.argv[1] # first argument passed to the script

# fancy stuff with pandas
print(f"Job done for day = {day}")