<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %> || [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]]

<% tp.file.cursor(1) %>




- - -
[[my.todo]] | [[work.todo]] | [[unsorted.todo|unsorted.todo]] | [[all.todo#Grocery|;grocery]] | [[blog.todo|blog]]
- - -
```tasks
not done
(tags include #p0) OR (tags include #p1) OR (tags include #p2)
hide created date
hide edit button
sort by tags
```
- - -
![[due.todo#Priority High / upcoming 20 days]]
![[due.todo#(Over) Due]]
![[due.todo#Priority Medium / upcoming 10 days]]
