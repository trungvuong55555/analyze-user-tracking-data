from analyst.connect import DAL
import matplotlib.pyplot as plt

dal = DAL()

xR = 0
yR = 50
r = 100
start_ts = '2023-06-07 00:40:28'
end_ts = '2023-06-07 23:40:28'

query = "select lat, lon, convert_milisecond_to_hour(miliseconds) part_hour " \
        "from range_movement (" + str(xR) + \
        ", " + str(yR) +\
        ", " + str(r) +\
        ", TIMESTAMP '" + start_ts + "'"\
        ", TIMESTAMP '" + end_ts + "')"

df = dal.get_table(query)

x = df['lat']
y = df['lon']
z = df['part_hour']
label = "movement within " + str(r) + " radius coordinate (" + str(xR) + ", " + str(yR) + ") "

ax = plt.figure().add_subplot(projection='3d')
ax.scatter(x, y, z, label=label)
ax.legend()
ax.set_xlabel('latitude', color='red')
ax.set_ylabel('longitude', color='blue')
ax.set_zlabel('hour', color='orange')
plt.show()

