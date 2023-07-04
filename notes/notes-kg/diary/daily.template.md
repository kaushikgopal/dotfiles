#### 🧠 🗑️

<% tp.file.cursor() %>




----
> [!quote] <% tp.web.daily_quote() %>
# Goals
## This month (T-<% moment().endOf("month").diff(moment().startOf('day'), "days") %>D)
```tasks
not done
tags include #month 
happens this month
sort by priority
hide edit button
```
## This year (T-<% moment("12-31", "MM-DD").diff(moment().startOf('day'), "days") %>D)

```tasks
not done
tags include #year
sort by priority
hide edit button
```

----
# Tasks

[[;Things]]

### ⏫ Important & Urgent
```tasks
not done
priority is above none
happens before in 7 days
starts before tomorrow
hide created date
hide edit button
```

### (Over) Due
```tasks
not done
due before tomorrow
sort by priority
hide created date
hide edit button
```


## Done

```tasks
done on <% tp.date.now("YYYY-MM-DD") %>
```