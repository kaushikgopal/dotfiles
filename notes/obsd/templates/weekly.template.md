---
tags:
  - weekly
week: <% moment().week() %>
year:
  - "[[✱ Years#<% moment().year() %>|<% moment().year() %>]]"
---
[Last week](<%*
tR += moment().year() + "-w" +  moment().subtract(1, 'weeks').week() + ".todo"
%>) | [Next week](<%*
tR += moment().year() + "-w" +  moment().add(1, 'weeks').week() + ".todo"
%>)

# Tasks
### Prioritized Personal
- [ ] 
### Work
- [ ] 

## Forwarded
```tasks
filter by function task.status.symbol === '>'
path includes <% moment().year() + "-w" + moment().week() + ".todo"%>
short mode
```



***
## now?
```tasks
not done
tags include now
path does not include ✱ Work
sort by priority
short mode
```
```tasks
not done
tags include now
path includes ✱ Work
sort by priority
short mode
```
## Due

![[✱ Personal Backlog#Priority / upcoming 20 days]]

![[✱ Personal Backlog#(Over)Due]]
***
# Goals
I want to accomplish the following this week:
To accomplish the above ↑ I'm breaking tasks over the week
10 small tasks or 5 medium tasks

# Inspiration
1. Start off first [from scratch](https://stephango.com/todos)
2. Are you making progress towards[[✱ Years#<% moment().year() %>|<% moment().year() %>]] ?
3. Anything to carry over from last week?
4. Check [[✱ Personal Backlog]] tasks
5. What are the [[✱ Work Backlog]] tasks you want to do
6. Pick a few [[✱ Skyview maintenance]] tasks
7. Pick one item to put up for sale
