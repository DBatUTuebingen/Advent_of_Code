import matplotlib.pyplot as plt
import numpy as np
import csv

xs = []
ys = []
zs = []
droplet = []

with open('filled2.txt') as input:
  reader = csv.reader(input, delimiter=',')
  for x, y, z in reader:
    xs.append(int(x))
    ys.append(int(y))
    zs.append(int(z))
    droplet.append((int(x), int(y), int(z)))

shell = []
with open('filled.txt') as input:
  reader = csv.reader(input, delimiter=',')
  for x, y, z in reader:
    shell.append((int(x), int(y), int(z)))


# # prepare some coordinates
maxDim = max(xs+ys+zs)
x, y, z = np.indices((maxDim, maxDim, maxDim))

# # draw cuboids in the top left and bottom right corners, and a link between
# # them
# cube1 = (x < 3) & (y < 3) & (z < 3)
# cube2 = (x >= 5) & (y >= 5) & (z >= 5)
# link = abs(x - y) + abs(y - z) + abs(z - x) <= 2

# combine the objects into a single boolean array
# voxelarray = cube1 | cube2 | link
# cubes = (x in xs) & (y in ys) & (z in zs)

cubes = []
for cx,cy,cz in droplet:
  cube = (x == cx) & (y == cy) & (z == cz)
  cubes.append(cube)

voxelarray = cubes[0]
for c in cubes[1:]:
  voxelarray |= c

cubes_shell = []
for cx,cy,cz in shell:
  cube = (x == cx) & (y == cy) & (z == cz)
  cubes_shell.append(cube)

voxelarray_shell = cubes_shell[0]
for c in cubes_shell[1:]:
  voxelarray_shell |= c

# set the colors of each object
colors = np.empty(voxelarray.shape, dtype=object)

for c in cubes:
  colors[c] = '#FF0000FF'

for c in cubes_shell:
  colors[c] = '#00FF0030'

# colors[link] = 'red'
# colors[cube1] = 'blue'
# colors[cube2] = 'green'

# and plot everything
ax = plt.figure().add_subplot(projection='3d')
# ax.voxels(voxelarray, facecolors=colors)
ax.voxels(voxelarray_shell, facecolors=colors, edgecolor='#00000030')
# ax.voxels(voxelarray, edgecolor= 'k')

plt.show()
