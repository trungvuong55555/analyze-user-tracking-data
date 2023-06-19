from analyst.connect import DAL
import matplotlib.pyplot as plt

dal = DAL()

xR = 0
yR = 0
r = 500
part_date = 20230607

query = "select state, part_hour, appear from stat_scope_by_states (" + str(xR) + ", " + str(yR) + ", " + str(r) + ", " + str(
    part_date) + ") where state in ('California', 'New York', 'Texas', 'Washington')"

df = dal.get_table(query)

label = "statistics on the number of people moving by state within a radius of " +\
        str(r) + " coordinates (" + str(xR) + ", " + str(yR) + ") date =" + str(part_date)


fig, ax = plt.subplots()
for state in df['state'].unique():
    ax.plot(df[df.state == state].part_hour, df[df.state == state].appear, label=state)

plt.title(label)
ax.set_xlabel("hour")
ax.set_ylabel("appear")
ax.legend(loc='best')
plt.show()
