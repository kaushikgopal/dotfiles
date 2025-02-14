---
tags:
  - daily
refs:
  - '[[<% moment().year() + "-w" + moment().week() + ".todo"%>]]'
---
[[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|⇤]]  | **<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %>** | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|⇥]]


<% tp.file.cursor(1) %>



***
[[✱ todo]] | [[✱ Work]] | [[✱ Dashboard]]
# Due

![[✱ todo#Priority / upcoming 20 days]]

![[✱ todo#(Over)Due]]
