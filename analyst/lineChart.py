from analyst.connect import DAL
import matplotlib.pyplot as plt

dal = DAL()

xR = 0
yR = 0
r = 500
part_date = 20230607

query = "select * from stat_scope_by_part_hour (" +\
        str(xR) + ", " + str(yR) + ", " + str(r) + ", " + str(part_date) + ")"

df = dal.get_table(query)

x = df['part_hour']
y = df['density']

label = "hourly commuting density with a radius of " + str(r) +\
        " coordinates (" + str(xR) + ", " + str(yR) + ") date =" + str(part_date)

fig = plt.figure()
ax = fig.add_subplot(111)

plt.plot(x, y, color='red')
plt.xlabel("hour", color='blue')
plt.ylabel("density", color='blue')
plt.title(label)

for i, v in enumerate(y):
    ax.annotate(str(v), xy=(i, v), xytext=(-7, 7), textcoords='offset points')

plt.show()
