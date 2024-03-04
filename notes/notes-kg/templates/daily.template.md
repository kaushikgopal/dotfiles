[[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]]
### <% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %>
```tasks
(done in this week) OR (not done)
(tags includes #w1) OR (tags includes #w2) OR (tags includes #w3) OR (tags includes #p1) OR (tags includes #p2) OR (tags includes #p3)
hide created date
hide edit button
hide task count
# hide backlinks
sort by status.type
sort by tag
```
# Notes today

<% tp.file.cursor(1) %>