[[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]]
### <% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %>

- Morning: Pick tasks to do today
- Morning: Schedule them into Google Calendar

- Morning: Personal Inbox
- Morning: Work Inbox
- Morning: Slack conversations

- Night: Move tasks to inbox/next day
- Night: Pick ⏫ | 🔼 (2 tasks) for tomorrow 
    - [[1.primary.todo|1.primary.todo]] 
    - [[2.work.todo|2.work.todo]]

# Notes today

<% tp.file.cursor(1) %>