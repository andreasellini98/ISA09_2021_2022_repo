import copy
import math
import sys

f = open("dadda_tree.vhd", "w")

u = 2
l = 0
lj = []

value = input("Please enter the parallelism:\n")
 
N = int(value)

# Evaluating number of rows per layer
while u < N/2+1:
    lj.append(u)
    u = math.floor(3*lj[l]/2)
    l = l + 1

# Actual rows of top layer is N/2 + 1
lj.append(int(N/2+1))

print("Number of max rows per layers : " + str(lj))
print("Number of layers = " + str(l))

# Signals declaration
for i in range(len(lj)):
    if (i == 0):
        f.write("TYPE p_layer_" + str(i) + " IS ARRAY(0 to " + str(lj[i]-1) + ") OF STD_LOGIC_VECTOR(2*NB DOWNTO 0); \n")
    else:
        f.write("TYPE p_layer_" + str(i) + " IS ARRAY(0 to " + str(lj[i]-1) + ") OF STD_LOGIC_VECTOR((2*NB - 1) DOWNTO 0); \n")
f.write("\n")
for i in range(len(lj)):
    f.write("signal p_" + str(i) + " : p_layer_" + str(len(lj)-(i+1)) + " \n")
f.write("\n")

# HA and FA initialization
ha = [[0 for x in range(2*N)] for y in range(l)]
fa = [[0 for x in range(2*N)] for y in range(l)]
# Diff stores the difference between the number of rows and expected row in next layer
diff = [[0 for x in range(2*N)] for y in range(l)]

# m stores the number of dots per column
m = [[0 for x in range(2*N+1)] for y in range(int(N/2+1))]
# Initialization of first column
m[0][0] = 2

for column in range(N):
    if not (column % 2):
        m[0][column] = m[0][column-1] + 2
    else:
        m[0][column] = m[0][column-1] - 1

# Sign extensions
m[0][N] = m[0][N-1] + 1
m[0][N+1] = m[0][N]
m[0][N+2] = m[0][N+1]
m[0][N+3] = m[0][N+2]
m[0][N+4] = m[0][N+3] - 1

for column in range(N+5, 2*N):
    if not ((column-(N+3)) % 2):
        m[0][column] = m[0][column-1] - 1
    else:
        m[0][column] = m[0][column-1]

m_new = [[] for x in range(l+1)]
m_new[0] = copy.deepcopy(m[0])

# Evaluating Half Adders and Full Adders in each column of each layer
for layer in range(l):
    for column in range(2*N):
        diff[layer][column] = m[layer][column] - lj[(l-1)-layer]
        if diff[layer][column] >= 1:
            ha[layer][column] = int(diff[layer][column] % 2)
            fa[layer][column] = int((diff[layer][column] - (diff[layer][column] % 2)) / 2)
            m[layer][column+1] = m[layer][column + 1] + ha[layer][column] + fa[layer][column]
        m[layer+1][column] = m[layer][column] - ha[layer][column] - 2*fa[layer][column]
    m_new[layer+1] = copy.deepcopy(m[layer+1])

for layer in range(l):
    print("Layer " + str(l-(layer+1)) + ": Half adders = " + str(ha[layer]))
    print("Layer " + str(l-(layer+1)) + ": Full adders = " + str(fa[layer]))
print()

matrix = [[] for x in range(l+1)]
tmp = []

# Creating the matrix
for layer in range(l+1):
    for row in range(lj[len(lj) - (layer+1)]):
        for column in range(2*N):
            if column > N+3 and layer == 0:
                if row < lj[len(lj) - 1] - m_new[layer][column]:
                    tmp.append("__________")
                else:
                    tmp.append("p[" + str(layer) + "][" + str(row) + "][" + str(column) + "]")
            else:
                if m_new[layer][column] != 0:
                    tmp.append("p[" + str(layer) + "][" + str(row) + "][" + str(column) + "]")
                    m_new[layer][column] = m_new[layer][column] - 1
                else:
                    tmp.append("__________")
        matrix[layer].append(tmp)
        tmp = []

# Printing the matrix
for l in range(len(matrix)):
    for r in range(len(matrix[l])):
        for c in range(len(matrix[l][r])):
            print(matrix[l][r][c], end =' ')
        print()
    print()

ha_flag = [0 for x in range(2*N)]
fa_flag = [0 for y in range(2*N)]
cout = [0 for x in range(2*N)]
num_ha = [0 for x in range(2*N)]
num_fa = [0 for x in range(2*N)]
inc = [0 for x in range(2*N)]
var = [0 for x in range(2*N)]

for layer in range(len(matrix)-1):
    for row in range(len(matrix[layer])):
        for column in range(2*N):
            if matrix[layer][row][column] != "__________" or layer != 0:
                if not ha_flag[column] and not fa_flag[column]:
                    if ha[layer][column] >= 1:
                        f.write("ha_" + str(layer) + "_" + str(column) + "_" + str(num_ha[column]) + ": Half_Adder port map(" + " a => p_" + str(layer) + "(" + str(row) + ")(" + str(column) + "), " + "b => p_" + str(layer) + "(" + str(row + 1) + ")(" + str(column) + "), " + "cout => p_" + str(layer+1) + "(" + str(lj[len(lj) - layer - 2]-(1+cout[column])) + ")(" + str(column+1) + "), " + "s => p_" + str(layer+1) + "(" + str(row - (var[column] + num_ha[column] + 2*num_fa[column])) + ")(" + str(column) + ")); \n")
                        ha_flag[column] = 1
                        ha[layer][column] = ha[layer][column] - 1
                        cout[column] = cout[column] + 1
                        num_ha[column] = num_ha[column] + 1

                    else:
                        if fa[layer][column] >= 1 and ha_flag[column] == 0 and fa_flag[column] == 0:
                            f.write("fa_" + str(layer) + "_" + str(column) + "_" + str(num_fa[column]) + ": Full_Adder port map(" + " a => p_" + str(layer) + "(" + str(row) + ")(" + str(column) + "), " + "b => p_" + str(layer) + "(" + str(row + 1) + ")(" + str(column) + "), " + "cin => p_" + str(layer) + "(" + str(row + 2) + ")(" + str(column) + "), " + "cout => p_" + str(layer + 1) + "(" + str(lj[len(lj) - layer - 2] - (1+cout[column])) + ")(" + str(column + 1) + "), " + "s => p_" + str(layer + 1) + "(" + str(row - (var[column] + num_ha[column] + 2*num_fa[column])) + ")(" + str(column) + ")); \n")
                            fa_flag[column] = 2
                            fa[layer][column] = fa[layer][column] - 1
                            cout[column] = cout[column] + 1
                            num_fa[column] = num_fa[column] + 1
                        else:
                            if matrix[layer][row][column] != "__________":
                                f.write("p_" + str(layer+1) + "(" + str(row-var[column]-inc[column]) + ")(" + str(column) + ") <= " + "p_" + str(layer) + "(" + str(row) + ")(" + str(column) + "); \n")
                else:
                    if ha_flag[column] != 0:
                        ha_flag[column] = ha_flag[column] - 1
                    else:
                        fa_flag[column] = fa_flag[column] - 1
                    inc[column] = inc[column] + 1
            else:
                var[column] = var[column] + 1
    cout = [0 for x in range(2*N)]
    num_ha = [0 for x in range(2*N)]
    num_fa = [0 for x in range(2*N)]
    var = [0 for x in range(2*N)]
    ha_flag = [0 for x in range(2*N)]
    fa_flag = [0 for x in range(2*N)]
    inc = [0 for x in range(2*N)]

f.close()