---
tags:
  - daily
---
<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %> || [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]]
[[✱ Dashboard]] - [[✱ Work]] |  [[✱ todo]] |   [[unsorted.todo]] |  [[✱ grocery]]


<% tp.file.cursor(1) %>






***
# 3 tasks for the day
### Personal
```tasks
not done
tags include now
path does not include ✱ Work
sort by priority
short mode

```
### Work
```tasks
not done
tags include now
path includes ✱ Work
sort by priority
short mode
```

# Due

![[✱ todo#Priority / upcoming 20 days]]

![[✱ todo#(Over)Due]]
