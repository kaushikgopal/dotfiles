---
tags:
  - weekly
week: <% moment().week() %>
year:
  - "[[✱ Years#<% moment().year() %>|<% moment().year() %>]]"
---
Update title: <% moment().format('YYYY-MM')  %>


```base
filters:
  and:
    - file.name.startsWith("<% moment().format('YYYY-MM')  %>")
views:
  - type: table
    name: Table
    filters:
      and:
        - file.name != "<% moment().format('YYYY-MM')  %>"


```



***
[[<% moment().subtract(1, 'months').format('YYYY-MM')  %>|Last Week]]
| [[<% moment().add(1, 'months').format('YYYY-MM')  %>|Last Week]]