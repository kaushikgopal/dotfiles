---
tags:
  - daily
refs:
  - '[[<% moment().year() + "-w" + moment().week() + ".todo"%>]]'
---
<% tp.file.cursor(1) %>


# Tasks Today
- [ ] 
- [ ] 
- [ ] 

- [ ] 
- [ ] 
- [ ] 
- [ ] 


***
[[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|⇤]]  | **<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %>** | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|⇥]]

| [[✱ Personal]] | [[✱ Writing\|✱ Writing]] |
| -------------- | ------------------------ |
| [[✱ Work]]     | [[✱ Fragmented]]         |
| [[✱ grocery]]  | [[Henry 3.0]]            |
| [[✱ Skyview]]  | [[unsorted.todo]]        |
### Accomplish this week
```tasks
not done
path includes <%*
tR += moment().year() + "-w" +  moment().week() + ".todo"
%>
heading includes Accomplish
short mode
hide created date
hide edit button
hide task count
```


# Due

![[✱ Personal#Priority / upcoming 20 days]]

![[✱ Personal#(Over)Due]]
