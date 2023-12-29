{{DATE:dddd}}

- [ ] Morning
    - [ ] Empty inboxes
    	- [ ] Personal Email
    	- [ ] Work email
    	- [ ] review [[inbox.todo|inbox.todo]] 
    	- [ ] review Slack conversations
    - [ ] Pick tasks to do today
    - [ ] Schedule them into Google Calendar
- [ ] Night
    - [ ] Move tasks to inbox/next day
    - [ ] Pick ⏫ | 🔼 (2 tasks) for tomorrow from [[todo|todo]] | [[work.todo|work.todo]]
    - [ ] review goals/top of mind
    - [ ] review google calendar tomorrow (accept/deny appointments)


*inbox tasks go here*
<% tp.file.cursor(1) %>

## Today
*put tasks that you plan to do today here*

---
[[todo|todo]] | [[work.todo|work.todo]] | [[inbox.todo|inbox.todo]] | [[all.todo#Grocery|;grocery]]
## Priority High / upcoming 20 days
```tasks
not done
priority is above medium
(happens before in 20 days) OR (no due date)
starts before tomorrow
hide created date
hide edit button
heading does not include Daily Review
```
## Priority Medium / upcoming 10 days
```tasks
not done
priority is medium
(happens before in 10 days) OR (no due date)
starts before tomorrow
hide created date
hide edit button
heading does not include Daily Review
```
## (Over) Due
```tasks
not done
due before tomorrow
priority is below medium
sort by priority
hide created date
hide edit button
```

---

The key to my productivity is knowing which tasks take 5 minutes or less. If i know it's more than 5 minutes throw it in a list and then prioritize it right away.

---
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
