---
tags:
  - daily
refs:
  - '[[<% moment().year() + "-w" + moment().week() + ".todo"%>]]'
---
<% tp.file.cursor(1) %>


# Tasks

- [ ]
- [ ]
- [ ]


> [!info] Added this week
> ```tasks
> not done
> <%*
  let days = [];
  let today = moment().format('YYYY-MM-DD');
  for(let i=0; i<7; i++) {
    let theDate = moment().startOf('week').add(i, 'day').format('YYYY-MM-DD');
    if (theDate !== today) {
      days.push(`(path includes ${theDate})`);
    }
  }
  let weekPath = `(path includes ${moment().year()}-w${moment().week()}.todo) AND (heading includes Accomplish this week)`;
  tR += days.join(' OR ') + ' OR ' + weekPath;
  %>
> short mode
> hide created date
> hide edit button
> hide task count
> ```

![[✱ Inbox#Due]]



> [!abstract] Last week  🕛
> ```tasks
> not done
> <%*
  // Calculate the start and end of last week (Sunday to Saturday)
  let start = moment().subtract(1, 'week').startOf('week');
  let days = [];
  for(let i=0; i<7; i++) {
    days.push(`(path includes ${start.clone().add(i, 'day').format('YYYY-MM-DD')})`);
  }
  // Last week's week number and year for the .todo file
  let week = moment().subtract(1, 'week');
  let weekPath = `(path includes ${week.year()}-w${week.week()}.todo) AND (heading includes Accomplish this week)`;
  // Combine all
  tR += days.join(' OR ') + ' OR ' + weekPath;
  %>
> short mode
> hide created date
> hide edit button
> hide task count
> ```



| [[✱ Inbox]] | [[✱ Writing\|✱ Writing]] |
| -------------- | ------------------------ |
| [[✱ Work]]     | [[✱ Fragmented]]         |
| [[✱ grocery]]  | [[Henry 3.0]]            |
| [[✱ Skyview]]  | [[unsorted.todo]]        |
***
[[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|⇤]]  | **<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %>** | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|⇥]]
