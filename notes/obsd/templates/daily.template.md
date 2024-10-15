<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %> || [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]]

<% tp.file.cursor(1) %>








- - -
[[✱ Home]] - [[✱ Work]] | [[✱ grocery]] | [[todo]] - [[todo.due]] - [[unsorted.todo|unsorted.todo]] | 
- - -
```tasks
not done
(tags include #p0) OR (tags include #p1) OR (tags include #p2)
hide created date
hide edit button
sort by tags
```
- - -
![[todo.due#Priority High / upcoming 20 days]]
![[todo.due#(Over) Due]]
![[todo.due#Priority Medium / upcoming 10 days]]
