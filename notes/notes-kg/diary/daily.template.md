#### 🧠 🗑️





----
> [!quote] <% tp.web.daily_quote() %>
# Goals

> [!hint]
>  - [[Goals#2023]]
>  - <% moment("12-31", "MM-DD").diff(moment().startOf('day'), "months") %> months left
>  - <% moment().endOf("month").diff(moment().startOf('day'), "days") %> days left this month

```tasks
not done
tags include #goal
sort by priority
happens before in 3 days
hide created date
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