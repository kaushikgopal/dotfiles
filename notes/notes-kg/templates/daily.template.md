{{DATE:dddd}}

<% tp.file.cursor(1) %>

- - -
[[1.todo|primary.todo]] | [[2.todo|work.todo]] | [[inbox.todo|inbox.todo]] | [[all.todo#Grocery|;grocery]] | [[letters.kau.sh.todo]] | [[blog/blog.kau.sh.todo|blog.kau.sh.todo]]
- - -
- [ ] Morning: Pick tasks to do today
- [ ] Morning: Schedule them into Google Calendar
- [ ] Morning: Personal Inbox
- [ ] Morning: Work Inbox
- [ ] Morning: Slack conversations
- [ ] Night: Move tasks to inbox/next day
- [ ] Night: Pick ⏫ | 🔼 (2 tasks) for tomorrow from [[1.todo|1.todo]] | [[2.todo|2.todo]]

**Priority High / upcoming 20 days**
```tasks
not done
priority is above medium
(happens before in 20 days) OR (no due date)
starts before tomorrow
hide created date
hide edit button
heading does not include Daily Review
```
**(Over) Due**
```tasks
not done
due before tomorrow
priority is below medium
sort by priority
hide created date
hide edit button
```
**Priority Medium / upcoming 10 days**
```tasks
not done
priority is medium
(happens before in 10 days) OR (no due date)
starts before tomorrow
hide created date
hide edit button
heading does not include Daily Review
```
- - -
## Archived
```tasks
done on <% tp.date.now("YYYY-MM-DD") %>
hide due date
hide recurrence rule
hide done date
hide edit button
heading does not include Daily Routine
heading does not include Daily Review
```
