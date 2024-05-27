import os
from glob import glob

def fmt(original):
    return(original.replace("\\", "/").replace("./", "res://").replace("\\", "/") + ",")

print("Getting shaders...")
result_gdshader = [y for x in os.walk(".") for y in glob(os.path.join(x[0], '*.gdshader'))]
result_tscn = [y for x in os.walk(".") for y in glob(os.path.join(x[0], '*.tscn'))]
result = ""

for file in result_gdshader:
    result += fmt(file)

for file in result_tscn:
    if "shader_" in file:
        result += fmt(file)

result = result.rstrip(",")

f = open("shader_list.txt", "w")
f.write(result)
f.close()
print("Done.")
