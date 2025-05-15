---
tags:
  - daily
refs:
  - '[[<% moment().year() + "-w" + moment().week() + ".todo"%>]]'
---
<% tp.file.cursor(1) %>




# Tasks



> [!info] Last 4 weeks
> ```tasks
> not done
 <%*
  let conditions = [];
  let today = moment();
  for (let i = 0; i < 4; i++) { // Current week + last 3 weeks
    let currentMoment = today.clone().subtract(i, 'weeks');
    let weekStart = currentMoment.clone().startOf('isoWeek'); // Start of ISO week (Monday)
    let weekEnd = currentMoment.clone().endOf('isoWeek'); // End of ISO week (Sunday)

    // Daily notes for this week
    let dailyPaths = [];
    for (let day = 0; day < 7; day++) {
      dailyPaths.push(`(path includes ${weekStart.clone().add(day, 'day').format('YYYY-MM-DD')})`);
    }
    conditions.push(`(${dailyPaths.join(' OR ')})`);

    // Weekly .todo file for this week
    let year = weekStart.year();
    let weekNumber = weekStart.isoWeek(); // Use isoWeek for consistency
    conditions.push(`((path includes ${year}-w${weekNumber}.todo) AND (heading includes Accomplish this week))`);
  }
  tR += conditions.join(' OR ');
 %>
> short mode
> hide created date
> hide edit button
> hide task count
> group by function \
>  const filePath = task.file.path; \
>  /* Check for daily notes like "diary/2024-07-15.md" */ \
>  let dailyMatch = filePath.match(/diary\/(\d{4}-\d{2}-\d{2})\.md$/); \
>  if (dailyMatch) { \
>    const date = dailyMatch[1]; \
>    return moment(date).format("gggg-[w]WW"); /* Returns "YYYY-wWW" */ \
>  } \
>  /* Check for weekly notes like "2024-w29.todo" or paths containing "YYYY-wWW" */ \
>  let weeklyMatch = filePath.match(/(\d{4})-w(\d{1,2})/); \
>  if (weeklyMatch) { \
>    return weeklyMatch[1] + "-w" + weeklyMatch[2].padStart(2, '0'); /* Returns "YYYY-wWW" */ \
>  } \
>  /* Fallback: if path contains a year, group by that year with a generic label for week */ \
>  const yearMatchInPath = filePath.match(/(\d{4})/); \
>  if (yearMatchInPath) { \
>    return yearMatchInPath[1] + " (Other Week)"; \
>  } \
>  return "Other Tasks"; /* Default fallback group */
> ```

![[✱ Inbox#Due]]

| [[✱ Inbox]] | [[✱ Writing\|✱ Writing]] |
| -------------- | ------------------------ |
| [[✱ Work]]     | [[✱ Fragmented]]         |
| [[✱ grocery]]  | [[Henry 3.0]]            |
| [[✱ Skyview]]  | [[unsorted.todo]]        |
***
[[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|⇤]]  | **<% moment(tp.file.title,'YYYY-MM-DD').format("dddd") %>** | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|⇥]]
