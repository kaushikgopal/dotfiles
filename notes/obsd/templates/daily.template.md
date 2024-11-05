<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %> || [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]]
- - -
[[✱ Dashboard]] - [[✱ Work]] |  [[todo]] |   [[unsorted.todo]] |  [[✱ grocery]]
- - -

<% tp.file.cursor(1) %>




---
```tasks
not done
tags include 3t
hide created date
hide edit button
hide task count
```
![[todo#Due]]
